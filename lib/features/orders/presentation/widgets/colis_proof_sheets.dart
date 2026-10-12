// Les deux moments où le livreur produit une preuve : à la prise en charge et
// à la remise.
//
// Les deux feuilles sont volontairement avares en étapes — un livreur les
// traverse plusieurs fois par jour, sous la pluie, une main sur le guidon.
// Photo, confirmation, c'est tout. Rien n'est demandé qui ne finisse pas dans
// le reçu.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/colis_proof_repository.dart';

/// Prise en charge : photo du colis + confirmation de ce qui est décrit.
/// Renvoie true si la preuve a été enregistrée.
Future<bool> showColisPickupSheet({
  required BuildContext context,
  required ColisProofRepository repo,
  required String orderId,
  required Map<String, dynamic> receipt,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _PickupSheet(repo: repo, orderId: orderId, receipt: receipt),
  );
  return ok ?? false;
}

/// Remise : code à 4 chiffres (ou remise à un tiers désigné) + photo.
Future<bool> showColisDeliverySheet({
  required BuildContext context,
  required ColisProofRepository repo,
  required String orderId,
  required Map<String, dynamic> receipt,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeliverySheet(repo: repo, orderId: orderId, receipt: receipt),
  );
  return ok ?? false;
}

// ─── Habillage commun ────────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({
    super.key,
    required this.photo,
    required this.onTap,
    required this.label,
  });

  final File? photo;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: photo == null ? Colors.orange : Colors.green,
            width: 1.4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: photo == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera_rounded,
                      size: 34, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 2),
                  const Text('Appareil photo uniquement',
                      style: TextStyle(fontSize: 11, color: Colors.black45)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(photo!, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Reprendre',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Le message d'une PostgrestException est écrit pour le livreur (les RPC
/// parlent français) ; tout le reste doit rester lisible malgré tout.
String _humanError(Object e) {
  if (e is PostgrestException) return e.message;
  if (e is StorageException) {
    return "L'envoi de la photo a échoué. Vérifiez votre connexion.";
  }
  return "Une erreur est survenue. Réessayez.";
}

// ─── Prise en charge ─────────────────────────────────────────────────────────

class _PickupSheet extends StatefulWidget {
  const _PickupSheet({
    required this.repo,
    required this.orderId,
    required this.receipt,
  });

  final ColisProofRepository repo;
  final String orderId;
  final Map<String, dynamic> receipt;

  @override
  State<_PickupSheet> createState() => _PickupSheetState();
}

class _PickupSheetState extends State<_PickupSheet> {
  File? _photo;
  /// Chemin de la photo déjà déposée. Conservé pour qu'un nouvel essai après
  /// une erreur réseau ne redépose pas le même fichier — le stockage refuse
  /// les doublons et le livreur resterait bloqué.
  String? _uploadedPath;
  bool _busy = false;
  String? _error;

  Future<void> _take() async {
    final f = await widget.repo.capturePhoto();
    if (f != null && mounted) {
      setState(() {
        _photo = f;
        // Nouvelle photo : l'ancien dépôt ne la représente plus.
        _uploadedPath = null;
      });
    }
  }

  Future<void> _confirm() async {
    if (_photo == null) {
      setState(() => _error = 'La photo du colis est obligatoire.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _uploadedPath ??= await widget.repo.uploadProof(
        orderId: widget.orderId,
        step: 'pickup',
        photo: _photo!,
      );
      await widget.repo
          .recordPickup(orderId: widget.orderId, photoPath: _uploadedPath!);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _humanError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final desc = (widget.receipt['description'] ?? '').toString();
    final value = widget.receipt['declared_value'];

    return _SheetShell(
      title: 'Prise en charge du colis',
      children: [
        // Ce que le livreur confirme recevoir. Affiché avant la photo, pour
        // qu'il compare le colis à la description avant de s'engager.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contenu déclaré',
                  style: TextStyle(fontSize: 11, color: Colors.black54)),
              const SizedBox(height: 3),
              Text(desc.isEmpty ? 'Non précisé' : desc,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text('Valeur déclarée',
                  style: TextStyle(fontSize: 11, color: Colors.black54)),
              const SizedBox(height: 3),
              Text(
                value == null
                    ? 'Non précisée'
                    : '${(value as num).toStringAsFixed(3)} TND',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PhotoButton(
          key: const Key('colis-pickup-photo'),
          photo: _photo,
          onTap: _busy ? () {} : _take,
          label: 'Photographier le colis',
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 12.5)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _busy ? null : _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Je confirme avoir reçu ce colis',
                    style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
        ),
      ],
    );
  }
}

// ─── Remise ──────────────────────────────────────────────────────────────────

class _DeliverySheet extends StatefulWidget {
  const _DeliverySheet({
    required this.repo,
    required this.orderId,
    required this.receipt,
  });

  final ColisProofRepository repo;
  final String orderId;
  final Map<String, dynamic> receipt;

  @override
  State<_DeliverySheet> createState() => _DeliverySheetState();
}

class _DeliverySheetState extends State<_DeliverySheet> {
  final _codeCtrl = TextEditingController();
  File? _photo;
  /// Déposée une seule fois pour toute la session de la feuille. C'est le
  /// point précis où le bug vivait : un code erroné laissait la photo en
  /// place, et l'essai suivant butait sur le refus de doublon du stockage.
  String? _uploadedPath;
  bool _busy = false;
  String? _error;
  late int _attempts;

  bool get _noCode => widget.receipt['delivery_mode'] == 'no_code';

  @override
  void initState() {
    super.initState();
    _attempts = (widget.receipt['code_attempts'] as num?)?.toInt() ?? 0;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _take() async {
    final f = await widget.repo.capturePhoto();
    if (f != null && mounted) {
      setState(() {
        _photo = f;
        _uploadedPath = null;
      });
    }
  }

  Future<void> _callSender() async {
    final phone = (widget.receipt['sender_phone'] ?? '').toString().trim();
    if (phone.isEmpty) {
      setState(() => _error = "Le numéro de l'expéditeur n'est pas disponible.");
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      setState(() => _error = "Impossible d'ouvrir le téléphone.");
    }
  }

  Future<void> _confirm() async {
    if (_photo == null) {
      setState(() => _error = 'La photo de remise est obligatoire.');
      return;
    }
    if (!_noCode && _codeCtrl.text.trim().length != 4) {
      setState(() => _error = 'Saisissez les 4 chiffres donnés par le client.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Déposée au premier essai, réutilisée ensuite : un code erroné ne doit
      // pas condamner les essais suivants.
      _uploadedPath ??= await widget.repo.uploadProof(
        orderId: widget.orderId,
        step: 'delivery',
        photo: _photo!,
      );
      await widget.repo.verifyAndDeliver(
        orderId: widget.orderId,
        photoPath: _uploadedPath!,
        code: _noCode ? null : _codeCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _humanError(e);
          // Le serveur fait foi sur le compte ; on l'avance ici seulement
          // pour que le livreur voie son crédit diminuer tout de suite.
          if (!_noCode) _attempts = (_attempts + 1).clamp(0, kColisMaxCodeAttempts);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final left = kColisMaxCodeAttempts - _attempts;
    final locked = widget.receipt['code_locked_at'] != null || left <= 0;

    return _SheetShell(
      title: _noCode ? 'Remise sans code' : 'Remise du colis',
      children: [
        if (_noCode)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('À remettre à',
                    style: TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 3),
                Text(
                  (widget.receipt['receiver_label'] ?? '—').toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  "L'expéditeur a accepté que la photo et la position tiennent "
                  'lieu de preuve pour ce colis.',
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          )
        else if (locked)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Trop de codes erronés. Un administrateur a été alerté et doit '
              'intervenir pour clôturer cette livraison.',
              style: TextStyle(fontSize: 13, color: Color(0xFFB71C1C)),
            ),
          )
        else ...[
          const Text('Code à 4 chiffres donné par le destinataire',
              style: TextStyle(fontSize: 12.5, color: Colors.black54)),
          const SizedBox(height: 8),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            enabled: !_busy,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 14),
            decoration: InputDecoration(
              counterText: '',
              hintText: '––––',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                left == kColisMaxCodeAttempts
                    ? '$kColisMaxCodeAttempts essais possibles'
                    : '$left essai${left > 1 ? 's' : ''} restant${left > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 11.5,
                  color: left <= 2 ? Colors.red : Colors.black45,
                ),
              ),
              // Le destinataire n'a pas toujours le code sous les yeux :
              // l'expéditeur, lui, l'a dans son suivi de commande. Un appel
              // vaut mieux qu'un colis qui repart.
              TextButton.icon(
                onPressed: _busy ? null : _callSender,
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: const Text("Appeler l'expéditeur",
                    style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        _PhotoButton(
          key: const Key('colis-delivery-photo'),
          photo: _photo,
          onTap: _busy ? () {} : _take,
          label: 'Photographier la remise',
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 12.5)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_busy || locked) ? null : _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(
                    _noCode ? 'Confirmer la remise' : 'Valider le code et livrer',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
        ),
      ],
    );
  }
}
