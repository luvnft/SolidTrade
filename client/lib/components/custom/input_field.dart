import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solidtrade/components/base/st_widget.dart';

class InputField extends StatelessWidget with STWidget {
  InputField({required this.labelText, required this.hintText, required this.controller, this.inputFormatters, Key? key}) : super(key: key);
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final String labelText;
  final String hintText;

  InputBorder getInputBorderDecoration() {
    return OutlineInputBorder(borderSide: BorderSide(color: colors.softBackground, width: 2), borderRadius: BorderRadius.circular(10));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(margin: const EdgeInsets.all(8), child: Text(labelText, style: const TextStyle(fontWeight: FontWeight.w600))),
        TextFormField(
          inputFormatters: inputFormatters,
          controller: controller,
          cursorColor: colors.foreground,
          decoration: InputDecoration(
            focusedBorder: getInputBorderDecoration(),
            enabledBorder: getInputBorderDecoration(),
            border: getInputBorderDecoration(),
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}
