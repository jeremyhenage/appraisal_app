class AppraisalResult {
  final String make;
  final String model;
  final double minPrice;
  final double maxPrice;
  final String liquidityScore; // "High", "Medium", "Low"
  final String confidence;
  final List<String> comparables;

  const AppraisalResult({
    required this.make,
    required this.model,
    required this.minPrice,
    required this.maxPrice,
    required this.liquidityScore,
    required this.confidence,
    required this.comparables,
  });

  factory AppraisalResult.mock() {
    return const AppraisalResult(
      make: "Glock",
      model: "19 Gen 5",
      minPrice: 450.00,
      maxPrice: 550.00,
      liquidityScore: "High",
      confidence: "High",
      comparables: [
        "GunBroker: \$525.00",
        "Armslist: \$480.00",
        "Local Shop: \$450.00",
      ],
    );
  }

  factory AppraisalResult.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in a "result" key (e.g. direct curl vs callable)
    // Callable functions usually unwrap "result", so "json" is likely the data object.
    // Inspect specific keys to determine structure.

    // Helper to safely cast generic maps
    Map<String, dynamic> safeMap(dynamic val) {
      if (val is Map) {
        return Map<String, dynamic>.from(val);
      }
      return {};
    }

    final analysis = safeMap(json['analysis']);
    final valuation = safeMap(json['valuation']);

    // Helper to parse double safely
    double parseDouble(dynamic value, double fallback) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    }

    // Extract Valuation Data
    final double estimatedValue = parseDouble(valuation['estimated_value'], 0.0);
    final double wholesale = parseDouble(valuation['wholesale_price'], estimatedValue * 0.8);
    final double mapPrice = parseDouble(valuation['map_price'], estimatedValue * 1.2);
    final double confidenceScore = parseDouble(valuation['valuation_confidence'], 0.0);

    // Map Confidence Score to String
    String mapConfidence(double score) {
      if (score >= 0.9) return "High";
      if (score >= 0.7) return "Medium";
      return "Low";
    }

    // Derive Liquidity from Production Status
    // If current production, likely high liquidity.
    final bool isCurrent = analysis['is_current_production'] as bool? ?? false;
    final String liquidity = isCurrent ? "High" : "Medium";

    return AppraisalResult(
      make: analysis['make'] as String? ?? 'Unknown',
      model: analysis['model'] as String? ?? 'Unknown',
      minPrice: wholesale > 0 ? wholesale : estimatedValue * 0.8,
      maxPrice: mapPrice > 0 ? mapPrice : estimatedValue * 1.2,
      liquidityScore: liquidity,
      confidence: mapConfidence(confidenceScore),
      comparables: (valuation['comparables'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
