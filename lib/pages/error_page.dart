import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Object error;

  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERROR'),
        centerTitle: true,
      ),
      body: Center(child: Text(error.toString())),
    );
  }
}
