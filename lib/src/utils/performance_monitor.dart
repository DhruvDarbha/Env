import 'dart:developer' as developer;

class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  
  /// Start timing a performance operation
  static void startTiming(String operationName) {
    _startTimes[operationName] = DateTime.now();
    developer.log('🚀 Started: $operationName', name: 'Performance');
  }
  
  /// End timing and log the duration
  static Duration endTiming(String operationName) {
    final startTime = _startTimes.remove(operationName);
    if (startTime == null) {
      developer.log('⚠️ No start time found for: $operationName', name: 'Performance');
      return Duration.zero;
    }
    
    final duration = DateTime.now().difference(startTime);
    developer.log(
      '✅ Completed: $operationName in ${duration.inMilliseconds}ms',
      name: 'Performance',
    );
    
    return duration;
  }
  
  /// Time an async operation
  static Future<T> timeAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTiming(operationName);
    try {
      final result = await operation();
      endTiming(operationName);
      return result;
    } catch (e) {
      endTiming(operationName);
      rethrow;
    }
  }
  
  /// Time a sync operation
  static T timeSync<T>(
    String operationName,
    T Function() operation,
  ) {
    startTiming(operationName);
    try {
      final result = operation();
      endTiming(operationName);
      return result;
    } catch (e) {
      endTiming(operationName);
      rethrow;
    }
  }
  
  /// Log a performance metric
  static void logMetric(String metricName, dynamic value, [String unit = '']) {
    developer.log(
      '📊 $metricName: $value$unit',
      name: 'Performance',
    );
  }
}
