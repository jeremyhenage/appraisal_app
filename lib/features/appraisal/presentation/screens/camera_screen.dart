import 'dart:io';
import 'package:appraisal_app/features/appraisal/application/appraisal_providers.dart';
import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart' as macos_camera;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appraisal_app/features/appraisal/presentation/widgets/targeting_reticle.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  // Mobile Controller
  CameraController? _mobileController;
  List<CameraDescription>? _cameras;

  // macOS Controller
  macos_camera.CameraMacOSController? _macOSController;

  bool _isCameraInitialized = false;
  bool _isMockMode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Only initialize mobile camera manually. macOS handles it in the View widget.
    if (!Platform.isMacOS) {
      _initializeMobileCamera();
    }
  }

  Future<void> _initializeMobileCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _enterMockMode('No cameras found.');
        return;
      }

      // Select the first back camera
      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _mobileController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _mobileController!.initialize();

      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
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
    _mobileController?.dispose();
    // macOS controller doesn't need explicit dispose if handled by the View, 
    // but the package documentation suggests destroy() might be needed if not managed by widget. 
    // CameraMacOSView handles its own lifecycle.
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    try {
      XFile? image;

      if (_isMockMode) {
        // In a real scenario, you might pick a gallery image here.
        // For now, we just proceed to dashboard with mock data (handled by repository fallback or mock check).
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mock Mode: Cannot analyze real image. Check dashboard for mock data.')),
        );
        return;
      }

      final controllerNotifier = ref.read(appraisalControllerProvider.notifier);

      if (Platform.isMacOS) {
        // macOS Capture
        if (_macOSController == null) return;
        
        final macos_camera.CameraMacOSFile? file = await _macOSController!.takePicture();
        if (file != null && file.bytes != null) {
          // Create XFile from bytes
          // Note: XFile.fromData is efficient.
          image = XFile.fromData(
            file.bytes!, 
            mimeType: 'image/jpeg', // Assuming jpeg/tiff usually
            name: 'capture.jpg' 
          );
        }
      } else {
        // Mobile Capture
        if (_mobileController == null || !_mobileController!.value.isInitialized) return;
        
        // Ensure flash is off or auto
        await _mobileController!.setFlashMode(FlashMode.off);
        image = await _mobileController!.takePicture();
      }

      if (image != null) {
        // Show loading via Riverpod state implied by the Future? 
        // Actually AppraisalController handles state.
        // We just call the method.
        await controllerNotifier.analyze(image);
        
        if (!mounted) return;

        // Navigate to Dashboard
        Navigator.of(context).pushNamed('/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to appraisal state
    ref.listen(appraisalControllerProvider, (previous, next) {
      next.when(
        data: (data) {
          if (data != null) {
             // Navigation is now handled directly in _captureAndAnalyze
             // Navigator.of(context).pushNamed('/dashboard', arguments: data);
             // Reset controller after navigation so we can scan again?
             // Optional.
          }
        },
        error: (e, st) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Analysis Failed: $e')),
          );
        },
        loading: () {}, // Handled by isLoading check
      );
    });

    final appraisalState = ref.watch(appraisalControllerProvider);
    final isLoading = appraisalState.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Layer
          if (_isCameraInitialized)
            Platform.isMacOS
                ? macos_camera.CameraMacOSView(
                    fit: BoxFit.cover,
                    cameraMode: macos_camera.CameraMacOSMode.photo,
                    onCameraInizialized: (controller) {
                      setState(() {
                        _macOSController = controller;
                        _isCameraInitialized = true; // Confirmed initialized
                      });
                    },
                  )
                : CameraPreview(_mobileController!)
          else
            _buildMockView(),

          // 2. Tactical Overlay (Always visible)
          IgnorePointer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: TargetingReticlePainter(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),

          // 3. Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.cyan),
                    SizedBox(height: 16),
                    Text(
                      "ANALYZING BALLISTICS...",
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: Colors.cyan,
                        fontSize: 14,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. UI Controls
          if (!isLoading)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  heroTag: 'scanBtn',
                  onPressed: _captureAndAnalyze,
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  child: const Icon(Icons.camera_alt, size: 32),
                ),
              ),
            ),
            
          // 4b. Mock Mode Indicator (Optional, if we want to show strict mode)
           if (_isMockMode)
            Positioned(
               bottom: 100,
               left: 16,
               right: 16,
               child: Text(
                 _errorMessage ?? "Mock Mode",
                 textAlign: TextAlign.center,
                 style: const TextStyle(color: Colors.redAccent, fontSize: 12),
               ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final controllerNotifier = ref.read(appraisalControllerProvider.notifier);
        await controllerNotifier.analyze(image);
        if (!mounted) return;
        Navigator.of(context).pushNamed('/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildMockView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            "CAMERA OFFLINE",
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white24,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text("UPLOAD IMAGE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.withOpacity(0.2),
                  foregroundColor: Colors.cyan,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                   // Navigate to dashboard with mock/empty data
                   Navigator.of(context).pushNamed('/dashboard');
                },
                child: const Text("MANUAL ENTRY"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
