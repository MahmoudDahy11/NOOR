part of 'home_cubit.dart';

@immutable
sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {}

final class HomeTabChanged extends HomeState {
  final int index;
  const HomeTabChanged(this.index);
}
