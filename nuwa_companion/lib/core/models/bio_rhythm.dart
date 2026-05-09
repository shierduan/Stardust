class BioRhythm {
  final double energy;
  final double social;
  final double systemEntropy;
  final double lastUpdateTimestamp;

  const BioRhythm({
    required this.energy,
    required this.social,
    required this.systemEntropy,
    required this.lastUpdateTimestamp,
  });

  factory BioRhythm.initial() {
    return BioRhythm(
      energy: 1.0,
      social: 0.5,
      systemEntropy: 0.0,
      lastUpdateTimestamp: DateTime.now().millisecondsSinceEpoch / 1000,
    );
  }

  String get energyStatus {
    if (energy > 0.7) return '充沛';
    if (energy > 0.4) return '良好';
    if (energy > 0.2) return '疲惫';
    return '精疲力竭';
  }

  String get socialStatus {
    if (social > 0.7) return '渴望社交';
    if (social > 0.4) return '适中';
    if (social > 0.2) return '需要独处';
    return '渴望独处';
  }

  String get entropyStatus {
    if (systemEntropy < 0.3) return '稳定';
    if (systemEntropy < 0.6) return '波动';
    if (systemEntropy < 0.8) return '混乱';
    return '严重混乱';
  }

  bool get isHealthy => systemEntropy < 0.5 && energy > 0.3;

  bool get needsRest => energy < 0.2;

  bool get needsInteraction => social > 0.7;

  BioRhythm copyWith({
    double? energy,
    double? social,
    double? systemEntropy,
    double? lastUpdateTimestamp,
  }) {
    return BioRhythm(
      energy: (energy ?? this.energy).clamp(0.0, 1.0),
      social: (social ?? this.social).clamp(0.0, 1.0),
      systemEntropy: (systemEntropy ?? this.systemEntropy).clamp(0.0, 1.0),
      lastUpdateTimestamp: lastUpdateTimestamp ?? this.lastUpdateTimestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'energy': energy,
    'social': social,
    'system_entropy': systemEntropy,
    'last_update_timestamp': lastUpdateTimestamp,
  };

  factory BioRhythm.fromJson(Map<String, dynamic> json) {
    return BioRhythm(
      energy: (json['energy'] as num?)?.toDouble() ?? 1.0,
      social: (json['social'] as num?)?.toDouble() ?? 0.5,
      systemEntropy: (json['system_entropy'] as num?)?.toDouble() ?? 0.0,
      lastUpdateTimestamp: (json['last_update_timestamp'] as num?)?.toDouble() ??
          DateTime.now().millisecondsSinceEpoch / 1000,
    );
  }
}
