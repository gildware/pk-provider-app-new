import 'dart:convert';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:universal_html/html.dart' as html;
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class PaymentMethodDialog extends StatelessWidget {
  final double amount;
  const PaymentMethodDialog({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {

    List<DigitalPaymentMethod> paymentMethodList = PaymentConfigHelper.enabledDigitalPaymentGateways();

    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return Container(
          width: Dimensions.webMaxWidth,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical:  Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            // border: Border.all(color: Theme.of(context).colorScheme.primary),
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
            boxShadow: context.customThemeColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [

              const SizedBox(height: Dimensions.paddingSizeDefault),
              Container(
                height: 5, width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).hintColor.withValues(alpha:0.15)
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(children: [
              Text(" ${'choose_payment_method'.tr} ", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),

                Expanded(child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'click_one_of_the_option_below'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                )),
            ]),

              (paymentMethodList.isNotEmpty)?
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                child: DigitalPaymentMethodView(
                  paymentList: paymentMethodList,
                  tooltipController: JustTheController(),
                  fromPage: '',
                ),
              ) :  Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraLarge),
                child: Text("no_payment_method_available".tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),),
              ),

              CustomButton(
                radius: Dimensions.radiusDefault,
                btnTxt: "select".tr,
                onPressed: () async {
                  if(paymentMethodList.isEmpty){
                    showCustomSnackBar("no_payment_method_available".tr);
                  }
                  else if(dashboardController.paymentMethodIndex == -1){
                    showCustomSnackBar("select_payment_method".tr);
                  }else{
                    String hostname = html.window.location.hostname!;
                    String protocol = html.window.location.protocol;
                    String port = html.window.location.port;
                    String? path = html.window.location.pathname;

                    DigitalPaymentMethod paymentMethod;
                    paymentMethod = paymentMethodList[dashboardController.paymentMethodIndex];

                    String platform = GetPlatform.isWeb ? "web" : "app" ;

                    String callbackUrl = GetPlatform.isWeb ? "$protocol//$hostname:$port$path" : AppConstants.baseUrl;

                    String providerID = Get.find<UserProfileController>().providerModel!.content!.providerInfo!.id!;


                    String url = '';

                    final accessToken = await PaymentAccessTokenHelper.forProvider();

                    url = '${AppConstants.baseUrl}/payment?payment_method=${paymentMethod.gateway}&provider_id=$providerID&access_token=$accessToken'
                        '&callback=$callbackUrl&amount=$amount&payment_platform=$platform&is_pay_to_admin=true';

                    Get.back();

                    DigitalPaymentLauncher.start(
                      paymentUrl: url,
                      fromPage: 'dashboard',
                      gateway: paymentMethod.gateway,
                    );

                  }

                },
              ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            ],
          ),
        );
      }
    );
  }
}
