import 'dart:async';

import 'package:appraisal_app/features/appraisal/data/repositories/appraisal_repository.dart';
import 'package:appraisal_app/features/appraisal/domain/entities/appraisal_result.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
final appraisalRepositoryProvider = Provider<AppraisalRepository>((ref) {
  return AppraisalRepository();
});

// Controller Provider
final appraisalControllerProvider = AsyncNotifierProvider<AppraisalController, AppraisalResult?>(() {
  return AppraisalController();
});

class AppraisalController extends AsyncNotifier<AppraisalResult?> {
  @override
  FutureOr<AppraisalResult?> build() {
    return null; // Initial state is null (no appraisal yet)
  }

  Future<void> analyze(XFile image) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(appraisalRepositoryProvider);
      final result = await repository.appraiseItem(image: image);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
