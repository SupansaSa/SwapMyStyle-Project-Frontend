import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? textEditingController;
  final bool? obscureText;
  final Widget? suffixIcon;
  final String? iconForm;
  final Widget? prefixIcon;
  final int? maxLines;
  final TextInputType? keyboardType; // เพิ่มพารามิเตอร์ keyboardType

  const CustomTextField({
    Key? key,
    this.title,
    this.hintText,
    this.textEditingController,
    this.obscureText,
    this.suffixIcon,
    this.iconForm,
    this.prefixIcon,
    this.maxLines,
    this.keyboardType, // รับพารามิเตอร์ keyboardType ถ้ามี
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? 'Change title',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          height: maxLines != null
              ? maxLines! * 24.0
              : 45, // Adjust height based on maxLines
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            children: [
              prefixIcon ?? const SizedBox(),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  style: const TextStyle(),
                  obscureText: obscureText ?? false,
                  maxLines: maxLines ?? 1, // Set the maxLines property here
                  keyboardType:
                      keyboardType, // ส่งค่าพารามิเตอร์ keyboardType ไปที่ TextField
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText ?? 'Type your text...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: suffixIcon ?? const SizedBox(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}