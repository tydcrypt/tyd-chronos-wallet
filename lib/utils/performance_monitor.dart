import 'dart:core';

class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, int> _componentTimes = {};
  
  static void startTimer(String component) {
    _timers[component] = Stopwatch()..start();
    print('⏱️ START: $component initialization');
  }
  
  static void stopTimer(String component) {
    final timer = _timers[component];
    if (timer != null) {
      timer.stop();
      final timeMs = timer.elapsedMilliseconds;
      _componentTimes[component] = timeMs;
      
      print('✅ COMPLETE: $component initialized in ${timeMs}ms');
      
      if (timeMs > 2000) {
        print('⚠️ WARNING: $component is slow: ${timeMs}ms');
      }
    }
  }
  
  static void printSummary() {
    print('\n📊 INITIALIZATION PERFORMANCE SUMMARY:');
    _componentTimes.forEach((component, time) {
      final status = time > 2000 ? '⚠️' : '✅';
      print('   $status $component: ${time}ms');
    });
    
    final totalTime = _componentTimes.values.fold(0, (sum, time) => sum + time);
    print('   📈 TOTAL TIME: ${totalTime}ms');
  }
  
  static Map<String, int> getTimings() {
    return Map.from(_componentTimes);
  }
}
