import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class TourCalendar {
  final int id;
  final String dateStart;
  final String dateEnd;
  final String state;
  final int remainingSeats;

  TourCalendar({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.state,
    required this.remainingSeats,
  });

  factory TourCalendar.fromJson(Map<String, dynamic> json) {
    return TourCalendar(
      id: json['id'] as int? ?? 0,
      dateStart: json['date_start'] as String? ?? '',
      dateEnd: json['date_end'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      remainingSeats: json['remaining_seats'] as int? ?? 0,
    );
  }
}

class TourPackage {
  final int id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String? imageUrl;
  final String country;
  final double rating;
  final List<String> galleryImages;
  final String availabilityStatus;
  final String startDate;
  final String endDate;
  final String category;
  final String? videoUrl;
  final List<TourCalendar> calendars;

  TourPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.duration = 7,
    this.imageUrl,
    this.country = 'Ipsum country',
    this.rating = 5.0,
    this.galleryImages = const [],
    this.availabilityStatus = 'Available',
    this.startDate = '2026-07-12',
    this.endDate = '2026-07-29',
    this.category = 'Other',
    this.videoUrl,
    this.calendars = const [],
  });

  factory TourPackage.fromJson(Map<String, dynamic> json) {
    // Generate some mock gallery images if they aren't provided by API
    final int id = json['id'] as int? ?? 0;
    
    final String? mainImage = json['cover_image'] as String? ?? json['imageUrl'] as String?;

    // Helper to replace hostname for Emulators
    String fixHost(String url) {
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          return url.replaceAll('http://localhost:', 'http://10.0.2.2:').replaceAll('http://soulivanh:', 'http://10.0.2.2:');
        } else if (Platform.isIOS || Platform.isMacOS) {
          return url.replaceAll('http://soulivanh:', 'http://localhost:');
        }
      }
      return url;
    }

    // Helper to strip HTML tags if present in description
    String stripHtml(String htmlString) {
      RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      return htmlString.replaceAll(exp, '').trim();
    }
    
    // Check if calendars exist to extract dates
    String extractedStart = '2026-07-12';
    String extractedEnd = '2026-07-29';
    if (json['calendars'] != null && (json['calendars'] as List).isNotEmpty) {
      final firstCal = (json['calendars'] as List).first as Map<String, dynamic>;
      extractedStart = firstCal['date_start'] as String? ?? extractedStart;
      extractedEnd = firstCal['date_end'] as String? ?? extractedEnd;
    }
    
    return TourPackage(
      id: id,
      name: json['name'] as String? ?? 'Lorem Island',
      description: stripHtml(json['description'] as String? ?? 
          'Experience the ultimate relaxation with our Tropical Paradise Escape. Enjoy pristine beaches, luxury resorts, and crystal-clear waters.'),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as int? ?? 7,
      imageUrl: mainImage,
      country: json['country'] as String? ?? 'Ipsum country',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      availabilityStatus: json['availability_status'] as String? ?? 'Available',
      startDate: extractedStart,
      endDate: extractedEnd,
      videoUrl: json['video_url'] as String?,
      galleryImages: (json['gallery'] as List<dynamic>?)
              ?.map((e) => fixHost(e as String))
              .toList() ??
          [
            'https://picsum.photos/seed/gallery${id}a/400/400',
            'https://picsum.photos/seed/gallery${id}b/400/400',
            'https://picsum.photos/seed/gallery${id}c/400/400',
            'https://picsum.photos/seed/gallery${id}d/400/400',
            'https://picsum.photos/seed/gallery${id}e/400/400',
          ],
      category: json['category'] as String? ?? (
          (json['name'] as String? ?? '').toLowerCase().contains('yacht') ? 'Yachts' :
          (json['name'] as String? ?? '').toLowerCase().contains('jet') ? 'Jetskis' : 
          'Beach Activities'
      ),
      calendars: (json['calendars'] as List<dynamic>?)
              ?.map((e) => TourCalendar.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
