import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_package.dart';
import '../providers/package_provider.dart';
import '../widgets/cover_image.dart';

class PackageDetailScreen extends ConsumerWidget {
  final TourPackage package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Primary gradient for UI elements (pink to orange)
    const LinearGradient primaryGradient = LinearGradient(
      colors: [Color(0xFFFF7B89), Color(0xFFFF9E7B)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    // Watch the detail provider for this specific package
    final detailAsyncValue = ref.watch(packageDetailProvider(package.id));
    
    // Fall back to the initially passed package while loading
    final displayPackage = detailAsyncValue.value ?? package;

    // Helper to quickly strip HTML tags from description
    String stripHtml(String htmlString) {
      RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      return htmlString.replaceAll(exp, '').trim();
    }

    final cleanDescription = stripHtml(displayPackage.description);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Trip&Travel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.sort, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title and Country
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayPackage.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayPackage.country,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Stars
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: index < displayPackage.rating.round()
                              ? const Color(0xFFFFD700)
                              : Colors.grey.shade300,
                        );
                      }),
                    ),
                  ],
                ),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 24),

            // Image Collage (Masonry Style)
            SizedBox(
              height: 260,
              child: Row(
                children: [
                  // Left Column (2 images)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildCollageImage(displayPackage.galleryImages.isNotEmpty ? displayPackage.galleryImages[0] : displayPackage.imageUrl),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 5,
                          child: _buildCollageImage(displayPackage.galleryImages.length > 1 ? displayPackage.galleryImages[1] : displayPackage.imageUrl),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Center Column (1 tall image)
                  Expanded(
                    child: _buildCollageImage(displayPackage.galleryImages.length > 2 ? displayPackage.galleryImages[2] : displayPackage.imageUrl),
                  ),
                  const SizedBox(width: 8),
                  // Right Column (2 images)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildCollageImage(displayPackage.galleryImages.length > 3 ? displayPackage.galleryImages[3] : displayPackage.imageUrl),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 4,
                          child: _buildCollageImage(displayPackage.galleryImages.length > 4 ? displayPackage.galleryImages[4] : displayPackage.imageUrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Book Now Button
            Center(
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7B89).withAlpha(76),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      // Booking action
                    },
                    child: Center(
                      child: detailAsyncValue.isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Text(
                            'Book now - \$${displayPackage.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // About the island section
            const Text(
              'About the island',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cleanDescription,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'More',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gallery section
            const Text(
              'Gallery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayPackage.galleryImages.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(displayPackage.galleryImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCollageImage(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CoverImage(
        imageUrl: url,
        fit: BoxFit.cover,
      ),
    );
  }
}
