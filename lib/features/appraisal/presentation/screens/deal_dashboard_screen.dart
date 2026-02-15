import 'package:flutter/material.dart';
import 'package:appraisal_app/features/appraisal/domain/entities/appraisal_result.dart';
import 'package:appraisal_app/features/appraisal/presentation/widgets/liquidity_indicator.dart';

class DealDashboardScreen extends StatelessWidget {
  const DealDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, this would come from a Provider/Bloc
    final result = AppraisalResult.mock();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEAL DASHBOARD'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            _buildHeaderCard(context, result),
            const SizedBox(height: 16),
            
            // Valuation Card
            _buildValuationCard(context, result),
            const SizedBox(height: 16),

            // Comparables
            _buildComparablesList(context, result),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppraisalResult result) {
    return Card(
      elevation: 4,
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              result.make.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              result.model.toUpperCase(),
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LIQUIDITY:', style: TextStyle(color: Colors.white70)),
                LiquidityIndicator(score: result.liquidityScore),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuationCard(BuildContext context, AppraisalResult result) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTIMATED VALUE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${result.minPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('-', style: Theme.of(context).textTheme.headlineSmall),
                ),
                Text(
                  '\$${result.maxPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Confidence: ${result.confidence}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparablesList(BuildContext context, AppraisalResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'MARKET COMPARABLES',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ),
        ...result.comparables.map((comp) => Card(
              color: Colors.black26,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.cyan),
                title: Text(comp, style: const TextStyle(color: Colors.white)),
              ),
            )),
      ],
    );
  }
}
