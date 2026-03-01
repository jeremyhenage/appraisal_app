import 'package:flutter/material.dart';
import 'package:appraisal_app/features/appraisal/domain/entities/appraisal_result.dart';
import 'package:appraisal_app/features/appraisal/presentation/widgets/liquidity_indicator.dart';

class DealDashboardScreen extends StatelessWidget {
  final AppraisalResult result;

  const DealDashboardScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEAL DASHBOARD'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card (Make/Model/Liquidity)
            _buildHeaderCard(context, result),
            const SizedBox(height: 16),

            // Valuation Card
            _buildValuationCard(context, result),
            const SizedBox(height: 16),

            // Confidence & Comparables
            _buildDetailsCard(context, result),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("RE-SCAN"),
                  ),
                ),
                const SizedBox(width: 16),
                 Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save or Share logic
                    },
                    child: const Text("SAVE DEAL"),
                  ),
                ),
              ],
            )
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
      color: Theme.of(context).primaryColor.withAlpha(20), // 0.08 * 255 ~= 20
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).primaryColor)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('ESTIMATED VALUE', style: TextStyle(color: Colors.white70, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(
              '\$${result.minPrice.toStringAsFixed(0)} - \$${result.maxPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                shadows: [Shadow(color: Theme.of(context).primaryColor, blurRadius: 10)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, AppraisalResult result) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CONFIDENCE:', style: TextStyle(color: Colors.white70)),
                Text(result.confidence, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('COMPARABLES:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            ...result.comparables.map((comp) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, color: Colors.white54),
                  Expanded(child: Text(comp, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }


}
