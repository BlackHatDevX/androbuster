# AndroBuster - Code Structure

This directory contains the main Flutter application code organized in a clean, modular architecture.

## 📁 Directory Structure

```
lib/
├── main.dart                 # Main application entry point
├── androbuster.dart         # Barrel file for easy imports
├── README.md               # This file
├── models/                 # Data models
│   └── scan_result.dart    # Scan result data class
├── services/               # Business logic services
│   ├── scanning_service.dart    # Core scanning functionality
│   ├── file_service.dart        # File handling operations
│   ├── update_service.dart      # Version checking and updates
│   └── background_service.dart  # Background execution management
└── widgets/                # UI components
    ├── directory_tab.dart      # Directory enumeration tab
    ├── subdomain_tab.dart      # Subdomain enumeration tab
    ├── results_tab.dart        # Results display tab
    └── dialogs.dart            # Dialog components
```

## 🏗️ Architecture Overview

### **Models** (`models/`)
- **`scan_result.dart`**: Data class representing a single scan result with path, status code, size, and URL.

### **Services** (`services/`)
- **`scanning_service.dart`**: Core scanning logic for both directory and subdomain enumeration.
- **`file_service.dart`**: Handles file picking, processing, and size validation.
- **`update_service.dart`**: Manages version checking and update functionality.
- **`background_service.dart`**: Handles background execution and native Android service communication.

### **Widgets** (`widgets/`)
- **`directory_tab.dart`**: Complete directory enumeration interface.
- **`subdomain_tab.dart`**: Complete subdomain enumeration interface.
- **`results_tab.dart`**: Results display and management interface.
- **`dialogs.dart`**: Collection of reusable dialog widgets.

### **Main App** (`main.dart`)
- **`MainApp`**: Root application widget with theme configuration.
- **`AndroBusterScreen`**: Main screen with tab controller and state management.

## 🔧 Key Features

### **Separation of Concerns**
- **Services**: Handle business logic and external operations
- **Widgets**: Manage UI presentation and user interaction
- **Models**: Define data structures
- **Main**: Orchestrates components and manages state

### **Clean Architecture**
- **Single Responsibility**: Each class has one clear purpose
- **Dependency Injection**: Services are injected where needed
- **Testability**: Services can be easily mocked for testing
- **Maintainability**: Clear separation makes code easier to modify

### **Performance Optimizations**
- **Lazy Loading**: Components are only created when needed
- **Memory Management**: Proper disposal of controllers and timers
- **Background Processing**: Efficient handling of large wordlists

## 🚀 Usage

### **Importing Components**
```dart
// Import specific components
import 'package:androbuster/models/scan_result.dart';
import 'package:androbuster/services/scanning_service.dart';

// Or import everything via barrel file
import 'package:androbuster/androbuster.dart';
```

### **Using Services**
```dart
// Scan a path
final result = await ScanningService.scanPath(
  'admin',
  'https://example.com',
  [404, 403],
  [0],
  5000,
);

// Process a file
final fileInfo = await FileService.processFile(filePickerResult);
```

### **Creating Widgets**
```dart
// Directory tab
DirectoryTab(
  urlController: _urlController,
  onStartScan: _startScan,
  // ... other parameters
)

// Results tab
ResultsTab(
  directoryResults: _results,
  subdomainResults: _subdomainResults,
  onCopyResults: _copyResults,
  onClearResults: _clearResults,
)
```

## 🧪 Testing

The modular architecture makes testing straightforward:

```dart
// Mock services for testing
class MockScanningService extends Mock implements ScanningService {
  // Mock implementations
}

// Test individual components
testWidgets('Directory tab shows correct fields', (tester) async {
  await tester.pumpWidget(DirectoryTab(/* parameters */));
  // Test assertions
});
```

## 🔄 State Management

The app uses Flutter's built-in `StatefulWidget` with:
- **Local State**: Managed within each widget
- **Shared State**: Passed down through parameters
- **Service State**: Managed by service classes

## 📱 Platform Support

- **Android**: Full support with native foreground service
- **Other Platforms**: Not currently supported

## 🚀 Future Enhancements

The modular structure makes it easy to add:
- **New scanning modes** (port scanning, API testing)
- **Additional services** (database storage, reporting)
- **Custom widgets** (charts, advanced filters)
- **Plugin system** for extensibility

---

**Note**: This architecture follows Flutter best practices and is designed for maintainability, testability, and future expansion.
