import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechNova Calculator',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      home: CalculatorScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String expression = '';
  String firstNumber = '';
  String selectedOperator = '';

  bool shouldClearDisplay = false;
  bool resultWasCalculated = false;

  void numberPressed(String number) {
    setState(() {
      if (resultWasCalculated) {
        display = number;
        expression = '';
        firstNumber = '';
        selectedOperator = '';
        shouldClearDisplay = false;
        resultWasCalculated = false;
        return;
      }

      if (display == '0' || shouldClearDisplay) {
        display = number;
        shouldClearDisplay = false;
      } else {
        display += number;
      }

      updateExpressionWhileTyping();
    });
  }

  void decimalPressed() {
    setState(() {
      if (resultWasCalculated) {
        display = '0.';
        expression = '';
        firstNumber = '';
        selectedOperator = '';
        shouldClearDisplay = false;
        resultWasCalculated = false;
        return;
      }

      if (shouldClearDisplay) {
        display = '0.';
        shouldClearDisplay = false;
      } else if (!display.contains('.')) {
        display += '.';
      }

      updateExpressionWhileTyping();
    });
  }

  void operatorPressed(String operator) {
    if (display == 'Error') {
      return;
    }

    if (selectedOperator.isNotEmpty &&
        !shouldClearDisplay &&
        !resultWasCalculated) {
      calculateResult();
    }

    setState(() {
      firstNumber = display;
      selectedOperator = operator;
      expression = '$firstNumber $selectedOperator';
      shouldClearDisplay = true;
      resultWasCalculated = false;
    });
  }

  void calculateResult() {
    if (firstNumber.isEmpty ||
        selectedOperator.isEmpty ||
        display == 'Error') {
      return;
    }

    final String secondNumberText = display;

    final double number1 = double.tryParse(firstNumber) ?? 0;
    final double number2 = double.tryParse(secondNumberText) ?? 0;

    double result = 0;

    switch (selectedOperator) {
      case '+':
        result = number1 + number2;
        break;

      case '-':
        result = number1 - number2;
        break;

      case '×':
        result = number1 * number2;
        break;

      case '÷':
        if (number2 == 0) {
          setState(() {
            expression =
            '$firstNumber $selectedOperator $secondNumberText = Error';
            display = 'Error';
            firstNumber = '';
            selectedOperator = '';
            shouldClearDisplay = true;
            resultWasCalculated = true;
          });
          return;
        }

        result = number1 / number2;
        break;
    }

    final String answer = formatResult(result);

    setState(() {
      expression =
      '$firstNumber $selectedOperator $secondNumberText = $answer';

      display = answer;
      firstNumber = '';
      selectedOperator = '';
      shouldClearDisplay = true;
      resultWasCalculated = true;
    });
  }

  String formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void updateExpressionWhileTyping() {
    if (firstNumber.isNotEmpty && selectedOperator.isNotEmpty) {
      expression = '$firstNumber $selectedOperator $display';
    }
  }

  void clearCalculator() {
    setState(() {
      display = '0';
      expression = '';
      firstNumber = '';
      selectedOperator = '';
      shouldClearDisplay = false;
      resultWasCalculated = false;
    });
  }

  void deleteLastCharacter() {
    setState(() {
      if (resultWasCalculated || display == 'Error') {
        display = '0';
        expression = '';
        firstNumber = '';
        selectedOperator = '';
        shouldClearDisplay = false;
        resultWasCalculated = false;
        return;
      }

      if (display.length <= 1 ||
          (display.startsWith('-') && display.length == 2)) {
        display = '0';
      } else {
        display = display.substring(0, display.length - 1);
      }

      updateExpressionWhileTyping();
    });
  }

  void toggleSign() {
    setState(() {
      if (display == '0' || display == 'Error') {
        return;
      }

      if (resultWasCalculated) {
        expression = '';
        firstNumber = '';
        selectedOperator = '';
        resultWasCalculated = false;
      }

      if (display.startsWith('-')) {
        display = display.substring(1);
      } else {
        display = '-$display';
      }

      updateExpressionWhileTyping();
    });
  }

  void percentagePressed() {
    if (display == 'Error') {
      return;
    }

    setState(() {
      final double value = double.tryParse(display) ?? 0;
      final String oldDisplay = display;
      final String result = formatResult(value / 100);

      display = result;

      if (firstNumber.isNotEmpty && selectedOperator.isNotEmpty) {
        expression = '$firstNumber $selectedOperator $oldDisplay%';
      } else {
        expression = '$oldDisplay% = $result';
        resultWasCalculated = true;
      }

      shouldClearDisplay = true;
    });
  }

  void buttonPressed(String text) {
    if (RegExp(r'^[0-9]$').hasMatch(text)) {
      numberPressed(text);
    } else if (text == '.') {
      decimalPressed();
    } else if (['+', '-', '×', '÷'].contains(text)) {
      operatorPressed(text);
    } else if (text == '=') {
      calculateResult();
    } else if (text == 'AC') {
      clearCalculator();
    } else if (text == '⌫') {
      deleteLastCharacter();
    } else if (text == '+/−') {
      toggleSign();
    } else if (text == '%') {
      percentagePressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isDarkMode
        ? const Color(0xFF101114)
        : const Color(0xFFF4F5F8);

    final Color displayColor =
    widget.isDarkMode ? const Color(0xFF181A20) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'TechNova Calculator',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Change theme',
            onPressed: widget.onThemeChanged,
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          widget.isDarkMode ? 0.25 : 0.08,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          expression,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 21,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.60),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          display,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    buildRow(['AC', '+/−', '%', '÷']),
                    buildRow(['7', '8', '9', '×']),
                    buildRow(['4', '5', '6', '-']),
                    buildRow(['1', '2', '3', '+']),
                    buildRow(['⌫', '0', '.', '=']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((text) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: CalculatorButton(
                text: text,
                onPressed: () => buttonPressed(text),
                isOperator: ['÷', '×', '-', '+', '='].contains(text),
                isAction: ['AC', '+/−', '%', '⌫'].contains(text),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOperator;
  final bool isAction;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isOperator,
    required this.isAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;

    if (isOperator) {
      backgroundColor =
          Theme.of(context).colorScheme.primary;

      foregroundColor =
          Theme.of(context).colorScheme.onPrimary;
    } else if (isAction) {
      backgroundColor = isDark
          ? const Color(0xFF30323A)
          : const Color(0xFFE1E4EA);

      foregroundColor =
          Theme.of(context).colorScheme.onSurface;
    } else {
      backgroundColor =
      isDark ? const Color(0xFF202228) : Colors.white;

      foregroundColor =
          Theme.of(context).colorScheme.onSurface;
    }

    return SizedBox.expand(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: isOperator ? 4 : 1,
          shadowColor: Colors.black.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: text == '+/−' ? 22 : 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}