import 'package:carlbl_gherkin/gherkin.dart';

import '../../calculator.dart';

class CalculatorWorld extends World {
  final Calculator calculator = Calculator();

  @override
  void dispose() {
    calculator.dispose();
  }
}
