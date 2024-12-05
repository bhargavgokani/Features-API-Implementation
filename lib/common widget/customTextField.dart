import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final bool isObscure;
  final Function? isVisible;
  final String? Function(String?)? validator;

  CustomTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.isObscure = false,
    this.validator,
    this.suffixIcon,
    this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        // autofocus: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF3F5769), // Slightly darker gray for contrast
            fontSize: 16,
          ),
          border: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          fillColor: Color(0xFFF7F8FA),
          filled: true,
          prefixIcon: Icon(
            prefixIcon,
            color: Color(0xFF3F5769),
          ),
          suffixIcon: IconButton(
              onPressed: () {
                if (isVisible != null) isVisible!();
              },
              icon: Icon(
                suffixIcon,
                color: Color(0xFF3F5769),
              )),
          contentPadding: EdgeInsets.all(10),
        ),
        validator: validator,
      ),
    );
  }
}
