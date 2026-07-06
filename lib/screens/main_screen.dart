import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/ui_state_providers.dart';
import 'welcome_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavIndex = ref.watch(bottomNavIndexProvider);

    // List of screens for the IndexedStack
    final screens = [
      const WelcomeScreen(),
      const Center(child: Text('Favorites (Coming Soon)')),
      const Center(child: Text('Calendar (Coming Soon)')),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          IndexedStack(
            index: bottomNavIndex,
            children: screens,
          ),
          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, ref, 0, Icons.home),
                  _buildNavItem(context, ref, 1, Icons.favorite_border),
                  _buildNavItem(context, ref, 2, Icons.calendar_today_outlined),
                  _buildUserNavItem(context, ref, 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, int index, IconData icon) {
    final bottomNavIndex = ref.watch(bottomNavIndexProvider);
    final isSelected = bottomNavIndex == index;

    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).set(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade500,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildUserNavItem(BuildContext context, WidgetRef ref, int index) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final userProfileAsync = ref.watch(userProfileProvider);
    final bottomNavIndex = ref.watch(bottomNavIndexProvider);
    final isSelected = bottomNavIndex == index;

    Widget userIcon = Icon(
      Icons.person_outline,
      color: isSelected ? Colors.white : (isLoggedIn ? Colors.black : Colors.grey.shade500),
      size: 24,
    );

    if (isLoggedIn) {
      userProfileAsync.whenData((profile) {
        if (profile != null && profile.profileImageProvider != null) {
          userIcon = CircleAvatar(
            radius: 12,
            backgroundImage: profile.profileImageProvider,
            backgroundColor: Colors.grey.shade200,
          );
        }
      });
    }

    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          _showLoginBottomSheet(context);
        } else {
          ref.read(bottomNavIndexProvider.notifier).set(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12), // Match the padding of other icons
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: userIcon,
      ),
    );
  }

  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Tour App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7B89), Color(0xFFFF9E7B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFFF7B89), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF7B89))),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
