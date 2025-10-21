import 'dart:core';

class SimplePerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, int> _componentTimes = {};
  
  static void startTimer(String component) {
    _timers[component] = Stopwatch()..start();
    print('[PERFORMANCE] START: \$component initialization');
  }
  
  static void stopTimer(String component) {
    final timer = _timers[component];
    if (timer != null) {
      timer.stop();
      final timeMs = timer.elapsedMilliseconds;
      _componentTimes[component] = timeMs;
      
      print('[PERFORMANCE] COMPLETE: \$component initialized in \${timeMs}ms');
      
      if (timeMs > 1000) {
        print('[PERFORMANCE] WARNING: \$component is slow: \${timeMs}ms');
      }
    }
  }
  
  static void printSummary() {
    print('[PERFORMANCE] === INITIALIZATION PERFORMANCE SUMMARY ===');
    _componentTimes.forEach((component, time) {
      final status = time > 1000 ? '[WARNING]' : '[SUCCESS]';
      print('[PERFORMANCE]    \$status \$component: \${time}ms');
    });
    
    final totalTime = _componentTimes.values.fold(0, (sum, time) => sum + time);
    print('[PERFORMANCE]    [TOTAL] Time: \${totalTime}ms');
    print('[PERFORMANCE] ==========================================');
  }
  
  static Map<String, int> getTimings() {
    return Map.from(_componentTimes);
  }
}
