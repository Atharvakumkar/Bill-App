import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class BillSummary extends StatelessWidget {
  final double subtotal;
  final double grandTotal;
  final TextEditingController discountController;
  final Function(double) onDiscountChanged;

  const BillSummary({
    super.key,
    required this.subtotal,
    required this.grandTotal,
    required this.discountController,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 16)),
                Text(CurrencyFormatter.format(subtotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount (₹)', style: TextStyle(fontSize: 16)),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: discountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      double d = double.tryParse(val) ?? 0;
                      onDiscountChanged(d);
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(CurrencyFormatter.format(grandTotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
