import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class SignUpAppbar extends StatefulWidget implements PreferredSizeWidget {
  const SignUpAppbar({super.key});
  @override
  State<SignUpAppbar> createState() => _SignUpAppbarState();
  @override
  Size get preferredSize => const Size(double.maxFinite, Dimensions.signUpAppbarHeight);
}

class _SignUpAppbarState extends State<SignUpAppbar> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(builder: (signUpController) {
      final stepsWithoutReview = signUpController.registrationSteps
          .where((s) => s != RegistrationStep.review)
          .toList();
      final int totalStep = stepsWithoutReview.length;
      final int currentStep = signUpController.isOnReviewStep
          ? totalStep
          : stepsWithoutReview.indexOf(signUpController.currentRegistrationStep) + 1;
      final String title = signUpController.currentRegistrationStep.titleKey;

      return AppBar(
        elevation: 5,
        titleSpacing: 0,
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        shadowColor: Get.isDarkMode
            ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
            : Theme.of(context).primaryColor.withValues(alpha: 0.1),
        centerTitle: false,
        toolbarHeight: Dimensions.signUpAppbarHeight,
        title: Text(
          trLabel(title),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        leading: IconButton(
          onPressed: signUpController.goToPreviousRegistrationStep,
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
        ),
        actions: [
          if (!signUpController.isOnReviewStep) ...[
            const SizedBox(width: 20),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: currentStep / totalStep, end: currentStep / totalStep),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: Dimensions.signUpAppbarHeight * 0.62,
                      width: Dimensions.signUpAppbarHeight * 0.62,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: Dimensions.signUpAppbarHeight * 0.06,
                        backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.2),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.signUpAppbarHeight * 0.4,
                      width: Dimensions.signUpAppbarHeight * 0.4,
                      child: FittedBox(
                        child: Text(
                          '$currentStep ${'of'.tr} $totalStep',
                          style: robotoBold.copyWith(color: context.adaptivePrimaryColor),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(width: 20),
        ],
      );
    });
  }
}
