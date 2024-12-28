# order_app

Required :
- Xampp control Panel
- flutter 3.24.5
- dart 3.5.4
- Android SDK 8.0
- Java 21.0.5 
- node 18.18.0

To RUN :
- Start Xampp Control Panel
- buat database baru dengan nama mobile_app, kemudian import database pada folder database/mobile_app.sql
- buka ide, pada terminal masuk ke folder backend, install dependecies dengan mengetik 'npm install'
- setelah selesai, kembali ke root project, kemudian ketik 'flutter pub get' untuk menginstal dependecies flutter.
- kemudian ketikan 'flutter run flutter_launcher_icons:main' untuk mengaktifkan icon launcher
- kemudian konfigurasikan ip address pada lib/services/api_service.dart, sesuaikan dengan ip address yang sedang digunakan pc anda. static const String _baseUrl = 'http://IPADRESS:3000';
- setelah itu ketikan lagi di terminal node 'backend\index.js' untuk menjalankan node yang merupakan penghubung flutter dengan database mysql
- done, jalankan aplikasinya.

This app is made by Christy Dany Tallane
Instagram   : https://www.instagram.com/danytallane?igsh=MW9yNWZydjNia25wYw==
Facebook    : https://www.facebook.com/share/15pnHuc1Jv/

feel free to reach me :
whatsapp : https://wa.me/+6281328438393/

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
