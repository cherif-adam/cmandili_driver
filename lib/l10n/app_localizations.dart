import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @pwdIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password, then choose a new one. You will stay signed in on this device.'**
  String get pwdIntro;

  /// No description provided for @pwdCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get pwdCurrent;

  /// No description provided for @pwdNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get pwdNew;

  /// No description provided for @pwdConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get pwdConfirm;

  /// No description provided for @pwdErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get pwdErrorRequired;

  /// No description provided for @pwdErrorWrongCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password is wrong'**
  String get pwdErrorWrongCurrent;

  /// No description provided for @pwdErrorTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters'**
  String pwdErrorTooShort(int min);

  /// No description provided for @pwdErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match'**
  String get pwdErrorMismatch;

  /// No description provided for @pwdErrorSameAsOld.
  ///
  /// In en, this message translates to:
  /// **'The new password is the same as the old one'**
  String get pwdErrorSameAsOld;

  /// No description provided for @pwdErrorReauthNeeded.
  ///
  /// In en, this message translates to:
  /// **'For security, confirm your identity again before changing your password'**
  String get pwdErrorReauthNeeded;

  /// No description provided for @pwdErrorNoSession.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get pwdErrorNoSession;

  /// No description provided for @pwdErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change the password. Try again.'**
  String get pwdErrorFailed;

  /// No description provided for @pwdChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get pwdChangedTitle;

  /// No description provided for @pwdChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Other devices are still signed in with the old session. Sign them out?'**
  String get pwdChangedBody;

  /// No description provided for @pwdKeepOtherDevices.
  ///
  /// In en, this message translates to:
  /// **'Keep them'**
  String get pwdKeepOtherDevices;

  /// No description provided for @pwdSignOutOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign out other devices'**
  String get pwdSignOutOthers;

  /// No description provided for @pwdOtherDevicesSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Other devices have been signed out'**
  String get pwdOtherDevicesSignedOut;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Amana'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter your {field}'**
  String pleaseEnter(Object field);

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLength;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 8-digit phone number'**
  String get phoneInvalid;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Notifications will appear here'**
  String get notificationsWillAppearHere;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @availableOrders.
  ///
  /// In en, this message translates to:
  /// **'Available Orders'**
  String get availableOrders;

  /// No description provided for @noOrdersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No orders available right now'**
  String get noOrdersAvailable;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// No description provided for @acceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get acceptOrder;

  /// No description provided for @failedToAcceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept order'**
  String get failedToAcceptOrder;

  /// No description provided for @markPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Mark as Picked Up'**
  String get markPickedUp;

  /// No description provided for @startDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start Delivery (On the Way)'**
  String get startDelivery;

  /// No description provided for @confirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery'**
  String get confirmDelivery;

  /// No description provided for @deliveryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Delivery Completed!'**
  String get deliveryCompleted;

  /// No description provided for @deliveringOrder.
  ///
  /// In en, this message translates to:
  /// **'Delivering Order'**
  String get deliveringOrder;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @orderMarkedPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Order marked as picked up!'**
  String get orderMarkedPickedUp;

  /// No description provided for @deliveryStarted.
  ///
  /// In en, this message translates to:
  /// **'Delivery started!'**
  String get deliveryStarted;

  /// No description provided for @deliveryConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Delivery confirmed!'**
  String get deliveryConfirmed;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @deliveriesCompleted.
  ///
  /// In en, this message translates to:
  /// **'deliveries completed'**
  String get deliveriesCompleted;

  /// No description provided for @recentDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Recent Deliveries'**
  String get recentDeliveries;

  /// No description provided for @noDeliveriesYet.
  ///
  /// In en, this message translates to:
  /// **'No deliveries yet'**
  String get noDeliveriesYet;

  /// No description provided for @couldNotLoadEarnings.
  ///
  /// In en, this message translates to:
  /// **'Could not load earnings'**
  String get couldNotLoadEarnings;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get couldNotLoadHistory;

  /// No description provided for @driverProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Driver profile not found'**
  String get driverProfileNotFound;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddresses;

  /// No description provided for @noAddressesSaved.
  ///
  /// In en, this message translates to:
  /// **'No addresses saved'**
  String get noAddressesSaved;

  /// No description provided for @addressRemoved.
  ///
  /// In en, this message translates to:
  /// **'Address removed'**
  String get addressRemoved;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set Default'**
  String get setDefault;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @labelHint.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g., Home, Work)'**
  String get labelHint;

  /// No description provided for @fullAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddressLabel;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods saved'**
  String get noPaymentMethods;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date (MM/YY)'**
  String get expiryDate;

  /// No description provided for @vehicleInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Vehicle info saved'**
  String get vehicleInfoSaved;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get vehicleInfo;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @vehicleMakeHint.
  ///
  /// In en, this message translates to:
  /// **'Make (e.g. Yamaha)'**
  String get vehicleMakeHint;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @vehicleModelHint.
  ///
  /// In en, this message translates to:
  /// **'Model (e.g. NMAX)'**
  String get vehicleModelHint;

  /// No description provided for @licensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlate;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @saveVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Save Vehicle Info'**
  String get saveVehicleInfo;

  /// No description provided for @pleaseSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first.'**
  String get pleaseSignInFirst;

  /// No description provided for @supportTicketSent.
  ///
  /// In en, this message translates to:
  /// **'Support ticket sent! We will contact you soon.'**
  String get supportTicketSent;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelp;

  /// No description provided for @fillFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Fill out the form below and our team will get back to you within 24 hours.'**
  String get fillFormDescription;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @pleaseEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get pleaseEnterSubject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @pleaseEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message'**
  String get pleaseEnterMessage;

  /// No description provided for @submitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicket;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get failedToUpdateProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @payoutInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Payout info saved'**
  String get payoutInfoSaved;

  /// No description provided for @earningsAndStatus.
  ///
  /// In en, this message translates to:
  /// **'Earnings & Status'**
  String get earningsAndStatus;

  /// No description provided for @youAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You are Online'**
  String get youAreOnline;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are Offline'**
  String get youAreOffline;

  /// No description provided for @parcelPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Parcel to collect'**
  String get parcelPickupTitle;

  /// No description provided for @parcelDeliverTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivering the parcel'**
  String get parcelDeliverTitle;

  /// No description provided for @parcelStepSender.
  ///
  /// In en, this message translates to:
  /// **'1. Collect from the sender'**
  String get parcelStepSender;

  /// No description provided for @parcelStepRecipient.
  ///
  /// In en, this message translates to:
  /// **'2. Deliver to the recipient'**
  String get parcelStepRecipient;

  /// No description provided for @parcelSender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get parcelSender;

  /// No description provided for @parcelRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get parcelRecipient;

  /// No description provided for @parcelCollected.
  ///
  /// In en, this message translates to:
  /// **'Parcel collected'**
  String get parcelCollected;

  /// No description provided for @parcelCollectedSnack.
  ///
  /// In en, this message translates to:
  /// **'Parcel collected. Now head to the recipient.'**
  String get parcelCollectedSnack;

  /// No description provided for @parcelHandedOver.
  ///
  /// In en, this message translates to:
  /// **'Parcel handed over — Finish'**
  String get parcelHandedOver;

  /// No description provided for @parcelCallOnArrival.
  ///
  /// In en, this message translates to:
  /// **'Call the recipient when you arrive.'**
  String get parcelCallOnArrival;

  /// No description provided for @parcelActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the order. Check your connection and try again.'**
  String get parcelActionFailed;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My reviews'**
  String get myReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @noReviewsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Customer ratings appear here after your deliveries.'**
  String get noReviewsYetHint;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews} =1{1 review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// No description provided for @bgGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Get orders with the app closed'**
  String get bgGuideTitle;

  /// No description provided for @bgGuideBody.
  ///
  /// In en, this message translates to:
  /// **'This phone can stop the app in the background. So the alarm still rings when the app is closed:'**
  String get bgGuideBody;

  /// No description provided for @bgGuideStep1.
  ///
  /// In en, this message translates to:
  /// **'Turn on “Autostart” for this app.'**
  String get bgGuideStep1;

  /// No description provided for @bgGuideStep2.
  ///
  /// In en, this message translates to:
  /// **'Battery saver: choose “No restrictions”.'**
  String get bgGuideStep2;

  /// No description provided for @bgGuideOpen.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get bgGuideOpen;

  /// No description provided for @bgGuideDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get bgGuideDone;

  /// No description provided for @bgGuideLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get bgGuideLater;

  /// No description provided for @canReceiveOrders.
  ///
  /// In en, this message translates to:
  /// **'You can receive new orders'**
  String get canReceiveOrders;

  /// No description provided for @turnOnToReceive.
  ///
  /// In en, this message translates to:
  /// **'Turn on to receive orders'**
  String get turnOnToReceive;

  /// No description provided for @bankPayoutInfo.
  ///
  /// In en, this message translates to:
  /// **'Bank Payout Info'**
  String get bankPayoutInfo;

  /// No description provided for @payoutsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Payouts are sent weekly to your bank account.'**
  String get payoutsWeekly;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @ibanRib.
  ///
  /// In en, this message translates to:
  /// **'IBAN / RIB'**
  String get ibanRib;

  /// No description provided for @enterValidIban.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid IBAN/RIB'**
  String get enterValidIban;

  /// No description provided for @savePayoutInfo.
  ///
  /// In en, this message translates to:
  /// **'Save Payout Info'**
  String get savePayoutInfo;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @earningsAndPayout.
  ///
  /// In en, this message translates to:
  /// **'Earnings & Payout'**
  String get earningsAndPayout;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @deliveryHistory.
  ///
  /// In en, this message translates to:
  /// **'Delivery History'**
  String get deliveryHistory;

  /// No description provided for @completedDeliveriesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Completed deliveries will appear here'**
  String get completedDeliveriesAppearHere;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Location is off. Turn on Location in your phone settings.'**
  String get locationOff;

  /// No description provided for @locationDeniedSettings.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Grant it in app settings.'**
  String get locationDeniedSettings;

  /// No description provided for @driverDashboard.
  ///
  /// In en, this message translates to:
  /// **'Driver Dashboard'**
  String get driverDashboard;

  /// No description provided for @youHaveActiveDelivery.
  ///
  /// In en, this message translates to:
  /// **'You have an active delivery'**
  String get youHaveActiveDelivery;

  /// No description provided for @readyForOrders.
  ///
  /// In en, this message translates to:
  /// **'Ready for orders'**
  String get readyForOrders;

  /// No description provided for @youreOfflineFlip.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — flip the switch to start'**
  String get youreOfflineFlip;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Active Delivery'**
  String get activeDelivery;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @ordersWaitingForDriver.
  ///
  /// In en, this message translates to:
  /// **'order(s) waiting for a driver'**
  String get ordersWaitingForDriver;

  /// No description provided for @viewAvailableOrders.
  ///
  /// In en, this message translates to:
  /// **'View Available Orders'**
  String get viewAvailableOrders;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get onTheWay;

  /// No description provided for @noActiveDelivery.
  ///
  /// In en, this message translates to:
  /// **'No active delivery'**
  String get noActiveDelivery;

  /// No description provided for @acceptOrderToStart.
  ///
  /// In en, this message translates to:
  /// **'Accept an order to start delivering'**
  String get acceptOrderToStart;

  /// No description provided for @browseAvailableOrders.
  ///
  /// In en, this message translates to:
  /// **'Browse Available Orders'**
  String get browseAvailableOrders;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'Deletion is permanent. You will no longer be able to sign in with this account.'**
  String get deleteAccountIntro;

  /// No description provided for @deleteAccountDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'What will be deleted'**
  String get deleteAccountDeletedTitle;

  /// No description provided for @deleteAccountDeletedDevices.
  ///
  /// In en, this message translates to:
  /// **'Your notifications and signed-in devices'**
  String get deleteAccountDeletedDevices;

  /// No description provided for @deleteAccountKeptTitle.
  ///
  /// In en, this message translates to:
  /// **'What will be kept'**
  String get deleteAccountKeptTitle;

  /// No description provided for @deleteAccountKeptWhy.
  ///
  /// In en, this message translates to:
  /// **'This information is kept for accounting and in case of a dispute.'**
  String get deleteAccountKeptWhy;

  /// No description provided for @deleteAccountBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account cannot be deleted yet'**
  String get deleteAccountBlockedTitle;

  /// No description provided for @deleteAccountContactTeam.
  ///
  /// In en, this message translates to:
  /// **'Contact the Amana team'**
  String get deleteAccountContactTeam;

  /// No description provided for @deleteAccountBlockerAdmin.
  ///
  /// In en, this message translates to:
  /// **'This is an administrator account: it cannot be deleted from the app.'**
  String get deleteAccountBlockerAdmin;

  /// No description provided for @deleteAccountBlockerActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'You have {count} order(s) in progress. Wait until they are delivered or cancelled.'**
  String deleteAccountBlockerActiveOrders(int count);

  /// No description provided for @deleteAccountBlockerOpenDisputes.
  ///
  /// In en, this message translates to:
  /// **'A parcel dispute is still open. Wait for the Amana team to close it.'**
  String get deleteAccountBlockerOpenDisputes;

  /// No description provided for @deleteAccountBlockerDriverOrders.
  ///
  /// In en, this message translates to:
  /// **'You have {count} delivery(ies) in progress. Finish them first.'**
  String deleteAccountBlockerDriverOrders(int count);

  /// No description provided for @deleteAccountBlockerDriverDisputes.
  ///
  /// In en, this message translates to:
  /// **'A parcel dispute involving you is still open. Wait for the Amana team to close it.'**
  String get deleteAccountBlockerDriverDisputes;

  /// No description provided for @deleteAccountBlockerDriverPayouts.
  ///
  /// In en, this message translates to:
  /// **'Amana still owes you bonuses. Contact the Amana team to settle your account.'**
  String get deleteAccountBlockerDriverPayouts;

  /// No description provided for @deleteAccountBlockerShopOrders.
  ///
  /// In en, this message translates to:
  /// **'Your shop has {count} order(s) in progress. Complete or cancel them first.'**
  String deleteAccountBlockerShopOrders(int count);

  /// No description provided for @deleteAccountBlockerWallet.
  ///
  /// In en, this message translates to:
  /// **'{amount} TND remain on your balance. Contact the Amana team to settle your account.'**
  String deleteAccountBlockerWallet(String amount);

  /// No description provided for @deleteAccountBlockerSettlements.
  ///
  /// In en, this message translates to:
  /// **'A settlement is pending. Contact the Amana team to settle your account.'**
  String get deleteAccountBlockerSettlements;

  /// No description provided for @deleteAccountBlockerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Your account cannot be deleted right now. Contact the Amana team.'**
  String get deleteAccountBlockerUnknown;

  /// No description provided for @deleteAccountConfirmWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteAccountConfirmWord;

  /// No description provided for @deleteAccountTypeWord.
  ///
  /// In en, this message translates to:
  /// **'To confirm, type {word}'**
  String deleteAccountTypeWord(String word);

  /// No description provided for @deleteAccountWordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Type exactly {word}'**
  String deleteAccountWordMismatch(String word);

  /// No description provided for @deleteAccountPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your password'**
  String get deleteAccountPasswordHint;

  /// No description provided for @deleteAccountPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get deleteAccountPasswordLabel;

  /// No description provided for @deleteAccountGoogleHint.
  ///
  /// In en, this message translates to:
  /// **'For your security, you will sign in again with this account\'s Google account.'**
  String get deleteAccountGoogleHint;

  /// No description provided for @deleteAccountSubmit.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete my account'**
  String get deleteAccountSubmit;

  /// No description provided for @deleteAccountErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get deleteAccountErrorWrongPassword;

  /// No description provided for @deleteAccountErrorOtherGoogle.
  ///
  /// In en, this message translates to:
  /// **'This Google account is not the one linked to this Amana account.'**
  String get deleteAccountErrorOtherGoogle;

  /// No description provided for @deleteAccountErrorReauth.
  ///
  /// In en, this message translates to:
  /// **'Your confirmation has expired. Please try again.'**
  String get deleteAccountErrorReauth;

  /// No description provided for @deleteAccountErrorNoMethod.
  ///
  /// In en, this message translates to:
  /// **'This account cannot be confirmed in the app. Contact the Amana team.'**
  String get deleteAccountErrorNoMethod;

  /// No description provided for @deleteAccountErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed. Try again or contact the Amana team.'**
  String get deleteAccountErrorFailed;

  /// No description provided for @deleteAccountLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not check your account. Check your connection.'**
  String get deleteAccountLoadError;

  /// No description provided for @deleteAccountRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get deleteAccountRetry;

  /// No description provided for @deleteAccountDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get deleteAccountDoneTitle;

  /// No description provided for @deleteAccountDoneOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get deleteAccountDoneOk;

  /// No description provided for @deleteAccountDeletedContact.
  ///
  /// In en, this message translates to:
  /// **'Your contact details: name, phone, email and photo'**
  String get deleteAccountDeletedContact;

  /// No description provided for @deleteAccountDeletedBank.
  ///
  /// In en, this message translates to:
  /// **'Your bank details'**
  String get deleteAccountDeletedBank;

  /// No description provided for @deleteAccountDriverOffline.
  ///
  /// In en, this message translates to:
  /// **'You will be removed from the drivers: no more deliveries will be offered to you'**
  String get deleteAccountDriverOffline;

  /// No description provided for @deleteAccountKeptDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Your delivery history, for accounting: dates, status and amounts, without your positions'**
  String get deleteAccountKeptDeliveries;

  /// No description provided for @deleteAccountKeptMoney.
  ///
  /// In en, this message translates to:
  /// **'Your earnings, settlements and balance history'**
  String get deleteAccountKeptMoney;

  /// No description provided for @deleteAccountKeptIdentity.
  ///
  /// In en, this message translates to:
  /// **'Your identity file and contract, visible only to the Amana team, for 5 years after your last delivery, then they are erased'**
  String get deleteAccountKeptIdentity;

  /// No description provided for @deleteAccountDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted. Thank you for working with Amana.'**
  String get deleteAccountDoneBody;

  /// No description provided for @deleteAccountDeletedVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle and your GPS positions'**
  String get deleteAccountDeletedVehicle;

  /// No description provided for @deleteAccountKeptColisDriver.
  ///
  /// In en, this message translates to:
  /// **'Your name, plate and ID on the receipts of delivered parcels, for 30 days after your last delivery, then they are erased'**
  String get deleteAccountKeptColisDriver;

  /// No description provided for @myContract.
  ///
  /// In en, this message translates to:
  /// **'My contract'**
  String get myContract;

  /// No description provided for @contractNone.
  ///
  /// In en, this message translates to:
  /// **'No contract yet. The Amana team will send it to you here.'**
  String get contractNone;

  /// No description provided for @contractStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Your contract is ready. Sign it, have your signature legalized at the municipality (baladiya), then send a photo of it.'**
  String get contractStatusSent;

  /// No description provided for @contractStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Photo sent. The Amana team is checking your contract.'**
  String get contractStatusSubmitted;

  /// No description provided for @contractStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Your contract is approved.'**
  String get contractStatusApproved;

  /// No description provided for @contractStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Your contract was refused. Please send a new photo.'**
  String get contractStatusRejected;

  /// No description provided for @contractReason.
  ///
  /// In en, this message translates to:
  /// **'Reason:'**
  String get contractReason;

  /// No description provided for @contractStep1.
  ///
  /// In en, this message translates to:
  /// **'Download the contract.'**
  String get contractStep1;

  /// No description provided for @contractStep2.
  ///
  /// In en, this message translates to:
  /// **'Print it and sign it.'**
  String get contractStep2;

  /// No description provided for @contractStep3.
  ///
  /// In en, this message translates to:
  /// **'Have your signature legalized at the municipality (baladiya).'**
  String get contractStep3;

  /// No description provided for @contractStep4.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of the signed and stamped contract and send it.'**
  String get contractStep4;

  /// No description provided for @contractDownload.
  ///
  /// In en, this message translates to:
  /// **'Download the contract'**
  String get contractDownload;

  /// No description provided for @contractSendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send the photo of the signed contract'**
  String get contractSendPhoto;

  /// No description provided for @contractResendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send another photo'**
  String get contractResendPhoto;

  /// No description provided for @contractTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get contractTakePhoto;

  /// No description provided for @contractChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get contractChooseGallery;

  /// No description provided for @contractSent.
  ///
  /// In en, this message translates to:
  /// **'Photo sent to the Amana team.'**
  String get contractSent;

  /// No description provided for @contractSendFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo couldn\'t be sent. Try again.'**
  String get contractSendFailed;

  /// No description provided for @contractDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The contract couldn\'t be opened. Try again.'**
  String get contractDownloadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
