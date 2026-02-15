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
}
