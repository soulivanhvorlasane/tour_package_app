
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/package_provider.dart';
import '../models/tour_package.dart';
import '../widgets/cover_image.dart';
import 'package_detail_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _selectedCategoryIndex = 1;

  @override
  Widget build(BuildContext context) {
    final packagesAsyncValue = ref.watch(packagesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
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
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildCategoryChip(0, 'Yachts', Icons.sailing),
                              const SizedBox(width: 12),
                              _buildCategoryChip(1, 'Jetskis', Icons.water_drop),
                              const SizedBox(width: 12),
                              _buildCategoryChip(2, 'Beach Activities', Icons.beach_access),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Best Offers Title
                        const Text(
                          'Best Offers For You',
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
                
                // Package List
                packagesAsyncValue.when(
                  data: (packages) {
                    if (packages.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text('No offers right now.')),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100), // padding for bottom nav
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: PackageCard(package: packages[index]),
                            );
                          },
                          childCount: packages.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Can not get data from API',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
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
                  _buildNavItem(Icons.person_outline, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int index, String label, IconData icon) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
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
                
                // Dates Row
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Color(0xFF9FA8DA), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${package.startDate} - ${package.endDate}',
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
