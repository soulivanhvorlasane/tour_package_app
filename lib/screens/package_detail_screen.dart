import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/tour_package.dart';
import '../providers/package_provider.dart';
import '../providers/ui_state_providers.dart';
import '../widgets/cover_image.dart';

class PackageDetailScreen extends ConsumerStatefulWidget {
  final TourPackage package;
  const PackageDetailScreen({super.key, required this.package});

  @override
  ConsumerState<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initYoutube(widget.package.videoUrl);
  }

  void _initYoutube(String? videoUrl) {
    if (videoUrl != null && videoUrl.isNotEmpty) {
      RegExp regExp = RegExp(r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})');
      var match = regExp.firstMatch(videoUrl);
      final videoId = match != null && match.groupCount >= 1 ? match.group(1) : null;
      
      if (videoId != null) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: true,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const LinearGradient primaryGradient = LinearGradient(
      colors: [Color(0xFFFF7B89), Color(0xFFFF9E7B)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final detailAsyncValue = ref.watch(packageDetailProvider(widget.package.id));
    final displayPackage = detailAsyncValue.value ?? widget.package;
    final selectedDateIndex = ref.watch(selectedDateIndexProvider);
    final seats = ref.watch(seatsProvider);
    final currentCarouselIndex = ref.watch(currentCarouselIndexProvider);

    // Handle Youtube Init if videoUrl is loaded later from the API
    if (_youtubeController == null && displayPackage.videoUrl != null && displayPackage.videoUrl!.isNotEmpty) {
      _initYoutube(displayPackage.videoUrl);
    }

    // Removed cleanDescription as the description section is no longer in the UI

    double totalPrice = displayPackage.price * seats;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(displayPackage.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: primaryGradient,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The package name has been moved to the AppBar

                      const SizedBox(height: 4),
                      Text(displayPackage.country, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 14,
                            color: index < displayPackage.rating.round() ? const Color(0xFFFFD700) : Colors.grey.shade300,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _youtubeController != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: YoutubePlayer(
                              controller: _youtubeController!,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CoverImage(
                              imageUrl: displayPackage.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  
                  // Gallery Carousel
                  if (displayPackage.galleryImages.isNotEmpty)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 280,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.7,
                            onPageChanged: (index, reason) {
                              ref.read(currentCarouselIndexProvider.notifier).set(index);
                            },
                          ),
                          items: displayPackage.galleryImages.map((img) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CoverImage(imageUrl: img, fit: BoxFit.cover, width: double.infinity),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        // Dots
                        Positioned(
                          bottom: 28,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: displayPackage.galleryImages.asMap().entries.map((entry) {
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: currentCarouselIndex == entry.key ? 1.0 : 0.5),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Left Arrow
                        const Positioned(
                          left: 20,
                          child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 36, shadows: [Shadow(color: Colors.black45, blurRadius: 8)]),
                        ),
                        // Right Arrow
                        const Positioned(
                          right: 20,
                          child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 36, shadows: [Shadow(color: Colors.black45, blurRadius: 8)]),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Dates Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (displayPackage.calendars.isNotEmpty)
                          ...displayPackage.calendars.asMap().entries.map((entry) {
                            int idx = entry.key;
                            var calendar = entry.value;
                            bool isAvailable = calendar.state == 'open' && calendar.remainingSeats > 0;
                            bool isSelected = selectedDateIndex == idx;
                            return GestureDetector(
                              onTap: isAvailable ? () {
                                ref.read(selectedDateIndexProvider.notifier).set(idx);
                                if (ref.read(seatsProvider) > calendar.remainingSeats) {
                                  ref.read(seatsProvider.notifier).set(calendar.remainingSeats);
                                }
                              } : null,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: idx != displayPackage.calendars.length - 1 ? Border(bottom: BorderSide(color: Colors.grey.shade200)) : null,
                                ),
                                child: Row(
                                  children: [
                                    // Custom Radio
                                    Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isSelected ? const Color(0xFFFF3B30) : Colors.grey.shade400, width: 2),
                                      ),
                                      child: isSelected ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF3B30)))) : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('${calendar.dateStart} - ${calendar.dateEnd}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                            if (isSelected) const Text(' • Available Date', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.circle, size: 10, color: isAvailable ? Colors.green : Colors.red),
                                            const SizedBox(width: 6),
                                            Text(
                                              isAvailable ? 'Available Date' : 'Fully Booked',
                                              style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.w500, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                        else
                          const Padding(padding: EdgeInsets.all(16), child: Text("No dates available.")),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Add Seats Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Add Seats:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Seats Card
                  if (displayPackage.calendars.isNotEmpty && selectedDateIndex < displayPackage.calendars.length)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 180, height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (ref.read(seatsProvider) > 1) ref.read(seatsProvider.notifier).decrement();
                                          },
                                          child: const Center(child: Icon(Icons.remove, color: Colors.black, size: 28)),
                                        )
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade300))
                                          ),
                                          child: Center(child: Text('$seats', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (ref.read(seatsProvider) < displayPackage.calendars[selectedDateIndex].remainingSeats) {
                                              ref.read(seatsProvider.notifier).increment();
                                            }
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE92525), // Strong red matching mockup
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                            ),
                                            child: const Center(child: Icon(Icons.add, color: Colors.white, size: 28)),
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          
                          // Stats Footer inside Seats Card
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                              border: Border(top: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(children: [const Icon(Icons.people, color: Color(0xFF1358C5), size: 16), const SizedBox(width: 4), Text('Booked: ${30 - displayPackage.calendars[selectedDateIndex].remainingSeats}', style: const TextStyle(fontSize: 12, color: Color(0xFF1358C5), fontWeight: FontWeight.w700))]),
                                Row(children: [const Icon(Icons.people, color: Color(0xFF2CA348), size: 16), const SizedBox(width: 4), Text('Remaining: ${displayPackage.calendars[selectedDateIndex].remainingSeats}', style: const TextStyle(fontSize: 12, color: Color(0xFF2CA348), fontWeight: FontWeight.w700))]),
                                const Row(children: [Icon(Icons.info, color: Colors.grey, size: 16), SizedBox(width: 4), Text('Total: 30', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w700))]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  const SizedBox(height: 16),
                  
                  // Info Card
                  if (displayPackage.calendars.isNotEmpty && selectedDateIndex < displayPackage.calendars.length)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black54),
                              const SizedBox(width: 12),
                              Text('Date:  ${displayPackage.calendars[selectedDateIndex].dateStart} - ${displayPackage.calendars[selectedDateIndex].dateEnd}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.access_time_outlined, size: 20, color: Colors.black54),
                              const SizedBox(width: 12),
                              Text('Duration: ${displayPackage.duration} Days', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.phone_in_talk_outlined, size: 20, color: Colors.black54), // Matches the weird icon in screenshot
                              const SizedBox(width: 12),
                              Text('Price: \$${displayPackage.price.toStringAsFixed(2)} per person', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Book Now Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3B30), Color(0xFFFF6B00)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3B30).withAlpha(76),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () {},
                        child: Center(
                          child: detailAsyncValue.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                'Book Now - \$${totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ], // Closes inner Column
              ), // Closes inner Column
            ), // Closes SingleChildScrollView
          ), // Closes Expanded
          ], // Closes outer Column's children
        ), // Closes outer Column
      ), // Closes SafeArea
        ], // Closes Stack's children
      ), // Closes Stack
    );
  }
}
