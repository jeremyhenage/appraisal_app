import 'package:flutter/material.dart';
import 'package:appraisal_app/core/theme/app_theme.dart';
import 'package:appraisal_app/features/appraisal/presentation/screens/camera_screen.dart';
import 'package:appraisal_app/features/appraisal/presentation/screens/deal_dashboard_screen.dart';

void main() {
  runApp(const AppraisalApp());
}

class AppraisalApp extends StatelessWidget {
  const AppraisalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operator Terminal',
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const CameraScreen(),
        '/dashboard': (context) => const DealDashboardScreen(),
      },
    );
  }
}
