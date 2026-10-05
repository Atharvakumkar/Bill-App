import '../models/bill_item.dart';

class Calculations {
  static double calculateSubtotal(List<BillItem> items) {
    return items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }

  static double calculateTotalDiscount(List<BillItem> items, double additionalDiscount) {
    double itemsDiscount = items.fold(0, (sum, item) => sum + item.discount);
    return itemsDiscount + additionalDiscount;
  }

  static double calculateGrandTotal(List<BillItem> items, double additionalDiscount) {
    double subtotal = calculateSubtotal(items);
    double totalDiscount = calculateTotalDiscount(items, additionalDiscount);
    return subtotal - totalDiscount;
  }
}
