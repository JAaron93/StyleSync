import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clothing_repository.dart';
import 'models/clothing_error.dart';
import 'models/clothing_item.dart';

/// Result type for retry operations.
sealed class RetryResult<T> {
  const RetryResult();

  bool get isSuccess => this is RetrySuccess<T>;
  bool get isFailure => this is RetryFailure<T>;
  T? get valueOrNull => switch (this) {
        RetrySuccess<T>(:final value) => value,
        RetryFailure<T>() => null,
      };
  ClothingError? get errorOrNull => switch (this) {
        RetrySuccess<T>() => null,
        RetryFailure<T>(:final error) => error,
      };
}

class RetrySuccess<T> extends RetryResult<T> {
  final T value;
  const RetrySuccess(this.value);
  @override
  String toString() => 'RetrySuccess($value)';
}

class RetryFailure<T> extends RetryResult<T> {
  final ClothingError error;
  const RetryFailure(this.error);
  @override
  String toString() => 'RetryFailure($error)';
}

/// Service for handling automatic background retries for failed processing.
///
/// Implements exponential backoff with jitter for retry attempts.
/// Uses a queue-based approach to manage retry tasks.
abstract class BackgroundRetryService {
  /// Enqueues an item for automatic retry.
  ///
  /// [itemId] - The ID of the item to retry.
  /// [retryCount] - The current retry count (used for backoff calculation).
  Future<void> enqueueRetry(String itemId, int retryCount);

  /// Processes the retry queue.
  ///
  /// This method should be called periodically (e.g., on app startup
  /// or when network connectivity is restored).
  Future<void> processRetryQueue();

  /// Gets the current retry queue size.
  int get queueSize;

  /// Clears all pending retries.
  Future<void> clearQueue();
}

/// Default implementation of [BackgroundRetryService].
///
/// Uses a simple in-memory queue with exponential backoff.
/// For production, consider using a persistent queue (e.g., Hive, SQLite).
class BackgroundRetryServiceImpl implements BackgroundRetryService {
  /// The clothing repository for performing retries.
  final ClothingRepository _repository;

  /// Queue of items to retry.
  final List<_RetryTask> _retryQueue = [];

  /// Timer for processing the queue.
  Timer? _processTimer;

  /// Creates a new [BackgroundRetryServiceImpl] instance.
  BackgroundRetryServiceImpl({
    required ClothingRepository repository,
  }) : _repository = repository;

  @override
  int get queueSize => _retryQueue.length;

  @override
  Future<void> enqueueRetry(String itemId, int retryCount) async {
    final task = _RetryTask(
      itemId: itemId,
      retryCount: retryCount,
      scheduledAt: DateTime.now().toUtc(),
    );
    _retryQueue.add(task);
    debugPrint('Enqueued retry for item $itemId (attempt ${retryCount + 1})');

    // Start processing if not already running
    _startProcessing();
  }

  @override
  Future<void> processRetryQueue() async {
    if (_retryQueue.isEmpty) {
      debugPrint('Retry queue is empty');
      return;
    }

    debugPrint('Processing ${_retryQueue.length} items in retry queue');

    // Process items in order
    for (final task in List.from(_retryQueue)) {
      final result = await _attemptRetry(task);
      if (result.isSuccess) {
        debugPrint('Successfully retried item ${task.itemId}');
        _retryQueue.remove(task);
      } else {
        debugPrint('Retry failed for item ${task.itemId}: ${result.errorOrNull}');
        // Keep in queue for next attempt
      }
    }
  }

  @override
  Future<void> clearQueue() async {
    _retryQueue.clear();
    _stopProcessing();
    debugPrint('Cleared retry queue');
  }

  /// Attempts to retry processing for an item.
  Future<RetryResult<ClothingItem>> _attemptRetry(_RetryTask task) async {
    try {
      // Calculate backoff delay with jitter
      final baseDelay = Duration(seconds: 1 << task.retryCount); // 1s, 2s, 4s, 8s...
      final jitter = Duration(milliseconds: Random().nextInt(1000)); // 0-1000ms jitter
      final delay = baseDelay + jitter;

      debugPrint('Waiting ${delay.inSeconds}s before retry for item ${task.itemId}');

      // Wait for backoff delay
      await Future<void>.delayed(delay);

      // Attempt retry
      final result = await _repository.retryProcessing(task.itemId);

      if (result.isFailure) {
        return RetryFailure(result.errorOrNull!);
      }

      return RetrySuccess(result.valueOrNull!);
    } catch (e) {
      return RetryFailure(ClothingError('Unexpected error during retry: $e'));
    }
  }

  /// Starts the processing timer.
  void _startProcessing() {
    if (_processTimer?.isActive ?? false) {
      return;
    }

    debugPrint('Starting retry queue processor');
    _processTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      processRetryQueue();
    });
  }

  /// Stops the processing timer.
  void _stopProcessing() {
    _processTimer?.cancel();
    _processTimer = null;
    debugPrint('Stopped retry queue processor');
  }
}

/// Represents a retry task in the queue.
class _RetryTask {
  /// The ID of the item to retry.
  final String itemId;

  /// The current retry count.
  final int retryCount;

  /// When this task was scheduled.
  final DateTime scheduledAt;

  const _RetryTask({
    required this.itemId,
    required this.retryCount,
    required this.scheduledAt,
  });
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for [BackgroundRetryService].
///
/// Creates a [BackgroundRetryServiceImpl] instance with injected dependencies.
final backgroundRetryServiceProvider = Provider<BackgroundRetryService>((ref) {
  final repository = ref.watch(clothingRepositoryProvider);
  return BackgroundRetryServiceImpl(repository: repository);
});
