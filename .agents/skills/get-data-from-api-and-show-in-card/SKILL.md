---
name: Get Data From API and Show In Card
description: Best practices for fetching data from an API using Riverpod and displaying it in a beautifully styled Flutter card widget.
---

# Get Data From API and Show In Card

When the user asks you to fetch data from an API and display it in a card, follow this detailed step-by-step workflow.

## Step 1: Create the Data Model
Always start by defining a strongly-typed Dart model for the API response. Place it in `lib/models/`.

```dart
class ItemModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final double price;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.price,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? '',
      imageUrl: json['image_url'], // Handle snake_case to camelCase
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
```
*Rule: Always provide safe fallback values for missing JSON fields.*

## Step 2: Create the API Provider (Riverpod)
Create a `FutureProvider` in `lib/providers/` to handle the asynchronous API call.

```dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

final itemsProvider = FutureProvider<List<ItemModel>>((ref) async {
  String baseUrl = 'http://localhost:8069';
  
  // Host resolution for emulators
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8069';
    } else if (Platform.isIOS || Platform.isMacOS) {
      baseUrl = 'http://localhost:8069'; 
    }
  }

  final url = Uri.parse('$baseUrl/api/items');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ItemModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load items: ${response.statusCode}');
  }
});
```
*Rule: Ensure you implement emulator host resolving (`10.0.2.2` for Android).*

## Step 3: Create the Reusable Card Widget
Build a stateless widget in `lib/widgets/` to display the item. 

```dart
import 'package:flutter/material.dart';
import '../models/item_model.dart';

class CustomItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onTap;

  const CustomItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            
            // Content Body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      ),
    );
  }
}
```
*Rule: Cards must have rounded corners (`BorderRadius`), subtle shadows (`BoxShadow`), and safe image loading with `errorBuilder`.*

## Step 4: Consume the Data in the UI Screen
Wrap your screen in a `ConsumerWidget` and use `.when()` to handle loading, error, and data states gracefully.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/items_provider.dart';
import '../widgets/custom_item_card.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsyncValue = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('API Data')),
      body: itemsAsyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return CustomItemCard(
                item: items[index],
                onTap: () {
                  // Navigate to details
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```
*Rule: Always handle `.loading` and `.error` states using Riverpod's `.when()`.*
