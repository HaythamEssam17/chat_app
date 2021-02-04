import 'package:flutter/material.dart';

class CommonTextFormField {
  static Widget textFormField(
      {TextEditingController controller,
      String hintText,
      TextInputType textInputType,
      IconData prefixIconData,
      String Function(String) validator,
      Function(String) onSaved,
      Function(String) onChanged}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.red),
          labelText: hintText,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey, width: 1)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.green, width: 1),
          ),
          prefixIcon: Icon(prefixIconData),
          contentPadding: EdgeInsets.all(10)),
      keyboardType: textInputType,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}
