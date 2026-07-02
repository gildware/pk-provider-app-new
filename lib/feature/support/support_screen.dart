import 'package:demandium_provider/common/widgets/app_bar.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/dimensions.dart';
import 'package:demandium_provider/util/images.dart';
import 'package:demandium_provider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String phone =
        Get.find<SplashController>().configModel.content?.businessPhone?.trim() ?? '';
    final String emailAddress =
        Get.find<SplashController>().configModel.content?.businessEmail?.trim() ?? '';

    return Scaffold(
      appBar: CustomAppBar(title: 'help_&_support'.tr),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeLarge,
            horizontal: Dimensions.paddingSizeExtraLarge,
          ),
          child: Column(
            children: [
              Image.asset(Images.helpSupportImage, width: 160, height: 140),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Text(
                'contact_for_support'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Text(
                  'we_are_here_to_help_contact_our_support'.tr,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .5),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              SupportContactCard(
                title: 'call_our_customer_support'.tr,
                subtitle: 'contact_us_through_our_customer_care_number'.tr,
                contactInfo: phone,
                icon: Icons.phone,
                onTap: phone.isNotEmpty
                    ? () async => await launchUrl(Uri(scheme: 'tel', path: phone))
                    : null,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              SupportContactCard(
                title: 'whatsapp_us'.tr,
                subtitle: 'whatsapp_support_subtitle'.tr,
                contactInfo: phone,
                icon: Icons.chat_rounded,
                accentColor: const Color(0xFF25D366),
                onTap: phone.isNotEmpty ? () => _openWhatsApp(phone) : null,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              SupportContactCard(
                title: 'send_us_email_through'.tr,
                subtitle: 'typically_the_support_team_send_you_any_feedback'.tr,
                contactInfo: emailAddress,
                icon: Icons.email_outlined,
                onTap: emailAddress.isNotEmpty
                    ? () async => await launchUrl(Uri(scheme: 'mailto', path: emailAddress))
                    : null,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(String value) async {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class SupportContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String contactInfo;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const SupportContactCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.contactInfo,
    required this.icon,
    this.accentColor,
    this.onTap,
  });

  Color _accentColor(BuildContext context) => accentColor ?? context.adaptivePrimaryColor;

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentColor(context);
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: Dimensions.paddingSizeTini),
                Text(
                  subtitle,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .5),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contactInfo,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Theme.of(context).cardColor, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
