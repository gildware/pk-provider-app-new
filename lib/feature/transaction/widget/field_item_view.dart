import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class FieldItemView extends StatelessWidget {
  final MethodField? methodField;
  final Map<String, TextEditingController>? textControllers;
  final Map<String, FocusNode>? focusNodes;
  const FieldItemView({super.key, this.methodField, this.textControllers, this.focusNodes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        CustomTextField(
          controller: textControllers![methodField!.inputName],
          focusNode: focusNodes![methodField!.inputName],
          hintText:  methodField!.placeholder??'',
          inputType:  _getType(methodField!.inputType ?? ""),
          isPassword: methodField!.inputType == 'password',
          title: methodField!.inputName!.replaceAll('_', ' ').formattedUpperCase(),
          isRequired: methodField?.isRequired == 1,
          onValidate: (value){
            if(methodField?.isRequired != 1) return null;
            return FormValidationHelper().validateDynamicTextFiled(value!, methodField!.placeholder?.replaceAll("_", " ").capitalizeFirst ?? "");
          },
        ),
        if(_getType(methodField!.inputType ?? "") != TextInputType.datetime) const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),
      ],
    );
  }

  TextInputType _getType(String type) {
    switch(type) {
      case 'number': return TextInputType.number;
      case 'date': return TextInputType.datetime;
      case 'password': return TextInputType.visiblePassword;
      case 'email': return  TextInputType.emailAddress;
      case 'phone': return TextInputType.phone;
      default: return TextInputType.text;
    }

  }
}

extension StringExtension on String {
  String formattedUpperCase() => replaceAllMapped(
      RegExp(r'(?<= |-|^).'), (match) => match[0]!.toUpperCase());
}

const indexNotFound = -1;


