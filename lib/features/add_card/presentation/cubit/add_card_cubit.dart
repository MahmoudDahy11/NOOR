import 'package:bloc/bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:meta/meta.dart';

import '../../domain/repo/add_card_repo.dart';


part 'add_card_state.dart';

class AddCardCubit extends Cubit<AddCardState> {
  final AddCardRepo _repo;

  AddCardCubit({required AddCardRepo repo})
      : _repo = repo,
        super(AddCardInitial());

  /// Step 1 — called on screen init:
  /// create or fetch Stripe customer
  Future<void> initCustomer() async {
    emit(AddCardCreatingCustomer());

    final result = await _repo.createCustomerAndSave();

    result.fold(
      (failure) => emit(AddCardFailure(failure.errMessage)),
      (customer) => emit(AddCardReadyToSubmit(customer.customerId)),
    );
  }

  /// Step 2 — called when user taps "Save Card":
  /// confirm setup intent then attach card
  Future<void> saveCard({required String customerId}) async {
    emit(AddCardSaving());

    try {
      // Confirm card setup using Stripe SDK
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final result = await _repo.attachCard(
        customerId: customerId,
        paymentMethodId: paymentMethod.id,
      );

      result.fold(
        (failure) => emit(AddCardFailure(failure.errMessage)),
        (_) => emit(AddCardSuccess()),
      );
    } on StripeException catch (e) {
      emit(AddCardFailure(
        e.error.localizedMessage ?? 'Card setup failed.',
      ));
    } catch (e) {
      emit(AddCardFailure(e.toString()));
    }
  }
}
