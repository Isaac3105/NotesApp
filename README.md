# 📝 MyNotes

A modern, feature-rich notes application built with Flutter and Firebase. Create, edit, and organize your notes with rich text formatting, image support, and real-time cloud synchronization.

## 📱 Preview Video

![app-preview](https://github.com/user-attachments/assets/bf16adc2-6f18-474e-9315-ff00815dd62c)

## ✨ Features

### 🎨 **Rich Text Editor**
- **Bold** and *Italic* text formatting
- Numbered and bullet point lists
- Checkbox lists for to-dos
- Image insertion from camera or gallery
- Undo/Redo functionality
- Custom toolbar with optimized button layout

### 🔒 **Authentication & Security**
- Firebase Authentication integration
- Secure user registration and login
- User-specific note storage
- Automatic session management

### ☁️ **Cloud Storage**
- Real-time synchronization with Firebase Firestore
- Automatic save as you type
- Cross-device access to your notes

### 🎭 **Themes & UI**
- Light and Dark theme support
- Manual theme toggle
- Custom amber color scheme
- Material Design 3 components
- Beautiful native splash screen

### 🔍 **Search & Organization**
- Real-time note search
- Search through note titles and content
- Clean, organized note list view
- Quick note creation and editing

### 📱 **Mobile-First Experience**
- Optimized for mobile devices
- Responsive design
- Smooth animations and transitions
- Native Android splash screen

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio or VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Isaac3105/NotesApp.git
   cd notes_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication and Firestore
   - Download `google-services.json` and place in `android/app/`
   - Edit the `.env` file with your Firebase configuration

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Build for Release

### Android APK
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

Or just download the release .apk app from the repo.

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
AAB location: `build/app/outputs/bundle/release/app-release.aab`

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase (Authentication + Firestore)
- **Rich Text**: Flutter Quill 11.4.2
- **State Management**: BLoC Pattern
- **Storage**: Cloud Firestore + SQLite (offline)
- **Authentication**: Firebase Auth
- **UI**: Material Design 3
- **Splash Screen**: Flutter Native Splash

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_quill: ^11.4.2                    # Rich text editor
  flutter_quill_extensions: ^11.0.0         # Image support
  firebase_core: ^4.0.0                     # Firebase core
  firebase_auth: ^6.0.0                     # Authentication
  cloud_firestore: ^6.0.0                   # Cloud database
  flutter_bloc: ^9.1.1                      # State management
  share_plus: ^11.1.0                       # Share functionality
  google_fonts: ^6.3.1                      # Custom fonts
  flutter_native_splash: ^2.4.6             # Splash screen
```

## 🎨 App Themes

The app features a beautiful amber-based color scheme with both light and dark variants:

- **Light Theme**: Clean white background with amber accents
- **Dark Theme**: Dark background with amber highlights
- **Manual Toggle**: Users can switch themes anytime
- **Consistent Branding**: Amber (#FFC107) throughout the app



## 🚧 Future Enhancements

- [ ] Note categories and tags
- [ ] Export notes to PDF/Text
- [ ] Note sharing between users
- [ ] Voice notes integration
- [ ] Advanced search filters
- [ ] Note encryption
- [ ] Restore functionality

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Isaac** - [Isaac3105](https://github.com/Isaac3105)

