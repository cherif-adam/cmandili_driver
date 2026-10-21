// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get changePassword => 'Change password';

  @override
  String get pwdIntro =>
      'Enter your current password, then choose a new one. You will stay signed in on this device.';

  @override
  String get pwdCurrent => 'Current password';

  @override
  String get pwdNew => 'New password';

  @override
  String get pwdConfirm => 'Confirm new password';

  @override
  String get pwdErrorRequired => 'Required';

  @override
  String get pwdErrorWrongCurrent => 'Current password is wrong';

  @override
  String pwdErrorTooShort(int min) {
    return 'At least $min characters';
  }

  @override
  String get pwdErrorMismatch => 'The two passwords do not match';

  @override
  String get pwdErrorSameAsOld => 'The new password is the same as the old one';

  @override
  String get pwdErrorReauthNeeded =>
      'For security, confirm your identity again before changing your password';

  @override
  String get pwdErrorNoSession => 'Your session has expired. Sign in again.';

  @override
  String get pwdErrorFailed => 'Could not change the password. Try again.';

  @override
  String get pwdChangedTitle => 'Password changed';

  @override
  String get pwdChangedBody =>
      'Other devices are still signed in with the old session. Sign them out?';

  @override
  String get pwdKeepOtherDevices => 'Keep them';

  @override
  String get pwdSignOutOthers => 'Sign out other devices';

  @override
  String get pwdOtherDevicesSignedOut => 'Other devices have been signed out';

  @override
  String get appTitle => 'Amana';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get or => 'OR';

  @override
  String pleaseEnter(Object field) {
    return 'Please enter your $field';
  }

  @override
  String get validEmail => 'Please enter a valid email';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get phoneInvalid => 'Please enter a valid 8-digit phone number';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get home => 'Home';

  @override
  String get welcome => 'Welcome';

  @override
  String get search => 'Search...';

  @override
  String get seeAll => 'See All';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get notificationsWillAppearHere => 'Notifications will appear here';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get availableOrders => 'Available Orders';

  @override
  String get noOrdersAvailable => 'No orders available right now';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get acceptOrder => 'Accept Order';

  @override
  String get failedToAcceptOrder => 'Failed to accept order';

  @override
  String get markPickedUp => 'Mark as Picked Up';

  @override
  String get startDelivery => 'Start Delivery (On the Way)';

  @override
  String get confirmDelivery => 'Confirm Delivery';

  @override
  String get deliveryCompleted => 'Delivery Completed!';

  @override
  String get deliveringOrder => 'Delivering Order';

  @override
  String get deliveryLocation => 'Delivery Location';

  @override
  String get orderMarkedPickedUp => 'Order marked as picked up!';

  @override
  String get deliveryStarted => 'Delivery started!';

  @override
  String get deliveryConfirmed => 'Delivery confirmed!';

  @override
  String get earnings => 'Earnings';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get deliveriesCompleted => 'deliveries completed';

  @override
  String get recentDeliveries => 'Recent Deliveries';

  @override
  String get noDeliveriesYet => 'No deliveries yet';

  @override
  String get couldNotLoadEarnings => 'Could not load earnings';

  @override
  String get couldNotLoadHistory => 'Could not load history';

  @override
  String get driverProfileNotFound => 'Driver profile not found';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get savedAddresses => 'Saved Addresses';

  @override
  String get noAddressesSaved => 'No addresses saved';

  @override
  String get addressRemoved => 'Address removed';

  @override
  String get setDefault => 'Set Default';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get labelHint => 'Label (e.g., Home, Work)';

  @override
  String get fullAddressLabel => 'Full Address';

  @override
  String get defaultLabel => 'Default';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get noPaymentMethods => 'No payment methods saved';

  @override
  String get addNewCard => 'Add New Card';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date (MM/YY)';

  @override
  String get vehicleInfoSaved => 'Vehicle info saved';

  @override
  String get vehicleInfo => 'Vehicle Info';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get vehicleMakeHint => 'Make (e.g. Yamaha)';

  @override
  String get required => 'Required';

  @override
  String get vehicleModelHint => 'Model (e.g. NMAX)';

  @override
  String get licensePlate => 'License Plate';

  @override
  String get color => 'Color';

  @override
  String get saveVehicleInfo => 'Save Vehicle Info';

  @override
  String get pleaseSignInFirst => 'Please sign in first.';

  @override
  String get supportTicketSent =>
      'Support ticket sent! We will contact you soon.';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get howCanWeHelp => 'How can we help you?';

  @override
  String get fillFormDescription =>
      'Fill out the form below and our team will get back to you within 24 hours.';

  @override
  String get subject => 'Subject';

  @override
  String get pleaseEnterSubject => 'Please enter a subject';

  @override
  String get message => 'Message';

  @override
  String get pleaseEnterMessage => 'Please enter your message';

  @override
  String get submitTicket => 'Submit Ticket';

  @override
  String get profileUpdated => 'Profile updated successfully!';

  @override
  String get failedToUpdateProfile => 'Failed to update profile.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get bio => 'Bio';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get payoutInfoSaved => 'Payout info saved';

  @override
  String get earningsAndStatus => 'Earnings & Status';

  @override
  String get youAreOnline => 'You are Online';

  @override
  String get youAreOffline => 'You are Offline';

  @override
  String get parcelPickupTitle => 'Parcel to collect';

  @override
  String get parcelDeliverTitle => 'Delivering the parcel';

  @override
  String get parcelStepSender => '1. Collect from the sender';

  @override
  String get parcelStepRecipient => '2. Deliver to the recipient';

  @override
  String get parcelSender => 'Sender';

  @override
  String get parcelRecipient => 'Recipient';

  @override
  String get parcelCollected => 'Parcel collected';

  @override
  String get parcelCollectedSnack =>
      'Parcel collected. Now head to the recipient.';

  @override
  String get parcelHandedOver => 'Parcel handed over — Finish';

  @override
  String get parcelCallOnArrival => 'Call the recipient when you arrive.';

  @override
  String get parcelActionFailed =>
      'Could not update the order. Check your connection and try again.';

  @override
  String get myReviews => 'My reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get noReviewsYetHint =>
      'Customer ratings appear here after your deliveries.';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String get bgGuideTitle => 'Get orders with the app closed';

  @override
  String get bgGuideBody =>
      'This phone can stop the app in the background. So the alarm still rings when the app is closed:';

  @override
  String get bgGuideStep1 => 'Turn on “Autostart” for this app.';

  @override
  String get bgGuideStep2 => 'Battery saver: choose “No restrictions”.';

  @override
  String get bgGuideOpen => 'Open settings';

  @override
  String get bgGuideDone => 'Done';

  @override
  String get bgGuideLater => 'Later';

  @override
  String get canReceiveOrders => 'You can receive new orders';

  @override
  String get turnOnToReceive => 'Turn on to receive orders';

  @override
  String get bankPayoutInfo => 'Bank Payout Info';

  @override
  String get payoutsWeekly => 'Payouts are sent weekly to your bank account.';

  @override
  String get accountHolderName => 'Account Holder Name';

  @override
  String get bankName => 'Bank Name';

  @override
  String get ibanRib => 'IBAN / RIB';

  @override
  String get enterValidIban => 'Enter a valid IBAN/RIB';

  @override
  String get savePayoutInfo => 'Save Payout Info';

  @override
  String get account => 'Account';

  @override
  String get earningsAndPayout => 'Earnings & Payout';

  @override
  String get delivery => 'Delivery';

  @override
  String get you => 'You';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get customer => 'Customer';

  @override
  String get deliveryHistory => 'Delivery History';

  @override
  String get completedDeliveriesAppearHere =>
      'Completed deliveries will appear here';

  @override
  String get delivered => 'Delivered';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get locationOff =>
      'Location is off. Turn on Location in your phone settings.';

  @override
  String get locationDeniedSettings =>
      'Location permission denied. Grant it in app settings.';

  @override
  String get driverDashboard => 'Driver Dashboard';

  @override
  String get youHaveActiveDelivery => 'You have an active delivery';

  @override
  String get readyForOrders => 'Ready for orders';

  @override
  String get youreOfflineFlip => 'You\'re offline — flip the switch to start';

  @override
  String get available => 'Available';

  @override
  String get active => 'Active';

  @override
  String get activeDelivery => 'Active Delivery';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get expand => 'Expand';

  @override
  String get ordersWaitingForDriver => 'order(s) waiting for a driver';

  @override
  String get viewAvailableOrders => 'View Available Orders';

  @override
  String get onTheWay => 'On the Way';

  @override
  String get noActiveDelivery => 'No active delivery';

  @override
  String get acceptOrderToStart => 'Accept an order to start delivering';

  @override
  String get browseAvailableOrders => 'Browse Available Orders';

  @override
  String get orders => 'Orders';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountIntro =>
      'Deletion is permanent. You will no longer be able to sign in with this account.';

  @override
  String get deleteAccountDeletedTitle => 'What will be deleted';

  @override
  String get deleteAccountDeletedDevices =>
      'Your notifications and signed-in devices';

  @override
  String get deleteAccountKeptTitle => 'What will be kept';

  @override
  String get deleteAccountKeptWhy =>
      'This information is kept for accounting and in case of a dispute.';

  @override
  String get deleteAccountBlockedTitle => 'Your account cannot be deleted yet';

  @override
  String get deleteAccountContactTeam => 'Contact the Amana team';

  @override
  String get deleteAccountBlockerAdmin =>
      'This is an administrator account: it cannot be deleted from the app.';

  @override
  String deleteAccountBlockerActiveOrders(int count) {
    return 'You have $count order(s) in progress. Wait until they are delivered or cancelled.';
  }

  @override
  String get deleteAccountBlockerOpenDisputes =>
      'A parcel dispute is still open. Wait for the Amana team to close it.';

  @override
  String deleteAccountBlockerDriverOrders(int count) {
    return 'You have $count delivery(ies) in progress. Finish them first.';
  }

  @override
  String get deleteAccountBlockerDriverDisputes =>
      'A parcel dispute involving you is still open. Wait for the Amana team to close it.';

  @override
  String get deleteAccountBlockerDriverPayouts =>
      'Amana still owes you bonuses. Contact the Amana team to settle your account.';

  @override
  String deleteAccountBlockerShopOrders(int count) {
    return 'Your shop has $count order(s) in progress. Complete or cancel them first.';
  }

  @override
  String deleteAccountBlockerWallet(String amount) {
    return '$amount TND remain on your balance. Contact the Amana team to settle your account.';
  }

  @override
  String get deleteAccountBlockerSettlements =>
      'A settlement is pending. Contact the Amana team to settle your account.';

  @override
  String get deleteAccountBlockerUnknown =>
      'Your account cannot be deleted right now. Contact the Amana team.';

  @override
  String get deleteAccountConfirmWord => 'DELETE';

  @override
  String deleteAccountTypeWord(String word) {
    return 'To confirm, type $word';
  }

  @override
  String deleteAccountWordMismatch(String word) {
    return 'Type exactly $word';
  }

  @override
  String get deleteAccountPasswordHint =>
      'For your security, enter your password';

  @override
  String get deleteAccountPasswordLabel => 'Password';

  @override
  String get deleteAccountGoogleHint =>
      'For your security, you will sign in again with this account\'s Google account.';

  @override
  String get deleteAccountSubmit => 'Permanently delete my account';

  @override
  String get deleteAccountErrorWrongPassword => 'Incorrect password.';

  @override
  String get deleteAccountErrorOtherGoogle =>
      'This Google account is not the one linked to this Amana account.';

  @override
  String get deleteAccountErrorReauth =>
      'Your confirmation has expired. Please try again.';

  @override
  String get deleteAccountErrorNoMethod =>
      'This account cannot be confirmed in the app. Contact the Amana team.';

  @override
  String get deleteAccountErrorFailed =>
      'Deletion failed. Try again or contact the Amana team.';

  @override
  String get deleteAccountLoadError =>
      'Could not check your account. Check your connection.';

  @override
  String get deleteAccountRetry => 'Retry';

  @override
  String get deleteAccountDoneTitle => 'Account deleted';

  @override
  String get deleteAccountDoneOk => 'OK';

  @override
  String get deleteAccountDeletedContact =>
      'Your contact details: name, phone, email and photo';

  @override
  String get deleteAccountDeletedBank => 'Your bank details';

  @override
  String get deleteAccountDriverOffline =>
      'You will be removed from the drivers: no more deliveries will be offered to you';

  @override
  String get deleteAccountKeptDeliveries =>
      'Your delivery history and the parcel handover receipts';

  @override
  String get deleteAccountKeptMoney =>
      'Your earnings, settlements and balance history';

  @override
  String get deleteAccountKeptIdentity =>
      'Your identity file and contract, visible only to the Amana team';

  @override
  String get deleteAccountDoneBody =>
      'Your account has been deleted. Thank you for working with Amana.';
}
