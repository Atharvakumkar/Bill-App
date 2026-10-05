class NumberToWords {
  static const List<String> _ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
  ];

  static const List<String> _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];

  static String convert(int number) {
    if (number == 0) return 'Zero Rupees';

    String words = '';

    if ((number / 10000000).floor() > 0) {
      words += '${convert((number / 10000000).floor()).replaceAll(" Rupees", "")} Crore ';
      number %= 10000000;
    }

    if ((number / 100000).floor() > 0) {
      words += '${convert((number / 100000).floor()).replaceAll(" Rupees", "")} Lakh ';
      number %= 100000;
    }

    if ((number / 1000).floor() > 0) {
      words += '${convert((number / 1000).floor()).replaceAll(" Rupees", "")} Thousand ';
      number %= 1000;
    }

    if ((number / 100).floor() > 0) {
      words += '${convert((number / 100).floor()).replaceAll(" Rupees", "")} Hundred ';
      number %= 100;
    }

    if (number > 0) {
      if (number < 20) {
        words += _ones[number];
      } else {
        words += _tens[(number / 10).floor()];
        if ((number % 10) > 0) {
          words += ' ${_ones[number % 10]}';
        }
      }
    }

    return '${words.trim()} Rupees';
  }
}
