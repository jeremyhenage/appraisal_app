
import 'dart:io';

import 'package:appraisal_app/features/appraisal/domain/entities/appraisal_result.dart';
import 'package:camera/camera.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class AppraisalRepository {
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  AppraisalRepository({
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'us-central1'),
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<AppraisalResult> appraiseItem({required XFile image}) async {
    try {
      // 1. Ensure user is authenticated
      User? user = _auth.currentUser;
      
      if (user == null && Platform.isMacOS && kDebugMode) {
         debugPrint("⚠️ AUTH BYPASS: Using Mock User ID for macOS Debug");
      } else if (user == null) {
        try {
          final userCredential = await _auth.signInAnonymously();
          user = userCredential.user;
        } catch (e) {
           // If sign-in fails on macOS debug, proceed with mock
           if (Platform.isMacOS && kDebugMode) {
              debugPrint("⚠️ AUTH FAILED ($e): Proceeding with Mock User ID");
           } else {
             rethrow;
           }
        }
      }
      
      final String userId = user?.uid ?? "mock_user_${DateTime.now().millisecondsSinceEpoch}";

      // 2. Upload image to Firebase Storage
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('appraisals/$userId/$fileName');

      debugPrint("Starting upload to: ${storageRef.fullPath} in bucket: ${storageRef.bucket}");
      
      final File localFile = File(image.path);
      if (!await localFile.exists()) {
        debugPrint("❌ ERROR: Local file does not exist at path: ${image.path}");
        throw Exception("Local file not found");
      } else {
        debugPrint("✅ Local file exists at: ${image.path} (${await localFile.length()} bytes)");
        try {
           final _ = await localFile.readAsBytes();
           debugPrint("✅ Local file is readable");
        } catch (e) {
           debugPrint("❌ ERROR: Local file is NOT readable (Sandbox issue?): $e");
        }
      }

      if (_auth.currentUser == null) {
        debugPrint("❌ ERROR: Auth is still NULL after sign-in attempt!");
      } else {
        debugPrint("✅ Auth Success: User ID: ${_auth.currentUser?.uid} (Is Anon: ${_auth.currentUser?.isAnonymous})");
      }

      try {
        // ALWAYS use putData on macOS to avoid potential Sandbox file access issues with putFile
        // internal-error/object-not-found can sometimes result from the SDK being unable to read the source file handle correctly.
        final Uint8List fileBytes = await image.readAsBytes();
        await storageRef.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));
        
        debugPrint("Upload completed successfully.");
      } catch (e) {
        debugPrint("Upload failed: $e");
        rethrow;
      }

      // Use getDownloadURL() to get an HTTPS URL that the Cloud Function (and Vertex AI) can access directly.
      debugPrint("Getting download URL...");
      final String downloadUrl = await storageRef.getDownloadURL();
      debugPrint("Image uploaded to: $downloadUrl");

      // 3. Call Cloud Function
      // Use GCS URI (gs://) for internal access by Vertex AI, avoiding public URL/token issues.
      final String gsUri = 'gs://${storageRef.bucket}/${storageRef.fullPath}';
      debugPrint("Calling Cloud Function with GCS URI: $gsUri");

      final HttpsCallable callable = _functions.httpsCallable('appraise_item');
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'imageUrl': gsUri, 
      });

      // 4. Parse Response
      final dynamic rawData = result.data;
      debugPrint("✅ RAW CLOUD FUNCTION RESPONSE: $rawData");
      
      if (rawData == null) {
        throw Exception("Cloud Function returned null data");
      }
      
      // Safe cast: Convert generic Map<Object?, Object?> to Map<String, dynamic>
      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);
      
      return AppraisalResult.fromJson(data);
    } catch (e) {
      debugPrint('Appraisal Error: $e');
      rethrow;
    }
  }
}
