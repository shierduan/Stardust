import 'dart:math' as math;

class PIDController {
  final double kp;
  final double ki;
  final double kd;
  
  double _integral = 0.0;
  double _previousError = 0.0;
  double _derivative = 0.0;
  final List<double> _errorHistory = [];
  final int maxHistorySize;

  PIDController({
    required this.kp,
    required this.ki,
    required this.kd,
    this.maxHistorySize = 100,
  });

  double compute(double setpoint, double current, {double dt = 1.0}) {
    final error = setpoint - current;
    
    _errorHistory.add(error);
    if (_errorHistory.length > maxHistorySize) {
      _errorHistory.removeAt(0);
    }
    
    _integral += error * dt;
    _integral = _integral.clamp(-10.0, 10.0);
    
    _derivative = dt > 0 ? (error - _previousError) / dt : 0.0;
    _previousError = error;
    
    final p = kp * error;
    final i = ki * _integral;
    final d = kd * _derivative;
    
    return (p + i + d).clamp(-1.0, 1.0);
  }

  void reset() {
    _integral = 0.0;
    _previousError = 0.0;
    _derivative = 0.0;
    _errorHistory.clear();
  }

  double get integral => _integral;
  double get derivative => _derivative;
  double get previousError => _previousError;
  List<double> get errorHistory => List.unmodifiable(_errorHistory);

  Map<String, double> getDebugInfo(double setpoint, double current) {
    final error = setpoint - current;
    return {
      'error': error,
      'integral': _integral,
      'derivative': _derivative,
      'kp_term': kp * error,
      'ki_term': ki * _integral,
      'kd_term': kd * _derivative,
    };
  }
}

class AdaptivePIDController {
  late PIDController _controller;
  final double initialKp;
  final double initialKi;
  final double initialKd;
  final double adaptationRate;
  
  final List<double> _performanceHistory = [];
  final int performanceWindowSize;

  AdaptivePIDController({
    this.initialKp = 1.0,
    this.initialKi = 0.1,
    this.initialKd = 0.01,
    this.adaptationRate = 0.05,
    this.performanceWindowSize = 20,
  }) {
    _controller = PIDController(
      kp: initialKp,
      ki: initialKi,
      kd: initialKd,
    );
  }

  double compute(double setpoint, double current, {double dt = 1.0}) {
    final output = _controller.compute(setpoint, current, dt: dt);
    
    final error = (setpoint - current).abs();
    _performanceHistory.add(error);
    if (_performanceHistory.length > performanceWindowSize) {
      _performanceHistory.removeAt(0);
    }
    
    if (_performanceHistory.length >= performanceWindowSize) {
      _adaptParameters();
    }
    
    return output;
  }

  void _adaptParameters() {
    final recentPerformance = _performanceHistory.sublist(
      math.max(0, _performanceHistory.length - 5),
    );
    final oldPerformance = _performanceHistory.sublist(
      0,
      math.min(5, _performanceHistory.length ~/ 2),
    );
    
    final recentAvg = recentPerformance.reduce((a, b) => a + b) / recentPerformance.length;
    final oldAvg = oldPerformance.reduce((a, b) => a + b) / oldPerformance.length;
    
    final performanceRatio = oldAvg > 0 ? recentAvg / oldAvg : 1.0;
    
    double kpAdjustment = 1.0;
    double kiAdjustment = 1.0;
    double kdAdjustment = 1.0;
    
    if (performanceRatio > 1.2) {
      kpAdjustment = 1.0 + adaptationRate;
      kiAdjustment = 1.0 - adaptationRate * 0.5;
    } else if (performanceRatio < 0.8) {
      kpAdjustment = 1.0 - adaptationRate * 0.5;
      kiAdjustment = 1.0 + adaptationRate * 0.3;
    }
    
    final currentKp = _controller.kp;
    final currentKi = _controller.ki;
    final currentKd = _controller.kd;
    
    _controller = PIDController(
      kp: currentKp * kpAdjustment,
      ki: currentKi * kiAdjustment,
      kd: currentKd * kdAdjustment,
    );
  }

  void reset() {
    _controller.reset();
    _performanceHistory.clear();
  }

  Map<String, double> get parameters => {
    'kp': _controller.kp,
    'ki': _controller.ki,
    'kd': _controller.kd,
  };

  void setParameters({double? kp, double? ki, double? kd}) {
    _controller = PIDController(
      kp: kp ?? initialKp,
      ki: ki ?? initialKi,
      kd: kd ?? initialKd,
    );
  }
}

class BioRhythmController {
  final AdaptivePIDController _energyController;
  final AdaptivePIDController _socialController;
  final AdaptivePIDController _entropyController;
  
  final double _baseEnergyDecayRate;
  final double _baseSocialDecayRate;
  final double _baseEntropyGrowthRate;

  BioRhythmController({
    double energyKp = 1.0,
    double energyKi = 0.1,
    double energyKd = 0.01,
    double socialKp = 0.8,
    double socialKi = 0.05,
    double socialKd = 0.005,
    double entropyKp = 0.5,
    double entropyKi = 0.02,
    double entropyKd = 0.01,
    double baseEnergyDecayRate = 0.001,
    double baseSocialDecayRate = 0.0005,
    double baseEntropyGrowthRate = 0.0002,
  })  : _energyController = AdaptivePIDController(
          initialKp: energyKp,
          initialKi: energyKi,
          initialKd: energyKd,
        ),
        _socialController = AdaptivePIDController(
          initialKp: socialKp,
          initialKi: socialKi,
          initialKd: socialKd,
        ),
        _entropyController = AdaptivePIDController(
          initialKp: entropyKp,
          initialKi: entropyKi,
          initialKd: entropyKd,
        ),
        _baseEnergyDecayRate = baseEnergyDecayRate,
        _baseSocialDecayRate = baseSocialDecayRate,
        _baseEntropyGrowthRate = baseEntropyGrowthRate;

  Map<String, double> update({
    required double currentEnergy,
    required double currentSocial,
    required double currentEntropy,
    required bool isInteracting,
    required bool isResting,
    required double interactionIntensity,
    double dt = 1.0,
  }) {
    double targetEnergy = isResting ? 1.0 : 0.7;
    double targetSocial = isInteracting ? 0.3 : 0.6;
    double targetEntropy = 0.2;
    
    double energyDelta = _energyController.compute(
      targetEnergy,
      currentEnergy,
      dt: dt,
    );
    
    double socialDelta = _socialController.compute(
      targetSocial,
      currentSocial,
      dt: dt,
    );
    
    double entropyDelta = _entropyController.compute(
      targetEntropy,
      currentEntropy,
      dt: dt,
    );
    
    double newEnergy = currentEnergy;
    double newSocial = currentSocial;
    double newEntropy = currentEntropy;
    
    if (isResting) {
      newEnergy = (currentEnergy + 0.01 * dt).clamp(0.0, 1.0);
      newEntropy = (currentEntropy - 0.005 * dt).clamp(0.0, 1.0);
    } else {
      newEnergy = (currentEnergy - _baseEnergyDecayRate * dt - interactionIntensity * 0.01)
          .clamp(0.0, 1.0);
    }
    
    if (isInteracting) {
      newSocial = (currentSocial - interactionIntensity * 0.005 * dt).clamp(0.0, 1.0);
      newEntropy = (currentEntropy + interactionIntensity * 0.002 * dt).clamp(0.0, 1.0);
    } else {
      newSocial = (currentSocial + _baseSocialDecayRate * dt).clamp(0.0, 1.0);
    }
    
    newEnergy = (newEnergy + energyDelta * 0.1).clamp(0.0, 1.0);
    newSocial = (newSocial + socialDelta * 0.1).clamp(0.0, 1.0);
    newEntropy = (newEntropy + entropyDelta * 0.1).clamp(0.0, 1.0);
    
    return {
      'energy': newEnergy,
      'social': newSocial,
      'entropy': newEntropy,
      'energy_delta': energyDelta,
      'social_delta': socialDelta,
      'entropy_delta': entropyDelta,
    };
  }

  void reset() {
    _energyController.reset();
    _socialController.reset();
    _entropyController.reset();
  }

  Map<String, Map<String, double>> getParameters() {
    return {
      'energy': _energyController.parameters,
      'social': _socialController.parameters,
      'entropy': _entropyController.parameters,
    };
  }
}
