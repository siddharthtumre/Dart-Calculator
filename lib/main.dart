import 'dart:html';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String output = "0";
  String expr = "";

  String calculate(String input) {
    String result = "";
    final builder = ExpressionBuilder<num>();

    builder.group()
      ..primitive(digit()
          .plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten()
          .trim()
          .map(num.parse))
      ..wrapper(char('(').trim(), char(')').trim(), (l, a, r) => a);

    // Negation is a prefix operator
    builder.group()..prefix(char('-').trim(), (op, a) => -a);

    // Multiplication and addition are left-associative
    builder.group()
      ..left(char('*').trim(), (a, op, b) => a * b)
      ..left(char('/').trim(), (a, op, b) => a / b)
      ..left(char("%").trim(), (a, op, b) => a % b);
    builder.group()
      ..left(char('+').trim(), (a, op, b) => a + b)
      ..left(char('-').trim(), (a, op, b) => a - b);

    final parser = builder.build().end();

    if (parser.parse(input).isSuccess) {
      result = parser.parse(input).value.toString();
    } else {
      result = "Error";
    }

    return result;
  }

  buttonPressed(String buttonText) {
    if (buttonText == "AC") {
      setState(() {
        expr = "";
        output = "0";
      });
    } else if (buttonText == "=") {
      setState(() {
        output = calculate(expr);
        expr = "";
      });
    } else {
      setState(() {
        expr = expr + buttonText;
      });
    }
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: OutlineButton(
        padding: EdgeInsets.all(26),
        onPressed: () {
          buttonPressed(buttonText);
        },
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: Column(children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 12,
                ),
                alignment: Alignment.centerRight,
                child: Text(
                  output,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const Expanded(
              child: Divider(
                thickness: 5,
              ),
            ),
            Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 12,
                    ),
                    alignment: Alignment.centerRight,
                    child: Text(
                      expr,
                      style: TextStyle(
                        fontSize: 48,
                      ),
                    )),
                Row(
                  children: [
                    buildButton('('),
                    buildButton(')'),
                    buildButton('%'),
                    buildButton('AC')
                  ],
                ),
                Row(
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('/')
                  ],
                ),
                Row(
                  children: [
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('*')
                  ],
                ),
                Row(
                  children: [
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('-')
                  ],
                ),
                Row(
                  children: [
                    buildButton('0'),
                    buildButton('.'),
                    buildButton('='),
                    buildButton('+')
                  ],
                ),
              ],
            )
          ]),
        ));
  }
}
