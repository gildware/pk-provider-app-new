import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ShowcaseFormScreen extends StatefulWidget {
  const ShowcaseFormScreen({super.key});

  @override
  State<ShowcaseFormScreen> createState() => _ShowcaseFormScreenState();
}

class _ShowcaseFormScreenState extends State<ShowcaseFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: Get.find<ShowcaseController>().editingItem != null
            ? 'edit_showcase'.tr
            : 'add_showcase'.tr,
      ),
      body: GetBuilder<ShowcaseController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShowcaseMediaTypeSelector(
                  selectedType: controller.selectedMediaType,
                  onTypeChanged: controller.setMediaType,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                _MediaPicker(controller: controller),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                CustomTextField(
                  title: 'title'.tr,
                  controller: controller.titleController,
                  hintText: 'showcase_title_hint'.tr,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                CustomTextField(
                  title: 'description'.tr,
                  controller: controller.descriptionController,
                  hintText: 'showcase_description_hint'.tr,
                  maxLines: 3,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                CustomButton(
                  btnTxt: controller.editingItem != null ? 'update'.tr : 'submit'.tr,
                  isLoading: controller.isLoading,
                  onPressed: controller.isLoading ? null : () => controller.saveItem(),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : Dimensions.paddingSizeDefault,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MediaPicker extends StatelessWidget {
  final ShowcaseController controller;
  const _MediaPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isVideo = controller.selectedMediaType == 'video';
    final previewHeight = isVideo ? 220.0 : 200.0;
    final hasPickedImage =
        controller.pickedMedia != null && controller.selectedMediaType == 'image';
    final hasNetworkImage = controller.networkMediaUrl != null &&
        controller.selectedMediaType == 'image' &&
        controller.pickedMedia == null;
    final videoReady = controller.videoPlayerController?.value.isInitialized == true;
    final hasVideo = isVideo && (controller.pickedMedia != null || videoReady);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(
          title: trLabel('upload_media'),
          requiredMark: true,
          isPadding: false,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          isVideo ? trLabel('showcase_video_upload_hint') : trLabel('showcase_image_upload_hint'),
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        InkWell(
          onTap: controller.pickMedia,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: DottedBorderBox(
            height: previewHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: SizedBox(
                width: double.infinity,
                height: previewHeight,
                child: hasPickedImage
                    ? Image.file(
                        File(controller.pickedMedia!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: previewHeight,
                      )
                    : hasNetworkImage
                        ? CustomImage(
                            image: controller.networkMediaUrl!,
                            fit: BoxFit.cover,
                            height: previewHeight,
                            width: double.infinity,
                          )
                        : hasVideo && videoReady
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: controller.videoPlayerController!.value.size.width,
                                      height: controller.videoPlayerController!.value.size.height,
                                      child: VideoPlayer(controller.videoPlayerController!),
                                    ),
                                  ),
                                  Container(
                                    color: Colors.black26,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      size: 56,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : _UploadPlaceholder(isVideo: isVideo),
              ),
            ),
          ),
        ),
        if (!isVideo) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ImageValidationTextWidget(
            textAlign: TextAlign.start,
            separator: '. ',
            showRatioValidation: false,
          ),
        ],
        if (controller.pickedMedia != null || controller.networkMediaUrl != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: controller.clearMedia,
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 20),
              label: Text(
                trLabel('remove'),
                style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
      ],
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final bool isVideo;
  const _UploadPlaceholder({required this.isVideo});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      color: primary.withValues(alpha: 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVideo ? Icons.videocam_outlined : Icons.add_photo_alternate_outlined,
              size: 40,
              color: primary,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            trLabel('tap_to_upload'),
            style: robotoMedium.copyWith(color: primary),
          ),
          const SizedBox(height: 4),
          Text(
            isVideo ? trLabel('showcase_video_upload_hint') : trLabel('showcase_image_upload_hint'),
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
