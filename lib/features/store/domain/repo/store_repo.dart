import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../entity/ticket_package_entity.dart';



abstract class StoreRepo {
  Future<Either<CustomFailure, List<TicketPackageEntity>>> getPackages();

  Future<Either<CustomFailure, void>> purchasePackage({
    required TicketPackageEntity package,
  });

  Future<Either<CustomFailure, int>> getTicketBalance();

  Future<Either<CustomFailure, void>> refundTickets({
    required String userTicketId,
    required int ticketCount,
  });
}
