class CreateRoomParams {
  final String name;
  final String type; // 'free' | 'paid'
  final String dhikr;
  final int goal;
  final bool isPublic;
  final double durationHours; // 0.5 for free, 1-24 for paid
  final int ticketsRequired; // 0 for free

  const CreateRoomParams({
    required this.name,
    required this.type,
    required this.dhikr,
    required this.goal,
    required this.isPublic,
    required this.durationHours,
    required this.ticketsRequired,
  });

  bool get isFree => type == 'free';
  bool get isPaid => type == 'paid';

  /// Tickets scale with duration:
  /// 1h=1, 2h=2 ... 24h=24
  static int calculateTickets(double hours) {
    if (hours <= 0.5) return 0; // free
    return hours.ceil();
  }
}
