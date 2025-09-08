# aWaWa - Inventory & Mission Management App

A Flutter-based inventory and mission management application designed to help you organize equipment and plan activities. Perfect for outdoor enthusiasts, professionals, or anyone who needs to track gear and organize missions or trips.

## Features

### 📦 Inventory Management
- **Add Items**: Create inventory items with photos, quantities, and notes
- **Categorization**: Tag items by mission types (climbing, foreign, driving, etc.)
- **Search & Filter**: Quickly find items using search and category filters
- **Visual Inventory**: Attach multiple images to each item for easy identification
- **Quantity Tracking**: Keep track of item quantities and availability

### 🎯 Mission Planning
- **Create Missions**: Plan missions with start/end dates and mission types
- **Item Assignment**: Add inventory items to missions with specific quantities
- **Todo Lists**: Create and manage todo items for each mission
- **Mission Tracking**: Track mission progress and completion status
- **Active Missions**: View and manage currently active missions

### 🔔 Smart Notifications
- **Mission Reminders**: Get notified about upcoming missions
- **Local Notifications**: Receive alerts even when the app is closed
- **Timezone Support**: Proper handling of different timezones

### 💾 Data Persistence
- **Local Storage**: All data is saved locally using SharedPreferences
- **Auto-Save**: Changes are automatically saved as you work
- **Data Recovery**: Your inventory and missions persist between app sessions

### 🎨 Modern UI
- **Dark Theme**: Beautiful dark theme with red accents and white text
- **Material Design 3**: Modern Flutter UI components
- **Responsive Design**: Works great on different screen sizes
- **Intuitive Navigation**: Easy-to-use bottom navigation and screens

## Screenshots

The app features a clean, dark interface with:
- **Home Screen**: Quick access to inventory and missions
- **Inventory Screen**: Browse, search, and filter your items
- **Mission Screen**: Plan and manage your missions
- **Detail Views**: Comprehensive item and mission details

## Installation

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd awawa
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate app icons:
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **flutter_local_notifications**: Local push notifications
- **image_picker**: Camera and gallery image selection
- **timezone**: Timezone handling for notifications
- **shared_preferences**: Local data persistence
- **cupertino_icons**: iOS-style icons

## Project Structure

```
lib/
├── main.dart              # Main app entry point and theme configuration
├── models/
│   ├── inventory_item.dart    # Inventory item data model
│   ├── mission.dart           # Mission data model
│   └── todo_item.dart         # Todo item data model
├── screens/
│   ├── home.dart              # Home screen with navigation
│   ├── inventory_screen.dart  # Inventory management
│   ├── mission_screen.dart    # Mission management
│   └── detail_screens.dart    # Item and mission details
└── services/
    ├── app_state.dart         # Global app state management
    └── notifications.dart     # Notification service
```

## Usage

### Adding Inventory Items
1. Navigate to the Inventory tab
2. Tap the "Add item" button
3. Fill in item details (name, quantity, notes)
4. Select mission types (climbing, foreign, driving)
5. Add photos from camera or gallery
6. Save the item

### Creating Missions
1. Go to the Missions tab
2. Tap the "New" floating action button
3. Enter mission details (name, dates, types)
4. Add inventory items to the mission
5. Create todo items for the mission
6. Save and activate when ready

### Managing Active Missions
- View active missions on the home screen
- Check off todo items as you complete them
- Mark inventory items as packed/used
- Complete missions when finished

## Data Models

### InventoryItem
- Unique ID and name
- Quantity tracking
- Mission type tags
- Multiple image support
- Notes and descriptions

### Mission
- Mission details (name, dates, types)
- Associated inventory items with quantities
- Todo lists for mission preparation
- Progress tracking and completion status

### Persistent Storage
All data is automatically saved to local storage using JSON serialization, ensuring your inventory and missions are preserved between app sessions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or feature requests, please open an issue on the project repository.
