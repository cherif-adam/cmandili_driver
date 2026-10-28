// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get pwdIntro =>
      'Saisissez votre mot de passe actuel, puis choisissez-en un nouveau. Vous resterez connecté sur cet appareil.';

  @override
  String get pwdCurrent => 'Mot de passe actuel';

  @override
  String get pwdNew => 'Nouveau mot de passe';

  @override
  String get pwdConfirm => 'Confirmer le nouveau mot de passe';

  @override
  String get pwdErrorRequired => 'Champ obligatoire';

  @override
  String get pwdErrorWrongCurrent => 'Mot de passe actuel incorrect';

  @override
  String pwdErrorTooShort(int min) {
    return 'Au moins $min caractères';
  }

  @override
  String get pwdErrorMismatch => 'Les deux mots de passe ne correspondent pas';

  @override
  String get pwdErrorSameAsOld =>
      'Le nouveau mot de passe est identique à l\'ancien';

  @override
  String get pwdErrorReauthNeeded =>
      'Par sécurité, confirmez à nouveau votre identité avant de changer votre mot de passe';

  @override
  String get pwdErrorNoSession => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get pwdErrorFailed =>
      'Impossible de changer le mot de passe. Réessayez.';

  @override
  String get pwdChangedTitle => 'Mot de passe modifié';

  @override
  String get pwdChangedBody =>
      'D\'autres appareils restent connectés avec l\'ancienne session. Voulez-vous les déconnecter ?';

  @override
  String get pwdKeepOtherDevices => 'Les garder';

  @override
  String get pwdSignOutOthers => 'Déconnecter les autres appareils';

  @override
  String get pwdOtherDevicesSignedOut =>
      'Les autres appareils ont été déconnectés';

  @override
  String get appTitle => 'Amana';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get fullName => 'Nom complet';

  @override
  String get or => 'OU';

  @override
  String pleaseEnter(Object field) {
    return 'Veuillez entrer votre $field';
  }

  @override
  String get validEmail => 'Veuillez entrer un email valide';

  @override
  String get passwordLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get phoneInvalid =>
      'Veuillez entrer un numéro de téléphone valide à 8 chiffres';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get profile => 'Profil';

  @override
  String get logout => 'Déconnexion';

  @override
  String get home => 'Accueil';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get search => 'Rechercher...';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get notificationsWillAppearHere =>
      'Les notifications apparaîtront ici';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get retry => 'Réessayer';

  @override
  String get availableOrders => 'Commandes disponibles';

  @override
  String get noOrdersAvailable => 'Aucune commande disponible pour l\'instant';

  @override
  String get pullDownToRefresh => 'Tirez vers le bas pour actualiser';

  @override
  String get acceptOrder => 'Accepter la commande';

  @override
  String get failedToAcceptOrder => 'Échec de l\'acceptation de la commande';

  @override
  String get markPickedUp => 'Marquer comme récupéré';

  @override
  String get startDelivery => 'Démarrer la livraison (En route)';

  @override
  String get confirmDelivery => 'Confirmer la livraison';

  @override
  String get deliveryCompleted => 'Livraison terminée !';

  @override
  String get deliveringOrder => 'Livraison de la commande';

  @override
  String get deliveryLocation => 'Adresse de livraison';

  @override
  String get orderMarkedPickedUp => 'Commande marquée comme récupérée !';

  @override
  String get deliveryStarted => 'Livraison démarrée !';

  @override
  String get deliveryConfirmed => 'Livraison confirmée !';

  @override
  String get earnings => 'Revenus';

  @override
  String get totalEarnings => 'Revenus totaux';

  @override
  String get deliveriesCompleted => 'livraisons effectuées';

  @override
  String get recentDeliveries => 'Livraisons récentes';

  @override
  String get noDeliveriesYet => 'Aucune livraison pour l\'instant';

  @override
  String get couldNotLoadEarnings => 'Impossible de charger les revenus';

  @override
  String get couldNotLoadHistory => 'Impossible de charger l\'historique';

  @override
  String get driverProfileNotFound => 'Profil chauffeur introuvable';

  @override
  String get locationPermissionDenied => 'Permission de localisation refusée';

  @override
  String get savedAddresses => 'Adresses enregistrées';

  @override
  String get noAddressesSaved => 'Aucune adresse enregistrée';

  @override
  String get addressRemoved => 'Adresse supprimée';

  @override
  String get setDefault => 'Définir par défaut';

  @override
  String get addNewAddress => 'Ajouter une nouvelle adresse';

  @override
  String get labelHint => 'Étiquette (ex. Maison, Travail)';

  @override
  String get fullAddressLabel => 'Adresse complète';

  @override
  String get defaultLabel => 'Par défaut';

  @override
  String get paymentMethods => 'Moyens de paiement';

  @override
  String get noPaymentMethods => 'Aucun moyen de paiement enregistré';

  @override
  String get addNewCard => 'Ajouter une nouvelle carte';

  @override
  String get cardholderName => 'Nom du titulaire';

  @override
  String get cardNumber => 'Numéro de carte';

  @override
  String get expiryDate => 'Date d\'expiration (MM/AA)';

  @override
  String get vehicleInfoSaved => 'Informations du véhicule enregistrées';

  @override
  String get vehicleInfo => 'Informations du véhicule';

  @override
  String get vehicleType => 'Type de véhicule';

  @override
  String get vehicleMakeHint => 'Marque (ex. Yamaha)';

  @override
  String get required => 'Requis';

  @override
  String get vehicleModelHint => 'Modèle (ex. NMAX)';

  @override
  String get licensePlate => 'Plaque d\'immatriculation';

  @override
  String get color => 'Couleur';

  @override
  String get saveVehicleInfo => 'Enregistrer les informations';

  @override
  String get pleaseSignInFirst => 'Veuillez vous connecter d\'abord.';

  @override
  String get supportTicketSent =>
      'Ticket d\'assistance envoyé ! Nous vous contacterons bientôt.';

  @override
  String get helpSupport => 'Aide et support';

  @override
  String get howCanWeHelp => 'Comment pouvons-nous vous aider ?';

  @override
  String get fillFormDescription =>
      'Remplissez le formulaire ci-dessous et notre équipe vous répondra dans les 24 heures.';

  @override
  String get subject => 'Sujet';

  @override
  String get pleaseEnterSubject => 'Veuillez entrer un sujet';

  @override
  String get message => 'Message';

  @override
  String get pleaseEnterMessage => 'Veuillez entrer votre message';

  @override
  String get submitTicket => 'Envoyer le ticket';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès !';

  @override
  String get failedToUpdateProfile => 'Échec de la mise à jour du profil.';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get phoneNumberLabel => 'Numéro de téléphone';

  @override
  String get bio => 'Bio';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get pleaseEnterName => 'Veuillez entrer votre nom';

  @override
  String get payoutInfoSaved => 'Informations de paiement enregistrées';

  @override
  String get earningsAndStatus => 'Revenus et statut';

  @override
  String get youAreOnline => 'Vous êtes en ligne';

  @override
  String get youAreOffline => 'Vous êtes hors ligne';

  @override
  String get parcelPickupTitle => 'Colis à récupérer';

  @override
  String get parcelDeliverTitle => 'Livraison du colis';

  @override
  String get parcelStepSender => '1. Récupérer chez l\'expéditeur';

  @override
  String get parcelStepRecipient => '2. Livrer au destinataire';

  @override
  String get parcelSender => 'Expéditeur';

  @override
  String get parcelRecipient => 'Destinataire';

  @override
  String get parcelCollected => 'Colis récupéré';

  @override
  String get parcelCollectedSnack =>
      'Colis récupéré. En route vers le destinataire.';

  @override
  String get parcelHandedOver => 'Colis remis — Terminer';

  @override
  String get parcelCallOnArrival => 'Appelez le destinataire à votre arrivée.';

  @override
  String get parcelActionFailed =>
      'Mise à jour impossible. Vérifiez la connexion et réessayez.';

  @override
  String get myReviews => 'Mes avis';

  @override
  String get noReviewsYet => 'Pas encore d\'avis';

  @override
  String get noReviewsYetHint =>
      'Les notes des clients apparaissent ici après vos livraisons.';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '1 avis',
      zero: 'Aucun avis',
    );
    return '$_temp0';
  }

  @override
  String get bgGuideTitle => 'Recevoir les commandes, application fermée';

  @override
  String get bgGuideBody =>
      'Ce téléphone peut arrêter l\'application en arrière-plan. Pour que l\'alarme sonne même application fermée :';

  @override
  String get bgGuideStep1 =>
      'Activez « Démarrage automatique » pour cette application.';

  @override
  String get bgGuideStep2 =>
      'Économiseur de batterie : choisissez « Aucune restriction ».';

  @override
  String get bgGuideOpen => 'Ouvrir les réglages';

  @override
  String get bgGuideDone => 'C\'est fait';

  @override
  String get bgGuideLater => 'Plus tard';

  @override
  String get canReceiveOrders => 'Vous pouvez recevoir de nouvelles commandes';

  @override
  String get turnOnToReceive => 'Activez pour recevoir des commandes';

  @override
  String get bankPayoutInfo => 'Informations bancaires';

  @override
  String get payoutsWeekly =>
      'Les paiements sont envoyés chaque semaine sur votre compte bancaire.';

  @override
  String get accountHolderName => 'Nom du titulaire du compte';

  @override
  String get bankName => 'Nom de la banque';

  @override
  String get ibanRib => 'IBAN / RIB';

  @override
  String get enterValidIban => 'Entrez un IBAN/RIB valide';

  @override
  String get savePayoutInfo => 'Enregistrer les informations';

  @override
  String get account => 'Compte';

  @override
  String get earningsAndPayout => 'Revenus et paiement';

  @override
  String get delivery => 'Livraison';

  @override
  String get you => 'Vous';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get customer => 'Client';

  @override
  String get deliveryHistory => 'Historique des livraisons';

  @override
  String get completedDeliveriesAppearHere =>
      'Les livraisons terminées apparaîtront ici';

  @override
  String get delivered => 'Livré';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get locationOff =>
      'La localisation est désactivée. Activez-la dans les paramètres du téléphone.';

  @override
  String get locationDeniedSettings =>
      'Permission de localisation refusée. Accordez-la dans les paramètres de l\'application.';

  @override
  String get driverDashboard => 'Tableau de bord chauffeur';

  @override
  String get youHaveActiveDelivery => 'Vous avez une livraison active';

  @override
  String get readyForOrders => 'Prêt pour les commandes';

  @override
  String get youreOfflineFlip =>
      'Vous êtes hors ligne — activez le bouton pour commencer';

  @override
  String get available => 'Disponible';

  @override
  String get active => 'Active';

  @override
  String get activeDelivery => 'Livraison active';

  @override
  String get yourLocation => 'Votre position';

  @override
  String get expand => 'Agrandir';

  @override
  String get ordersWaitingForDriver => 'commande(s) en attente d\'un chauffeur';

  @override
  String get viewAvailableOrders => 'Voir les commandes disponibles';

  @override
  String get onTheWay => 'En route';

  @override
  String get noActiveDelivery => 'Aucune livraison active';

  @override
  String get acceptOrderToStart =>
      'Acceptez une commande pour commencer à livrer';

  @override
  String get browseAvailableOrders => 'Parcourir les commandes disponibles';

  @override
  String get orders => 'Commandes';

  @override
  String get deleteAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountIntro =>
      'La suppression est définitive. Vous ne pourrez plus vous connecter avec ce compte.';

  @override
  String get deleteAccountDeletedTitle => 'Ce qui sera supprimé';

  @override
  String get deleteAccountDeletedDevices =>
      'Vos notifications et vos appareils connectés';

  @override
  String get deleteAccountKeptTitle => 'Ce qui sera gardé';

  @override
  String get deleteAccountKeptWhy =>
      'Ces informations sont conservées pour la comptabilité et en cas de litige.';

  @override
  String get deleteAccountBlockedTitle =>
      'Votre compte ne peut pas encore être supprimé';

  @override
  String get deleteAccountContactTeam => 'Contacter l\'équipe Amana';

  @override
  String get deleteAccountBlockerAdmin =>
      'C\'est un compte administrateur : il ne peut pas être supprimé depuis l\'app.';

  @override
  String deleteAccountBlockerActiveOrders(int count) {
    return 'Vous avez $count commande(s) en cours. Attendez qu\'elles soient livrées ou annulées.';
  }

  @override
  String get deleteAccountBlockerOpenDisputes =>
      'Un litige colis est encore ouvert. Attendez que l\'équipe Amana le clôture.';

  @override
  String deleteAccountBlockerDriverOrders(int count) {
    return 'Vous avez $count livraison(s) en cours. Terminez-les d\'abord.';
  }

  @override
  String get deleteAccountBlockerDriverDisputes =>
      'Un litige colis vous concernant est encore ouvert. Attendez que l\'équipe Amana le clôture.';

  @override
  String get deleteAccountBlockerDriverPayouts =>
      'Amana vous doit encore des primes. Contactez l\'équipe Amana pour solder votre compte.';

  @override
  String deleteAccountBlockerShopOrders(int count) {
    return 'Votre boutique a $count commande(s) en cours. Terminez-les ou annulez-les d\'abord.';
  }

  @override
  String deleteAccountBlockerWallet(String amount) {
    return 'Il reste $amount TND sur votre solde. Contactez l\'équipe Amana pour solder votre compte.';
  }

  @override
  String get deleteAccountBlockerSettlements =>
      'Un règlement est en attente. Contactez l\'équipe Amana pour solder votre compte.';

  @override
  String get deleteAccountBlockerUnknown =>
      'Votre compte ne peut pas être supprimé pour le moment. Contactez l\'équipe Amana.';

  @override
  String get deleteAccountConfirmWord => 'SUPPRIMER';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Pour confirmer, tapez $word';
  }

  @override
  String deleteAccountWordMismatch(String word) {
    return 'Tapez exactement $word';
  }

  @override
  String get deleteAccountPasswordHint =>
      'Pour votre sécurité, entrez votre mot de passe';

  @override
  String get deleteAccountPasswordLabel => 'Mot de passe';

  @override
  String get deleteAccountGoogleHint =>
      'Pour votre sécurité, vous allez vous reconnecter avec le compte Google de ce compte.';

  @override
  String get deleteAccountSubmit => 'Supprimer définitivement mon compte';

  @override
  String get deleteAccountErrorWrongPassword => 'Mot de passe incorrect.';

  @override
  String get deleteAccountErrorOtherGoogle =>
      'Ce compte Google n\'est pas celui de ce compte Amana.';

  @override
  String get deleteAccountErrorReauth =>
      'Votre confirmation a expiré. Recommencez.';

  @override
  String get deleteAccountErrorNoMethod =>
      'Ce compte ne peut pas être confirmé dans l\'app. Contactez l\'équipe Amana.';

  @override
  String get deleteAccountErrorFailed =>
      'La suppression a échoué. Réessayez ou contactez l\'équipe Amana.';

  @override
  String get deleteAccountLoadError =>
      'Impossible de vérifier votre compte. Vérifiez votre connexion.';

  @override
  String get deleteAccountRetry => 'Réessayer';

  @override
  String get deleteAccountDoneTitle => 'Compte supprimé';

  @override
  String get deleteAccountDoneOk => 'OK';

  @override
  String get deleteAccountDeletedContact =>
      'Vos coordonnées : nom, téléphone, email et photo';

  @override
  String get deleteAccountDeletedBank => 'Vos coordonnées bancaires';

  @override
  String get deleteAccountDriverOffline =>
      'Vous serez retiré des livreurs : plus aucune course ne vous sera proposée';

  @override
  String get deleteAccountKeptDeliveries =>
      'L\'historique de vos livraisons, pour la comptabilité : dates, statut et montants, sans vos positions';

  @override
  String get deleteAccountKeptMoney =>
      'Vos gains, les règlements et l\'historique de votre solde';

  @override
  String get deleteAccountKeptIdentity =>
      'Votre dossier d\'identité et votre contrat, visibles uniquement par l\'équipe Amana, 5 ans après votre dernière livraison, puis ils sont effacés';

  @override
  String get deleteAccountDoneBody =>
      'Votre compte a été supprimé. Merci d\'avoir travaillé avec Amana.';

  @override
  String get deleteAccountDeletedVehicle =>
      'Votre véhicule et vos positions GPS';

  @override
  String get deleteAccountKeptColisDriver =>
      'Votre nom, votre plaque et votre CIN sur les bons des colis livrés, 30 jours après votre dernière livraison, puis ils sont effacés';

  @override
  String get myContract => 'Mon contrat';

  @override
  String get contractNone =>
      'Aucun contrat pour l\'instant. L\'équipe Amana vous l\'enverra ici.';

  @override
  String get contractStatusSent =>
      'Votre contrat est prêt. Signez-le, faites légaliser votre signature à la baladiya, puis envoyez-en une photo.';

  @override
  String get contractStatusSubmitted =>
      'Photo envoyée. L\'équipe Amana vérifie votre contrat.';

  @override
  String get contractStatusApproved => 'Votre contrat est validé.';

  @override
  String get contractStatusRejected =>
      'Votre contrat a été refusé. Envoyez une nouvelle photo.';

  @override
  String get contractReason => 'Motif :';

  @override
  String get contractStep1 => 'Téléchargez le contrat.';

  @override
  String get contractStep2 => 'Imprimez-le et signez-le.';

  @override
  String get contractStep3 => 'Faites légaliser votre signature à la baladiya.';

  @override
  String get contractStep4 =>
      'Prenez une photo nette du contrat signé et tamponné, puis envoyez-la.';

  @override
  String get contractDownload => 'Télécharger le contrat';

  @override
  String get contractSendPhoto => 'Envoyer la photo du contrat signé';

  @override
  String get contractResendPhoto => 'Renvoyer une autre photo';

  @override
  String get contractTakePhoto => 'Prendre une photo';

  @override
  String get contractChooseGallery => 'Choisir dans la galerie';

  @override
  String get contractSent => 'Photo envoyée à l\'équipe Amana.';

  @override
  String get contractSendFailed =>
      'La photo n\'a pas pu être envoyée. Réessayez.';

  @override
  String get contractDownloadFailed =>
      'Le contrat n\'a pas pu être ouvert. Réessayez.';

  @override
  String get locationDisclosureTitle => 'Votre position pendant le service';

  @override
  String get locationDisclosureIntro =>
      'Amana utilise la position précise de votre téléphone quand vous êtes en ligne, y compris lorsque l\'application est fermée ou en arrière-plan :';

  @override
  String get locationDisclosureUseOffers =>
      'pour vous proposer les commandes proches de vous ;';

  @override
  String get locationDisclosureUseTracking =>
      'pour montrer votre trajet au client et au commerçant pendant une livraison ;';

  @override
  String get locationDisclosureUseProof =>
      'pour enregistrer le lieu de remise des colis.';

  @override
  String get locationDisclosureStop =>
      'Le suivi s\'arrête dès que vous passez hors ligne. Une notification reste affichée tant qu\'il est actif. Vous pouvez retirer l\'accès à tout moment dans les paramètres du téléphone.';

  @override
  String get locationDisclosureContinue => 'Continuer';

  @override
  String get locationDisclosureNotNow => 'Pas maintenant';

  @override
  String get locationDisclosureDeclined =>
      'Sans la localisation, vous ne pouvez pas recevoir de commandes. Vous pourrez l\'activer en passant en ligne.';
}
