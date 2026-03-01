import 'package:appraisal_app/core/theme/app_theme.dart';
import 'package:appraisal_app/features/appraisal/domain/entities/appraisal_result.dart';
import 'package:appraisal_app/features/appraisal/presentation/screens/camera_screen.dart';
import 'package:appraisal_app/features/appraisal/presentation/screens/deal_dashboard_screen.dart';
import 'package:appraisal_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Anonymous Auth to ensure backend access
  try {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      // Disable persistence on macOS to avoid Keychain Access errors without signed entitlements
      await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    }
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    debugPrint("Auth Error: $e");
  }

  runApp(const ProviderScope(child: AppraisalApp()));
}

class AppraisalApp extends StatelessWidget {
  const AppraisalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operator Terminal',
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const CameraScreen());
        }
        if (settings.name == '/dashboard') {
          final args = settings.arguments as AppraisalResult?;
          // If no args (e.g. direct nav or reload), maybe show mock or error?
          // For now, let's assume args are passed. If not, maybe use mock as fallback for dev?
          return MaterialPageRoute(
            builder: (_) => DealDashboardScreen(
              result: args ?? AppraisalResult.mock(), // Fallback to mock if null
            ),
          );
        }
        return null;
      },
    );
  }
}
