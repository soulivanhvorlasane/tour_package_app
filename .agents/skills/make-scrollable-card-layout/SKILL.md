---
name: Make Scrollable Card Layout
description: Best practices for implementing a beautiful, horizontally scrollable card layout with swiping interactions.
---

# Make Scrollable Card Layout

When the user asks you to implement a horizontally scrollable card layout (or swipeable cards), follow these exact instructions and best practices to ensure a premium, modern user experience.

## Step 1: The Container and Layout

To create a horizontal scroll, you must constrain the height of the list. Do not use an unbounded horizontal list without a height constraint.

1. Wrap your `ListView.builder` in a `SizedBox` with a fixed height (e.g., 500-600 depending on content).
2. If this is part of a `CustomScrollView`, wrap the `SizedBox` inside a `SliverToBoxAdapter`.

```dart
SliverToBoxAdapter(
  child: SizedBox(
    height: 540, // Define a fixed height for the horizontal carousel
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(), // Important for native feel
      padding: const EdgeInsets.only(left: 24, right: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        // Build card here
      },
    ),
  ),
);
```

## Step 2: Sizing the Cards for "Peeking"

A premium scrollable layout should hint to the user that there are more cards to the right. To do this, **do not** let the card take up 100% of the screen width.

1. Set the width of each card to roughly `80%` or `85%` of the screen width using `MediaQuery`.
2. Add padding to the right of each card so they have breathing room.

```dart
itemBuilder: (context, index) {
  return Padding(
    padding: const EdgeInsets.only(right: 16.0), // Gap between cards
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.85, // 85% width allows the next card to peek in
      child: MyCustomCardWidget(item: items[index]),
    ),
  );
}
```

## Step 3: Constraining Internal Content

When placing content inside a card that lives in a fixed-height container, you must prevent text from overflowing or wrapping infinitely, which would break the layout height.

1. Ensure multi-line text blocks (like descriptions) have a hard `maxLines` limit.
2. Add `overflow: TextOverflow.ellipsis` to gracefully truncate overflowing text.

```dart
Text(
  item.description,
  maxLines: 3,
  overflow: TextOverflow.ellipsis, // Critical for fixed-height layouts
  style: const TextStyle(
    fontSize: 15,
    color: Color(0xFF4A4A4A),
    height: 1.4,
  ),
)
```

## Key Guidelines

- **Scroll Physics:** Always use `BouncingScrollPhysics()` on horizontal carousels to provide a fluid, premium feel, especially on iOS.
- **Card Aesthetics:** Cards should use subtle shadows, rounded corners (`BorderRadius.circular`), and an engaging cover image (`ClipRRect`) to maintain visual excellence.
- **Responsiveness:** Use screen-relative sizing (`MediaQuery`) instead of hardcoded widths for the cards, ensuring the "peeking" effect works correctly on all device sizes.
