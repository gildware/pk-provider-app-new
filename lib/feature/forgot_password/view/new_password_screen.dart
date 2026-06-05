import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class NewPassScreen extends StatefulWidget {
  final String identity;
  final String identityType;
  final String otp;
  final int isFirebaseOtp;
  const NewPassScreen({super.key, required this.identity,required this.otp, required this.identityType, required this.isFirebaseOtp});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _identity='';



  @override
  void initState() {
    super.initState();
    _identity = widget.identity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "change_password".tr),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Form(
              key: formKey,
              child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [

                CustomTextField(
                  title: 'New_Password'.tr,
                  hintText: "********",
                  controller: _newPasswordController,
                  focusNode: _newPasswordFocus,
                  nextFocus: _confirmPasswordFocus,
                  inputType: TextInputType.visiblePassword,
                  isPassword: true,
                  onValidate: (value){
                    return (value ==null || value.isEmpty) ? "field_cannot_be_empty".tr : value.length<8 ? "password_should_be".tr : null;
                  },
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                CustomTextField(
                  title: "Confirm_New_Password".tr,
                  hintText: "********",
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.visiblePassword,
                  isPassword: true,
                  onValidate: (value){
                    return (value ==null || value.isEmpty) ? "field_cannot_be_empty".tr :
                    value != _newPasswordController.text ?
                    "confirm_password_does_not_matched".tr : null;
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
                //const SizedBox(height: Dimensions.paddingSizeDefault),

                GetBuilder<AuthController>(builder: (controller){
                  return CustomButton(
                    fontSize: Dimensions.fontSizeDefault,
                    btnTxt: "change_password".tr,
                    isLoading: controller.isLoading!,
                    onPressed: ()=> _resetPassword(
                        _identity,widget.otp,_newPasswordController.text.trim(),_confirmPasswordController.text.trim()
                    ),
                  );
                })
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(String identity,String otp,String password,String conPassword){
    if(formKey.currentState!.validate()){
      Get.find<AuthController>().resetPassword(identity,widget.identityType,otp,password,conPassword, widget.isFirebaseOtp);
    }
  }
}
