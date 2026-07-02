import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType? type;
  final String? pageKey;
  const HtmlViewerScreen({super.key, this.type, this.pageKey});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}
class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  String _fallbackTitle(String pageKey) {
    if (pageKey == HtmlType.aboutUs.value) return 'about_us'.tr;
    if (pageKey == HtmlType.termsAndCondition.value) return 'terms_and_conditions'.tr;
    if (pageKey == HtmlType.privacyPolicy.value) return 'privacy_policy'.tr;
    if (pageKey == HtmlType.cancellationPolicy.value) return 'cancellation_policy'.tr;
    if (pageKey == HtmlType.refundPolicy.value) return 'refund_policy'.tr;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final pageKey = widget.pageKey ?? widget.type?.value ?? '';
    String? data;
    return GetBuilder<HtmlViewController>(
        initState: (state){
          Get.find<HtmlViewController>().getPagesContent(pageKey);
        },
        builder: (htmlViewController){
          data = htmlViewController.pageDetailsModel?.content?.replaceAll('href=', 'target="_blank" href=');
          final appBarTitle = (htmlViewController.pageDetailsModel?.title?.isNotEmpty ?? false)
              ? htmlViewController.pageDetailsModel!.title!
              : _fallbackTitle(pageKey);

        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: CustomAppBar(title: appBarTitle),
            body: Skeletonizer(
          enabled: htmlViewController.pageDetailsModel == null,
          child: Center(
              child: Container(
                width: Dimensions.webMaxWidth,
                height: MediaQuery.of(context).size.height,
                color: GetPlatform.isWeb ? context.adaptiveWhite : Theme.of(context).cardColor,
                child:SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [

                      (data?.isNotEmpty ?? false || htmlViewController.pageDetailsModel == null) ?  Container(
                        padding:  const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        margin: EdgeInsets.only(
                            top: Dimensions.paddingSizeDefault
                        ),
                        decoration: BoxDecoration(
                          color:  Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          boxShadow:  [ BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 5,
                            color: context.adaptivePrimaryColor.withValues(alpha: 0.12),
                          )],
                        ),
                        child: HtmlWidget(
                          data ?? '',
                          textStyle: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.7),
                          ),
                        ),
                      ) : NoDataScreen(text: 'no_data_found'.tr),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}