import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:tracking_app/util/dimensions.dart';

class FixedTextField extends StatelessWidget {
  const FixedTextField(
      {Key? key,
      this.label = "",
      this.function,
      this.inputType,
      this.errorLabel,
      this.controller,
      this.onSubmit,
      this.nextFocus,
      this.prefixIcon,
      this.suffixIcon,
      this.enable = true,
      this.autoFocus = false,
      this.hint = "",
      this.obSecure = false,
      this.focusNode})
      : super(key: key);
  final String? label;
  final Function(String)? function;
  final TextInputType? inputType;
  final String? errorLabel;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final FocusNode? nextFocus;
  final Function? onSubmit;
  final IconButton? suffixIcon;
  final Icon? prefixIcon;
  final bool? obSecure;
  final String? hint;
  final bool? autoFocus;
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: TextFormField(

              enabled: enable,
              autofocus: autoFocus!,
              obscureText: obSecure!,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(4),
                  hintStyle: TextStyle(
                      color: const Color(0xff008d36),
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.fontSizeLarge),
                  suffixIcon: suffixIcon,
                  prefixIcon: prefixIcon,
                  hintText: hint,
                  label: Text(
                    label!,
                    style: TextStyle(
                        color: const Color(0xff008d36),
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.fontSizeLarge),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xff008d36),
                      )),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xff008d36),
                      ))),
              controller: controller,
              focusNode: focusNode,
              keyboardType: inputType,
              inputFormatters: inputType == TextInputType.phone
                  ? <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9+]'))
                    ]
                  : null,
              onChanged: function,
              showCursor: true,
              cursorColor: Theme.of(context).primaryColor,
              onFieldSubmitted: (text) => nextFocus != null
                  ? FocusScope.of(context).requestFocus(nextFocus)
                  : onSubmit != null
                      ? onSubmit!(text)
                      : null,
            ),
          ),
          if (errorLabel != null && errorLabel!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: ShowUpAnimation(
                child: Text(
                  '$errorLabel',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.redAccent[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
