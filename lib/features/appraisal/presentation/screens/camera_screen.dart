import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:appraisal_app/features/appraisal/presentation/widgets/targeting_reticle.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  String? _errorMessage;
  bool _isMockMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _enterMockMode('No cameras found. Entering Mock Mode.');
        return;
      }

      // Try to find a back camera, otherwise take the first one (e.g. webcam)
      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _errorMessage = null;
        _isMockMode = false;
      });
    } catch (e) {
      if (!mounted) return;
      _enterMockMode('Error initializing camera: $e. Entering Mock Mode.');
    }
  }

  void _enterMockMode(String message) {
    setState(() {
      _isMockMode = true;
      _errorMessage = message;
      _isCameraInitialized = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Feed or Mock Background
          if (_isCameraInitialized && _controller != null)
             CameraPreview(_controller!)
          else
            _buildMockView(),

          // 2. Tactical Overlay (Always visible)
          LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: TargetingReticlePainter(
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),

          // 3. UI Controls
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/dashboard');
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.camera_alt, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockView() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              "CAMERA OFFLINE",
              style: TextStyle(
                color: Colors.white24,
                fontFamily: 'JetBrains Mono',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
