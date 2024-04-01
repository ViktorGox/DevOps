import 'package:flutter/material.dart';

class ErrorComponent extends StatelessWidget {
  final String error;

  const ErrorComponent({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(error),
        ],
      ),
    );
  }
}