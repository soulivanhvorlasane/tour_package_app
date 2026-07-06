
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/package_provider.dart';
import '../models/tour_package.dart';
import '../widgets/cover_image.dart';
import 'package_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_state_providers.dart';
import '../providers/user_provider.dart';
import '../providers/cover_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final packagesAsyncValue = ref.watch(packagesProvider);
    final allPackages = packagesAsyncValue.value ?? [];
    
    final List<String> categories = ['All', ...allPackages.map((p) => p.category).where((c) => c.isNotEmpty).toSet()];
    final selectedCategoryIndex = ref.watch(selectedCategoryIndexProvider);
    final selectedCategory = selectedCategoryIndex < categories.length ? categories[selectedCategoryIndex] : 'All';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Tour Packages", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7B89), Color(0xFFFF9E7B)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(packagesProvider);
                try {
                  await ref.read(packagesProvider.future);
                } catch (_) {}
              },
              child: CustomScrollView(
                slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1E1E),
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(text: 'Start Your First '),
                              TextSpan(
                                text: 'Journey\n',
                                style: TextStyle(
                                  color: Color(0xFFFF7B89),
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.wavy,
                                ),
                              ),
                              TextSpan(text: 'Enjoy Today.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey.shade400),
                              const SizedBox(width: 12),
                              Text(
                                'Search here',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Categories
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              IconData icon = Icons.category;
                              final cat = categories[index];
                              if (cat == 'All') {
                                icon = Icons.all_inclusive;
                              } else if (cat.toLowerCase().contains('cultural') || cat.toLowerCase().contains('heritage')) {
                                icon = Icons.museum;
                              } else if (cat.toLowerCase().contains('food') || cat.toLowerCase().contains('culinary')) {
                                icon = Icons.restaurant;
                              } else if (cat.toLowerCase().contains('wildlife') || cat.toLowerCase().contains('safari')) {
                                icon = Icons.pets;
                              } else if (cat.toLowerCase().contains('sports') || cat.toLowerCase().contains('activity')) {
                                icon = Icons.sports_soccer;
                              } else if (cat.toLowerCase().contains('yacht') || cat.toLowerCase().contains('boat')) {
                                icon = Icons.sailing;
                              } else if (cat.toLowerCase().contains('beach')) {
                                icon = Icons.beach_access;
                              }
                              
                              return _buildCategoryChip(index, cat, icon);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Best Offers Title
                        const Text(
                          'Best Package Offers For You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                if (packagesAsyncValue.hasValue)
                  Builder(
                    builder: (context) {
                      final packages = packagesAsyncValue.value!;
                      final filteredPackages = selectedCategory == 'All' 
                          ? packages 
                          : packages.where((p) => p.category == selectedCategory).toList();

                      if (filteredPackages.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text('No offers right now.')),
                        );
                      }
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 100), // padding for bottom nav
                          child: SizedBox(
                            height: 540, // Fixed height for horizontal cards
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(left: 24, right: 8),
                              itemCount: filteredPackages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.85, // Width relative to screen
                                    child: PackageCard(package: filteredPackages[index]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else if (packagesAsyncValue.hasError)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Can not get data from API',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            ), // Closes RefreshIndicator
          ), // Closes SafeArea
          
          // Floating Bottom Nav
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, true),
                  _buildNavItem(Icons.favorite_border, false),
                  _buildNavItem(Icons.calendar_today_outlined, false),
                  _buildUserNavItem(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int index, String label, IconData icon) {
    final selectedCategoryIndex = ref.watch(selectedCategoryIndexProvider);
    final isSelected = selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryIndexProvider.notifier).set(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
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
    );
  }

  Widget _buildUserNavItem() {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final userProfileAsync = ref.watch(userProfileProvider);

    Widget userIcon = Icon(
      Icons.person_outline,
      color: isLoggedIn ? Colors.black : Colors.grey.shade500,
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            userIcon,
            if (!isLoggedIn)
              const Text(
                'login',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
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
                    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Register page not implemented yet')));
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

class PackageCard extends StatelessWidget {
  final TourPackage package;

  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            child: CoverImage(
              imageUrl: package.imageUrl,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          
          // Card Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  package.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4A4A4A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Price Row
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${package.price.toStringAsFixed(1)} per person',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                

                
                // Status Row
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF64B5F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.info, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${package.availabilityStatus}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageDetailScreen(package: package),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03A9F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text('More detail & Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
