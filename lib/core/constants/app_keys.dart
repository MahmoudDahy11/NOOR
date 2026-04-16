class AppKeys {
  AppKeys._();

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String roomsCollection = 'rooms';
  static const String ticketPackagesCollection = 'ticket_packages';
  static const String userTicketsCollection = 'user_tickets';
  static const String otpsCollection = 'otps';

  // User Keys
  static const String uId = 'uid';
  static const String userId = 'userId';
  static const String email = 'email';
  static const String name = 'name';
  static const String displayName = 'displayName';
  static const String avatarAsset = 'avatarAsset';
  static const String bio = 'bio';
  static const String interests = 'interests';
  static const String photoUrl = 'photoUrl';
  static const String ticketBalance = 'ticket_balance';
  static const String stripeCustomerId = 'stripeCustomerId';
  static const String hasCard = 'hasCard';
  static const String defaultPaymentMethodId = 'defaultPaymentMethodId';
  static const String userCreatedAt = 'createdAt';
  static const String userCardAddedAt = 'cardAddedAt';
  static const String userStatsRoomsCreated = 'roomsCreated';
  static const String userStatsRoomsJoined = 'roomsJoined';
  static const String userStatsTotalCounts = 'totalCounts';

  // Room Keys
  static const String roomId = 'id';
  static const String roomName = 'name';
  static const String roomPhoto = 'photo';
  static const String roomType = 'type';
  static const String roomDhikr = 'dhikr';
  static const String roomGoal = 'goal';
  static const String roomCurrentProgress = 'currentProgress';
  static const String roomCreator = 'creator';
  static const String roomCreatorId = 'creator.id';
  static const String roomCreatedAt = 'createdAt';
  static const String roomExpiresAt = 'expiresAt';
  static const String roomStartedAt = 'startedAt';
  static const String roomStatus = 'status';
  static const String roomIsPublic = 'isPublic';
  static const String roomParticipants = 'participants';
  static const String roomDurationHours = 'durationHours';
  static const String roomCount = 'c'; // RTDB counter

  // Ticket & Package Keys
  static const String packageTicketCount = 'ticketCount';
  static const String packagePrice = 'price';
  static const String packageCurrency = 'currency';
  static const String packageIsPopular = 'isPopular';
  static const String userTicketPackageId = 'packageId';
  static const String userTicketPricePaid = 'pricePaid';
  static const String userTicketStripePaymentIntentId = 'stripePaymentIntentId';
  static const String userTicketPurchasedAt = 'purchasedAt';
  static const String userTicketRefunded = 'refunded';

  // Room Detailed Keys
  static const String roomCreatorName = 'creator.name';
  static const String roomCreatorAvatar = 'creator.avatar';
  static const String roomDurationDays = 'durationDays'; // if any
  static const String typeFree = 'free';
  static const String statusPending = 'pending';
  static const String statusActive = 'active';
  static const String createdAt = 'createdAt'; // Generic fallback if needed

  // Stripe & Payment API Keys
  static const String stripeEmail = 'stripeEmail';
  static const String stripeDefaultPaymentMethod = 'default_payment_method';
  static const String stripeInvoiceSettings = 'invoice_settings';
  static const String stripeCustomer = 'customer';
  static const String stripeMetadataFirebaseUid = 'firebaseUid';
  static const String stripeClientSecret = 'client_secret';
  static const String stripeId = 'id';
  static const String stripeSecret = 'secret';
  static const String stripeAmount = 'amount';
  static const String stripeCurrency = 'currency';
  static const String stripePaymentMethodTypes = 'payment_method_types[]';
  static const String stripeSetupFutureUsage = 'setup_future_usage';

  // OTP Keys
  static const String otpValue = 'otp';
  static const String otpCreatedAt = 'createdAt';
  static const String otpExpiresAt = 'expiresAt';
  static const String otpCanResendAt = 'canResendAt';
  static const String otpVerified = 'verified';
  static const String otpVerifiedAt = 'verifiedAt';

  // Api Endpoints (Stripe)
  static const String stripeBaseUrl = 'https://api.stripe.com/v1';
}
