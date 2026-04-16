import 'package:flutter/material.dart';

import '../../domain/entities/profile_entity.dart';
import 'interests_section.dart';
import 'pending_rooms_section.dart';
import 'profile_header.dart';
import 'profile_menu.dart';
import 'profile_stats.dart';
import 'ticket_inventory_placeholder.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.profile,
    required this.isStartingRoom,
    required this.onStartRoom,
    required this.onEditProfile,
    required this.onOpenSettings,
    required this.onSignOut,
  });

  final ProfileEntity profile;
  final bool isStartingRoom;
  final ValueChanged<String> onStartRoom;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(
              child: ProfileHeader(
                avatar: profile.user.avatarAsset,
                name: profile.user.displayName,
                bio: profile.user.bio,
              ),
            ),
            const SizedBox(height: 30),
            ProfileStats(
              joined: profile.roomsJoined,
              counts: profile.totalCounts,
              created: profile.roomsCreated,
            ),
            const SizedBox(height: 30),
            const TicketInventoryPlaceholder(),
            const SizedBox(height: 30),
            PendingRoomsSection(
              rooms: profile.pendingRooms,
              isLoading: isStartingRoom,
              onStart: onStartRoom,
            ),
            const SizedBox(height: 30),
            InterestsSection(interests: profile.user.interests),
            const SizedBox(height: 30),
            ProfileMenu(
              onEditProfile: onEditProfile,
              onSettings: onOpenSettings,
              onSignOut: onSignOut,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
