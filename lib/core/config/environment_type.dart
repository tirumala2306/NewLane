enum EnvironmentType {
  development,
  staging,
  production;

  bool get isProduction => this == EnvironmentType.production;

  static EnvironmentType fromName(String rawValue) {
    return EnvironmentType.values.firstWhere(
      (value) => value.name == rawValue,
      orElse: () => EnvironmentType.development,
    );
  }
}
