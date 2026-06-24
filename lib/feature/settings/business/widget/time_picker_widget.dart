import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final String title;
  final String? time;
  final Function(String?) onTimeChanged;
  const TimePickerWidget({super.key, required this.title, required this.time, required this.onTimeChanged});

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}


class _TimePickerWidgetState extends State<TimePickerWidget> {
  String? _myTime;

  @override
  void initState() {
    super.initState();
    _myTime = widget.time;
  }

  @override
  void didUpdateWidget(covariant TimePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      _myTime = widget.time;
    }
  }

  TimeOfDay _parseInitialTime() {
    final raw = _myTime ?? widget.time;
    if (raw == null || raw.trim().isEmpty) {
      return TimeOfDay.now();
    }

    for (final pattern in ['h:mm a', 'hh:mm a', 'HH:mm', 'HH:mm:ss']) {
      try {
        final parsed = DateFormat(pattern).parse(raw.trim());
        return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
      } catch (_) {
        continue;
      }
    }

    return TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {

        Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
        TimeOfDay? time = await showCustomTimePicker(initialTime: _parseInitialTime());
        Get.find<UserProfileController>().trialWidgetShow(route: "");
        if(time != null) {
          setState(() {
            _myTime = DateConverter.convert24HourTimeTo12HourTime(DateTime(DateTime.now().year, 1, 1, time.hour, time.minute));

          });
          widget.onTimeChanged(_myTime);
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha:0.2))
        ),
        child: Row(children: [

          Text(
            _myTime != null ? _myTime!: 'pick_time'.tr, style: robotoRegular,
            maxLines: 1,
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall,),

          const Icon(Icons.access_time, size: 20),

        ]),
      ),
    );
  }
}