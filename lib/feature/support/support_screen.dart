import 'package:demandium_provider/common/widgets/app_bar.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:demandium_provider/util/dimensions.dart';
import 'package:demandium_provider/util/images.dart';
import 'package:demandium_provider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  String get _supportPhone =>
      Get.find<SplashController>().configModel.content?.businessPhone?.trim() ?? '';

  String get _supportEmail =>
      Get.find<SplashController>().configModel.content?.businessEmail?.trim() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBar(title: 'help_&_support'.tr),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeSmall,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Images.helpSupportImage, width: 140, height: 56),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  'contact_for_support'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  'were_here_to_help'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeSmall,
                  bottom: Dimensions.paddingSizeDefault,
                ),
                children: [
                  ContactWithEmailOrPhone(
                    title: 'call_our_customer'.tr,
                    subTitle: 'talk_with_our_customer'.tr,
                    message: _supportPhone,
                    contactType: SupportContactType.phone,
                  ),
                  ContactWithEmailOrPhone(
                    title: 'whatsapp_us'.tr,
                    subTitle: 'whatsapp_support_subtitle'.tr,
                    message: _supportPhone,
                    contactType: SupportContactType.whatsapp,
                  ),
                  ContactWithEmailOrPhone(
                    title: 'send_us_email_through'.tr,
                    subTitle: 'typically_the_support'.tr,
                    message: _supportEmail,
                    contactType: SupportContactType.email,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SupportContactType { phone, email, whatsapp }

class ContactWithEmailOrPhone extends StatelessWidget {
  final String title;
  final String subTitle;
  final String message;
  final SupportContactType contactType;

  const ContactWithEmailOrPhone({
    super.key,
    required this.title,
    required this.subTitle,
    required this.message,
    required this.contactType,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasMessage = message.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _LeadingIcon(contactType: contactType),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subTitle,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasMessage) ...[
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    message,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          InkWell(
            onTap: hasMessage ? () => _openContact(message) : null,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                color: contactType == SupportContactType.whatsapp
                    ? const Color(0xFF25D366)
                    : Theme.of(context).primaryColor,
              ),
              child: _ActionIcon(contactType: contactType),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openContact(String value) async {
    final Uri uri;
    switch (contactType) {
      case SupportContactType.phone:
        uri = Uri(scheme: 'tel', path: value);
        break;
      case SupportContactType.email:
        uri = Uri(scheme: 'mailto', path: value);
        break;
      case SupportContactType.whatsapp:
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.isEmpty) return;
        uri = Uri.parse('https://wa.me/$digits');
        break;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _LeadingIcon extends StatelessWidget {
  final SupportContactType contactType;

  const _LeadingIcon({required this.contactType});

  @override
  Widget build(BuildContext context) {
    final Color bg = Get.isDarkMode
        ? Colors.grey.withValues(alpha: 0.2)
        : Theme.of(context).primaryColor.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: contactType == SupportContactType.whatsapp
            ? const Color(0xFF25D366).withValues(alpha: 0.12)
            : bg,
      ),
      child: contactType == SupportContactType.whatsapp
          ? const Icon(Icons.chat_rounded, size: 16, color: Color(0xFF25D366))
          : Image.asset(
              contactType == SupportContactType.phone
                  ? Images.phoneIconBlue
                  : Images.mailIconBlue,
              height: 16,
              width: 16,
            ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final SupportContactType contactType;

  const _ActionIcon({required this.contactType});

  @override
  Widget build(BuildContext context) {
    if (contactType == SupportContactType.whatsapp) {
      return const Icon(Icons.chat_rounded, size: 15, color: Colors.white);
    }
    return Image.asset(
      contactType == SupportContactType.phone ? Images.phoneIconWhite : Images.mailIconWhite,
      height: 15,
      width: 15,
    );
  }
}
