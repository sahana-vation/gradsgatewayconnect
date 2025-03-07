import 'package:flutter/material.dart';
import 'package:gradsgatewayconnect/splash_screen.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'intro_screen.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for updates after the app is fully initialized
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   //checkForUpdate();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Set the global navigator key
      home: const IntroScreen(),
    );
  }
}

Future<void> checkForUpdate() async {
  //showUpdateDialog();
  try {
    // Get the current app version
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    print("Current version: $currentVersion");

    // Check for app updates
    final updateInfo = await InAppUpdate.checkForUpdate();

    // If an update is available, show the update dialog
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      showUpdateDialog();
    }
  } catch (e) {
    print("Error checking for updates: $e");
  }
 }



void showUpdateDialog() {
  showDialog(
    context: navigatorKey.currentContext!, // Use navigatorKey for context
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Update Available"),
        content: const Text(
            "A new version of the app is available. Please update to the latest version for better features and performance."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text("Later"),
          ),
          TextButton(
            onPressed: () async {
              const String appId = "com.gradsconnect.gradsgateway.gradsgatewayconnect";
              const String playStoreUrl = "https://play.google.com/store/apps/details?id=$appId&hl=en_IN";

              try {
                // Open the Play Store URL
                final Uri uri = Uri.parse(playStoreUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $playStoreUrl';
                }
              } catch (e) {
                print("Error opening Play Store: $e");
                ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                  const SnackBar(content: Text("Could not open Play Store. Please try again.")),
                );
              }
            },
            child: const Text("Update Now"),
          ),
        ],
      );
    },
  );
}

