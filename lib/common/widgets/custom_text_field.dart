import 'dart:math';

import 'package:demandium_provider/common/widgets/code_picker_widget.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? title;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final bool isPassword;
  final bool isShowBorder;
  final bool? isAutoFocus;
  final Function(String)? onSubmit;
  final bool isEnabled;
  final int? maxLines;
  final bool? isShowSuffixIcon;
  final TextCapitalization? capitalization;
  final Function(String text)? onChanged;
  final String? countryDialCode;
  final bool isCountryPickerEnabled;
  final Function(CountryCode countryCode)? onCountryChanged;
  final String? Function(String? )? onValidate;
  final bool contentPadding;
  final double borderRadius;
  final bool isRequired;
  final String? prefixIcon;
  final Widget? errorWidget;
  final Function()? onPressedSuffix;
  final Color? fillColor;
  final String? suffixIcon;

  const CustomTextField(
      {super.key, this.hintText = '',
        this.controller,
        this.focusNode,
        this.nextFocus,
        this.isEnabled = true,
        this.inputType = TextInputType.text,
        this.inputAction = TextInputAction.next,
        this.maxLines = 1,
        this.isShowSuffixIcon = false,
        this.onSubmit,
        this.capitalization = TextCapitalization.none,
        this.isPassword = false,
        this.isShowBorder = false,
        this.isAutoFocus = false,
        this.countryDialCode,
        this.isCountryPickerEnabled = true,
        this.onCountryChanged,
        this.onChanged,
        this.onValidate,
        this.title,
        this.contentPadding= true,
        this.borderRadius = 10,
        this.isRequired = true,
        this.prefixIcon,
        this.errorWidget, this.onPressedSuffix, this.fillColor, this.suffixIcon,
      });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}


class CustomTextFieldState extends State<CustomTextField> {

  void onFocusChanged(){
    FocusScope.of(context).unfocus();
    FocusScope.of(Get.context!).requestFocus(widget.focusNode);
    widget.focusNode?.addListener(() {
      setState(() {
      });
    });
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange:  (v){},
      child: TextFormField(

        onTap: onFocusChanged,
        maxLines: widget.maxLines,
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: robotoRegular.copyWith(fontSize:Dimensions.fontSizeDefault,color: widget.isEnabled==false?Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6):Theme.of(context).textTheme.bodyLarge!.color),
        textInputAction: widget.inputAction,
        keyboardType: widget.inputType,
        cursorColor: Theme.of(context).hintColor,
        textCapitalization: widget.capitalization!,
        enabled: widget.isEnabled,
        autofocus: widget.isAutoFocus!,

        autofillHints: widget.inputType == TextInputType.name ? [AutofillHints.name]
            : widget.inputType == TextInputType.emailAddress ? [AutofillHints.email]
            : widget.inputType == TextInputType.phone ? [AutofillHints.telephoneNumber]
            : widget.inputType == TextInputType.streetAddress ? [AutofillHints.fullStreetAddress]
            : widget.inputType == TextInputType.url ? [AutofillHints.url]
            : widget.inputType == TextInputType.visiblePassword ? [AutofillHints.password] : null,
        obscureText: widget.isPassword ? _obscureText : false,
        inputFormatters: widget.inputType == TextInputType.phone
            ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))]
            : widget.inputType == TextInputType.datetime
            ? [_DateInputFormatter()] : null,

        decoration: InputDecoration(
          isCollapsed: widget.focusNode?.hasFocus == true || widget.isEnabled == true || widget.controller!.text.isNotEmpty ? false: true,
          isDense: widget.focusNode?.hasFocus == true || (widget.nextFocus != null && widget.nextFocus?.hasFocus == true) || widget.controller!.text.isNotEmpty ? false : true,
          label: widget.countryDialCode == null  ? Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
            Text(trLabel(widget.title),
              style: ((widget.focusNode?.hasFocus == true || widget.controller!.text.isNotEmpty ))
                  ? robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: widget.errorWidget!=null
                    ? Theme.of(context).colorScheme.error
                    : ((widget.focusNode?.hasFocus == true || widget.controller!.text.isNotEmpty )
                    &&  widget.isEnabled) ? Theme.of(context).textTheme.bodyLarge?.color
                    :  Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5) ,
              ) :
              robotoMedium.copyWith(
                fontSize:  Dimensions.fontSizeDefault,
                color: widget.errorWidget != null
                    ? Theme.of(context).colorScheme.error
                    : ((widget.focusNode?.hasFocus == true || widget.controller!.text.isNotEmpty )
                    &&  widget.isEnabled) ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5) ,
              ),
            ),

            if(widget.isRequired)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text("*", style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),),
              )
          ],) : null,

          labelStyle: widget.countryDialCode == null ? robotoMedium.copyWith(fontSize: 20) : null,

          prefixIcon: widget.prefixIcon != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: 5),
            child: Image.asset(widget.prefixIcon!, width: 20,height: 20, color: Theme.of(context).colorScheme.primary.withValues(alpha:0.4),),
          ) : widget.countryDialCode != null ? Padding( padding:  EdgeInsets.only(left: widget.isShowBorder == true ?  10: 0, top: 5),
            child: CodePickerWidget(
              onChanged: widget.onCountryChanged,
              initialSelection: widget.countryDialCode,
              favorite: [widget.countryDialCode ?? ""],
              enabled: widget.isCountryPickerEnabled && widget.isEnabled,
              showDropDownButton: widget.isCountryPickerEnabled,
              padding: EdgeInsets.zero,
              showFlagMain: true,
              flagWidth: 27,
              dialogSize: Size(Dimensions.webMaxWidth/2, Get.height*0.6),
              dialogBackgroundColor: Theme.of(context).cardColor,
              barrierColor: Get.isDarkMode?Colors.black.withValues(alpha:0.4):null,
              textStyle: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge, color: widget.isEnabled == false ?Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha:0.6) :Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ): null,
          contentPadding:  EdgeInsets.only(
            top: widget.countryDialCode != null ? Dimensions.paddingSizeDefault : 0.0,
            bottom: Dimensions.paddingSizeExtraSmall,
            left:   0,
            right:  0,
          ),
          
          focusedBorder : widget.isShowBorder ? OutlineInputBorder(
            borderSide: BorderSide(color:  Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ) : UnderlineInputBorder(borderSide: BorderSide(color:  Theme.of(context).primaryColor)),

          enabledBorder :  UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.4))),
          errorBorder :  UnderlineInputBorder(borderSide: BorderSide(color:  Theme.of(context).colorScheme.error)),
          focusedErrorBorder :  UnderlineInputBorder(borderSide: BorderSide(color:  Theme.of(context).colorScheme.error)),
          border :  UnderlineInputBorder(borderSide: BorderSide(color:  Theme.of(context).colorScheme.error)),
          disabledBorder :  UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.4))),



          hintText: widget.hintText != null && widget.hintText!.isNotEmpty ? trLabel(widget.hintText) : widget.hintText,
          hintStyle: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor.withValues(alpha:Get.isDarkMode ? .5:1)),

          suffixIconConstraints: widget.isPassword ? BoxConstraints(
            minHeight: widget.focusNode?.hasFocus == true || widget.controller!.text.isNotEmpty ? 40 : 20,
          ): null,

          suffixIcon: widget.suffixIcon!=null?
          GestureDetector(
            onTap: widget.onPressedSuffix,
            child: Stack(
              alignment: widget.focusNode?.hasFocus == true || widget.controller!.text.isNotEmpty ? Alignment.bottomRight : Alignment.centerRight,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  child: Image.asset(widget.suffixIcon!, height: 22, width: 22,color: Theme.of(context).primaryColor,),
                ),
              ],
            ),
          ) :
          widget.isPassword ?
          InkWell(
            onTap: _toggle,
            child: Stack(
              alignment: widget.focusNode?.hasFocus == true  || widget.controller!.text.isNotEmpty? Alignment.bottomCenter : Alignment.bottomRight,
              children: [
                Icon(_obscureText ? Icons.visibility_off : Icons.visibility,size: 20, color: Theme.of(context).hintColor.withValues(alpha:0.3)),
              ],
            ),
          ) : null,
        ),
        onFieldSubmitted: (text) => widget.nextFocus != null ?
        FocusScope.of(context).requestFocus(widget.nextFocus) :
        widget.onSubmit != null ? widget.onSubmit!(text) : null,
        onChanged: widget.onChanged,
        validator: widget.onValidate,

      ),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}

class _DateInputFormatter extends TextInputFormatter {
  final String _placeholder = '--/----';
  TextEditingValue? _lastNewValue;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.isEmpty) {
      oldValue = oldValue.copyWith(
        text: _placeholder,
      );
      newValue = newValue.copyWith(
        text: _fillInputToPlaceholder(newValue.text),
      );
      return newValue;
    }

    if (newValue == _lastNewValue) {
      return oldValue;
    }
    _lastNewValue = newValue;

    int offset = newValue.selection.baseOffset;

    if (offset > 7) {
      return oldValue;
    }

    if (oldValue.text == newValue.text && oldValue.text.isNotEmpty) {
      return newValue;
    }

    final String oldText = oldValue.text;
    final String newText = newValue.text;
    String? resultText;

    int index = _indexOfDifference(newText, oldText);
    if (oldText.length < newText.length) {

      String newChar = newText[index];
      if (index == 2 ) {
        index++;
        offset++;
      }
      resultText = oldText.replaceRange(index, index + 1, newChar);
      if (offset == 2) {
        offset++;
      }
    } else if (oldText.length > newText.length) {
      if (oldText[index] != '/') {
        resultText = oldText.replaceRange(index, index + 1, '-');
        if (offset == 2) {
          offset--;
        }
      } else {
        resultText = oldText;
      }
    }

    return oldValue.copyWith(
      text: resultText,
      selection: TextSelection.collapsed(offset: offset),
      composing: defaultTargetPlatform == TargetPlatform.iOS
          ? const TextRange(start: 0, end: 0)
          : TextRange.empty,
    );
  }

  int _indexOfDifference(String? cs1, String? cs2) {
    if (cs1 == cs2) {
      return indexNotFound;
    }
    if (cs1 == null || cs2 == null) {
      return 0;
    }
    int i;
    for (i = 0; i < cs1.length && i < cs2.length; ++i) {
      if (cs1[i] != cs2[i]) {
        break;
      }
    }
    if (i < cs2.length || i < cs1.length) {
      return i;
    }
    return indexNotFound;
  }

  String _fillInputToPlaceholder(String? input) {
    if (input == null || input.isEmpty) {
      return _placeholder;
    }
    String result = _placeholder;
    final index = [0, 1, 3, 4, 6, 7, 8, 9];
    final length = min(index.length, input.length);
    for (int i = 0; i < length; i++) {
      result = result.replaceRange(index[i], index[i] + 1, input[i]);
    }
    return result;
  }
}