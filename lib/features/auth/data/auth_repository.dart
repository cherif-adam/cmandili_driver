import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/background_location_service.dart';

// Simple User class to replace Firebase User
class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String role;

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.role = 'client',
  });

  factory User.fromSupabase(supabase.User user) {
    return User(
      uid: user.id,
      email: user.email,
      displayName: user.userMetadata?['full_name'] as String? ?? user.userMetadata?['name'] as String?,
      photoURL: user.userMetadata?['avatar_url'] as String? ?? user.userMetadata?['picture'] as String?,
      role: user.appMetadata['role'] as String? ?? 'client',
    );
  }
}

class AuthRepository {
  final _supabase = supabase.Supabase.instance.client;
  final _googleSignIn = GoogleSignIn(
    serverClientId: '1047309149711-09in2f2qoce5upqcno61ekuevp2e5hjk.apps.googleusercontent.com',
  );
  
  // Get current user
  User? get currentUser {
    final user = _supabase.auth.currentUser;
    return user != null ? User.fromSupabase(user) : null;
  }

  // Auth state changes stream
  /// L'etat de connexion, tel que l'ecran principal doit le lire.
  ///
  /// Deux protections, et chacune corrige un symptome observe.
  ///
  /// AMORCAGE. On emet d'abord la session REELLE, sans attendre un evenement.
  /// `onAuthStateChange` est un BehaviorSubject : un nouvel abonne recoit sa
  /// derniere valeur, qui peut n'avoir aucun rapport avec l'etat courant --
  /// ou ne rien contenir du tout.
  ///
  /// ERREURS NEUTRALISEES. `notifyException` pousse les ERREURS dans ce meme
  /// sujet : un rafraichissement de jeton qui echoue met le flux en erreur.
  /// Changer son mot de passe revoque justement les jetons des autres
  /// sessions, donc le rafraichissement suivant echouait. L'ecran principal
  /// traduisait cette erreur par « pas de session » et affichait l'ecran de
  /// connexion -- la connexion suivante reussissait cote serveur, mais rien
  /// ne bougeait, et seul un redemarrage reparait, puisqu'il recree le sujet.
  /// Un `ref.invalidate` n'y pouvait rien : le sujet REJOUE son erreur au
  /// nouvel abonne.
  ///
  /// Une panne de rafraichissement n'est pas une deconnexion. Elle est
  /// signalee, jamais propagee ; le dernier etat connu tient.
  /// Voir test/auth_state_stream_test.dart.
  Stream<User?> get authStateChanges {
    User? fromSession(supabase.Session? session) {
      final user = session?.user;
      return user != null ? User.fromSupabase(user) : null;
    }

    final out = StreamController<User?>();
    out.add(fromSession(_supabase.auth.currentSession));

    final sub = _supabase.auth.onAuthStateChange.listen(
      (data) => out.add(fromSession(data.session)),
      onError: (Object e) {
        debugPrint('authStateChanges: erreur ignoree ($e)');
      },
    );
    out.onCancel = sub.cancel;
    return out.stream;
  }

  /// Y a-t-il une session utilisable maintenant. Apres une inscription, c'est
  /// faux quand le projet exige une confirmation par email : le compte existe,
  /// mais l'utilisateur ne peut pas encore entrer.
  bool get hasSession => _supabase.auth.currentSession != null;

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    // GoTrue can occasionally hang indefinitely on this call (observed after
    // a sign-out earlier in the same session) — without a timeout the button
    // spins forever with no error and no way to recover short of killing the
    // app. Force it to fail instead so the UI can reset and the user can retry.
    final response = await _supabase.auth
        .signInWithPassword(email: email, password: password)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw 'La connexion prend trop de temps. Réessaie.',
        );

    final user = response.user;
    if (user == null) throw 'Sign in failed';

    return User.fromSupabase(user);
  }

  // Sign up with email and password — also inserts a drivers row immediately
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );

    final user = response.user;
    if (user == null) throw 'Sign up failed';

    await _ensureDriverRow(user.id, phone);
    return User.fromSupabase(user);
  }

  Future<void> _ensureDriverRow(String userId, String phone) async {
    await _supabase.from('drivers').upsert({
      'user_id': userId,
      'is_online': false,
    }, onConflict: 'user_id');

    // Store phone on the profiles row (created by the auth trigger)
    if (phone.isNotEmpty) {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'phone': phone,
      }, onConflict: 'id');
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) throw 'Google sign in failed';

      // Google sign-in: phone not available at this point; driver can update it from profile settings
      await _ensureDriverRow(user.id, '');

      return User.fromSupabase(user);
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  // Apple Sign-In not surfaced in driver UI — reserved for future use.
  Future<User?> signInWithApple() async {
    throw UnimplementedError('Apple Sign In is not available in the driver app.');
  }

  // Sign out
  Future<void> signOut() async {
    // Remove this device's push token before the session ends. Left
    // unremoved, a stale row keeps receiving pushes for this account even
    // after a different account signs in on the same physical device --
    // confirmed live: a driver's status-update pushes were reaching a
    // phone that had since switched to a different test account, because
    // its old token from months ago was still sitting in device_tokens.
    // Must run before auth.signOut() -- the RLS policy needs auth.uid()
    // to still resolve to this user.
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _supabase.from('device_tokens').delete().eq('token', token);
      }
    } catch (e) {
      debugPrint('signOut: failed to remove device token: $e');
    }
    // Same class of bug as the device-token one above, for the GPS
    // foreground service: startTracking()/startOnlinePresence() persist this
    // driver's id to SharedPreferences (bg_driver_id/bg_delivery_id) for the
    // background isolate to read, completely separate from the Supabase auth
    // session. If a different account signs in on this same physical device
    // without this call, that isolate keeps running under the OLD driver's
    // id — still pushing their GPS to `drivers`/`deliveries` and still
    // showing their delivery-offer alarm — with no visible link to whichever
    // account is actually signed in. Confirmed live on a real device: a
    // stale bg_driver_id from a previous test account kept ringing and
    // updating location well after the app had switched to a different
    // signed-in user. No RLS dependency (purely local SharedPreferences +
    // stopping the service), so ordering relative to auth.signOut() doesn't
    // matter the way it does for the token deletion above.
    await BackgroundLocationService.stopTracking();
    // La session Supabase est ce sur quoi l'app s'oriente : elle doit finir
    // meme si la deconnexion Google echoue (utilisateur jamais passe par Google).
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('signOut: deconnexion Google echouee ($e), on continue');
    }
    await _supabase.auth.signOut();
  }

  // ── Password reset (OTP flow) ──────────────────────────────────────────────

  /// Step 1 — Sends a 6-digit recovery code to [email].
  Future<void> sendPasswordResetOtp(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Step 2 — Verifies the 6-digit [token] and establishes a recovery session.
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: supabase.OtpType.recovery,
    );
  }

  /// Step 3 — Updates the password.  Must follow a successful [verifyPasswordResetOtp].
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      supabase.UserAttributes(password: newPassword),
    );
  }

  // ── Changement de mot de passe, utilisateur connecte ──────────────────────

  /// Change le mot de passe d'un utilisateur DEJA connecte.
  ///
  /// Renvoie `null` en cas de succes, sinon un CODE d'erreur que l'ecran
  /// traduit : le depot ne connait pas la langue du client, et les messages
  /// que renvoie Supabase sont en anglais.
  ///
  ///   wrong_current   le mot de passe actuel est faux
  ///   same_as_old     le nouveau est identique a l'ancien
  ///   too_short       refuse par le serveur (longueur, politique)
  ///   reauth_needed   « Secure password change » est actif cote Supabase :
  ///                   il faut un code de reauthentification recent
  ///   no_session      plus de session, ou compte sans email
  ///   failed          tout le reste
  ///
  /// Le mot de passe actuel est verifie en se reconnectant avec lui. C'est la
  /// seule verification que Supabase offre : il n'existe pas d'API « ce mot de
  /// passe est-il le bon ». signInWithPassword rafraichit la session en place,
  /// l'utilisateur n'est donc pas deconnecte de cet appareil -- mais il FAUT
  /// verifier avant, sinon un telephone laisse deverrouille suffirait a
  /// changer le mot de passe du compte.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null || email.isEmpty) return 'no_session';

    if (currentPassword == newPassword) return 'same_as_old';

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on supabase.AuthException catch (e) {
      debugPrint('changePassword: reauth refusee (${e.message})');
      return 'wrong_current';
    } catch (e) {
      debugPrint('changePassword: reauth impossible ($e)');
      return 'failed';
    }

    try {
      await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      return null;
    } on supabase.AuthException catch (e) {
      final m = e.message.toLowerCase();
      // Supabase ne renvoie pas de code stable ici : on lit le message, et on
      // retombe sur 'failed' plutot que d'afficher de l'anglais au client.
      if (m.contains('reauthentication')) return 'reauth_needed';
      if (m.contains('should be different') ||
          m.contains('same as the old')) {
        return 'same_as_old';
      }
      if (m.contains('at least') || m.contains('password')) return 'too_short';
      debugPrint('changePassword: refus serveur (${e.message})');
      return 'failed';
    } catch (e) {
      debugPrint('changePassword: echec ($e)');
      return 'failed';
    }
  }

  /// Deconnecte les AUTRES appareils, en gardant celui-ci connecte.
  ///
  /// Propose apres un changement de mot de passe : si quelqu'un d'autre avait
  /// une session ouverte, la changer ne la ferme pas toute seule.
  Future<bool> signOutOtherDevices() async {
    try {
      await _supabase.auth.signOut(scope: supabase.SignOutScope.others);
      return true;
    } catch (e) {
      debugPrint('signOutOtherDevices: $e');
      return false;
    }
  }
}
