import 'package:demandium_provider/common/enums/enums.dart';
import 'package:demandium_provider/common/widgets/custom_snackbar.dart';
import 'package:demandium_provider/helper/file_validation_helper.dart';
import 'package:demandium_provider/helper/localization_helper.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickCropHelper {
  static Future<XFile?> pickCropAndValidate({
    ImageSource source = ImageSource.gallery,
    bool lockAspectRatio = true,
    double ratioX = 1,
    double ratioY = 1,
    CropAspectRatioPreset? androidInitPreset,
    int maxSizeInBytes = AppConstants.registrationImageMaxBytes,
  }) async {
    final picked = await FileValidationHelper.validateAndPickImage(
      source: source,
      maxSizeInBytes: maxSizeInBytes,
    );
    if (picked == null) return null;

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: lockAspectRatio ? CropAspectRatio(ratioX: ratioX, ratioY: ratioY) : null,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: trLabel('crop_image'),
            toolbarColor: Get.theme.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: androidInitPreset ??
                (ratioX == ratioY
                    ? CropAspectRatioPreset.square
                    : CropAspectRatioPreset.original),
            lockAspectRatio: lockAspectRatio,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: trLabel('crop_image'),
            aspectRatioLockEnabled: lockAspectRatio,
            resetAspectRatioEnabled: !lockAspectRatio,
            hidesNavigationBar: false,
          ),
        ],
      );

      if (cropped == null) {
        return null;
      }

      final croppedFile = XFile(cropped.path);
      final sizeError = await FileValidationHelper.validateFileSizeAsync(
        file: croppedFile,
        maxSizeInBytes: maxSizeInBytes,
      );
      if (sizeError != null) {
        showCustomSnackBar(sizeError, type: ToasterMessageType.error);
        return null;
      }
      return croppedFile;
    } catch (e) {
      debugPrint('Image crop error: $e — using original pick');
      showCustomSnackBar(
        trLabel('crop_image_unavailable_using_original'),
        type: ToasterMessageType.info,
      );
      return picked;
    }
  }
}
