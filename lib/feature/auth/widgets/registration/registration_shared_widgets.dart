import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';

class RegistrationContinueButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String labelKey;

  const RegistrationContinueButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.labelKey = 'continue',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
      ),
      child: CustomButton(
        height: 48,
        width: double.infinity,
        radius: Dimensions.radiusDefault,
        fontSize: Dimensions.fontSizeDefault,
        isLoading: isLoading,
        btnTxt: trLabel(labelKey),
        onPressed: onPressed,
      ),
    );
  }
}

class CompanyStepBadge extends StatelessWidget {
  const CompanyStepBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        trLabel('for_company'),
        style: robotoMedium.copyWith(color: Colors.green.shade700, fontSize: Dimensions.fontSizeSmall),
      ),
    );
  }
}

class ProviderTypeOptionCard extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final bool isSelected;
  final VoidCallback onTap;

  const ProviderTypeOptionCard({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: isSelected ? primary : Theme.of(context).hintColor.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? primary.withValues(alpha: 0.06) : Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? primary.withValues(alpha: 0.15) : Theme.of(context).hintColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? primary : context.adaptiveIconColor, size: 28),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trLabel(titleKey), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: 4),
                    Text(
                      trLabel(subtitleKey),
                      style: robotoRegular.copyWith(
                        color: context.adaptiveIconColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: primary, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationIconField extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String hintKey;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool isRequired;
  final bool isEnabled;
  final String? Function(String?)? onValidate;
  final VoidCallback? onChanged;

  const RegistrationIconField({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.hintKey,
    required this.controller,
    this.inputType = TextInputType.text,
    this.isRequired = true,
    this.isEnabled = true,
    this.onValidate,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        keyboardType: inputType,
        validator: onValidate,
        onChanged: (_) => onChanged?.call(),
        style: robotoRegular,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: context.adaptiveIconColor, size: 22),
          labelText: trLabel(titleKey),
          hintText: trLabel(hintKey),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: context.adaptiveIconColor.withValues(alpha: 0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: context.adaptivePrimaryColor),
          ),
        ),
      ),
    );
  }
}

class RegistrationUploadBox extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;
  final VoidCallback onTap;
  final Widget? preview;
  final bool isValid;

  const RegistrationUploadBox({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    required this.onTap,
    this.preview,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: isValid ? Theme.of(context).hintColor.withValues(alpha: 0.35) : Theme.of(context).colorScheme.error,
                width: 1.5,
                style: BorderStyle.solid,
              ),
              color: context.adaptiveIconColor.withValues(alpha: 0.04),
            ),
            child: preview ??
                Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 40, color: context.adaptivePrimaryColor),
                    const SizedBox(height: 8),
                    Text(trLabel(titleKey), style: robotoMedium),
                    const SizedBox(height: 4),
                    Text(
                      trLabel(subtitleKey),
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(color: context.adaptiveIconColor, fontSize: Dimensions.fontSizeSmall),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
