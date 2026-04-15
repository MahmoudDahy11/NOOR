import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tally_islamic/features/store/presentation/screen/store_screen.dart';

import '../create_room/domain/entities/room_entity.dart';
import '../create_room/presentation/screens/create_room_sheet.dart';
import '../create_room/presentation/widgets/create_room_type_sheet.dart';
import '../profile/presentation/screen/profile_screen.dart';
import 'presentation/cubit/home_cubit.dart';
import 'presentation/screens/feed_placeholder_screen.dart';
import 'presentation/widgets/home_nav_bar.dart';
import 'presentation/widgets/join_room_sheet.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => HomeCubit(), child: const _HomeView());
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  static const _screens = [
    FeedPlaceholderScreen(),
    StoreScreen(),
    SizedBox.shrink(), // FAB — handled separately
    ProfileScreen(),
    SizedBox.shrink(), // Join — handled as sheet
  ];

  void _onFabTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CreateRoomTypeSheet(
        onSelected: (type) {
          Navigator.pop(context);
          _openCreateRoomSheet(context, type);
        },
      ),
    );
  }

  void _openCreateRoomSheet(BuildContext context, RoomType type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CreateRoomSheet(roomType: type),
    );
  }

  void _onTabTap(BuildContext context, int index) {
    if (index == 4) {
      _openJoinSheet(context);
      return;
    }
    context.read<HomeCubit>().changeTab(index);
  }

  void _openJoinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const JoinRoomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final currentIndex = state is HomeTabChanged ? state.index : 0;

        return Scaffold(
          body: IndexedStack(
            index: currentIndex == 4 ? 0 : currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: HomeNavBar(
            currentIndex: currentIndex,
            onTap: (i) => _onTabTap(context, i),
            onFabTap: () => _onFabTap(context),
          ),
        );
      },
    );
  }
}
