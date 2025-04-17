import 'package:flutter/material.dart';

class FeedbackButtons extends StatelessWidget {
  final bool hasFeedback;
  final int? currentFeedback;
  final Function(int rating) onFeedback;

  const FeedbackButtons({
    super.key,
    required this.onFeedback,
    this.hasFeedback = false,
    this.currentFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.thumb_up,
            color: currentFeedback == 1 ? Colors.green : Colors.grey,
            size: 20,
          ),
          onPressed: hasFeedback 
              ? null 
              : () => onFeedback(1),
          tooltip: 'Util',
        ),
        IconButton(
          icon: Icon(
            Icons.thumb_down,
            color: currentFeedback == 0 ? Colors.red : Colors.grey,
            size: 20,
          ),
          onPressed: hasFeedback 
              ? null 
              : () => onFeedback(0),
          tooltip: 'No util',
        ),
      ],
    );
  }
}