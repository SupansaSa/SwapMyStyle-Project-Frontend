import 'package:flutter/material.dart';
import 'package:myapp/thems/theme.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Function(BuildContext) onPressed;
  final Color? color; 
  final double? width; 

  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.color, 
    this.width, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // กำหนดความกว้างของ Container
      child: ElevatedButton(
        onPressed: () {
          onPressed(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? primaryColor, 
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: whiteTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
