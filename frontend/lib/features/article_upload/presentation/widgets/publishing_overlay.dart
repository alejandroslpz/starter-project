import 'package:flutter/material.dart';

class PublishingOverlay extends StatelessWidget {
  const PublishingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x80000000),
      child: AbsorbPointer(
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Publishing your article…'),
                  SizedBox(height: 4),
                  Text(
                    'Uploading thumbnail and saving',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
