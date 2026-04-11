part of 'add_card_cubit.dart';

@immutable
sealed class AddCardState {
  const AddCardState();
}

final class AddCardInitial extends AddCardState {}

final class AddCardCreatingCustomer extends AddCardState {}

final class AddCardReadyToSubmit extends AddCardState {
  final String customerId;
  const AddCardReadyToSubmit(this.customerId);
}

final class AddCardSaving extends AddCardState {}

final class AddCardSuccess extends AddCardState {}

final class AddCardFailure extends AddCardState {
  final String message;
  const AddCardFailure(this.message);
}
