import '../models/bill_item.dart';

class Calculations {
  static double calculateSubtotal(List<BillItem> items) {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  static double calculateGrandTotal(double subtotal, double discount) {
    return subtotal - discount;
  }
}
