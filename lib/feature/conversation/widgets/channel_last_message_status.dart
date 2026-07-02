import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ChannelLastMessageStatus extends StatelessWidget {
  final String? status;
  final int? peerIsRead;

  const ChannelLastMessageStatus({
    super.key,
    required this.status,
    this.peerIsRead,
  });

  String get _resolvedStatus {
    if (status != null && status!.isNotEmpty) {
      return status!;
    }
    return peerIsRead == 1 ? 'seen' : 'sent';
  }

  String get _label {
    switch (_resolvedStatus) {
      case 'seen':
        return 'seen'.tr;
      case 'delivered':
        return 'delivered'.tr;
      default:
        return 'sent'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSeen = _resolvedStatus == 'seen';
    final color = isSeen
        ? context.tabSelectedColor
        : Theme.of(context).hintColor.withValues(alpha: 0.75);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _resolvedStatus == 'sent' ? Icons.check : Icons.done_all,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 2),
        Text(
          _label,
          style: robotoRegular.copyWith(
            color: color,
            fontSize: Dimensions.fontSizeExtraSmall,
          ),
        ),
      ],
    );
  }
}
