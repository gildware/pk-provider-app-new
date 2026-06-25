import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ReportCustomDropdownButton extends StatefulWidget {
  final String? value;
  final String? label;
  final List<String> items;
  final Function(String? value)? onChanged;
  final Function()? onTap;
  final double? height;
  final double? width;
  final Color? borderColor;
  final Color? dropdownBackgroundColor;
  final bool translateLabels;
  const ReportCustomDropdownButton({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.height,
    this.width,
    this.borderColor,
    this.dropdownBackgroundColor,
    this.label,
    this.onTap,
    this.translateLabels = true,
  });

  @override
  State<ReportCustomDropdownButton> createState() => _ReportCustomDropdownButtonState();
}

class _ReportCustomDropdownButtonState extends State<ReportCustomDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 50,
      width:widget.width ?? MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: DropdownButtonFormField<String>(
        key: ValueKey('${widget.label}_${widget.items.length}_${widget.value}'),
        menuMaxHeight: MediaQuery.of(context).size.height/2,
        dropdownColor: widget.dropdownBackgroundColor ?? Theme.of(context).cardColor,
        hint:  Text( widget.value !=null ? 'Not available' :'select'.tr, maxLines: 1,overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(color: widget.value !=null ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).hintColor),
        ),
        value: widget.value != null && widget.items.contains(widget.value)
            ? widget.value
            : null,
        items: widget.items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              widget.translateLabels ? value.tr : value,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
              maxLines: 1,
            ),
          );
        }).toList(),
        isDense: true,
        onChanged: widget.onChanged,
        isExpanded: true,
        onTap: widget.onTap,
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide:  BorderSide(color: Theme.of(context).colorScheme.error,width: 0.5),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide:  BorderSide(color: Theme.of(context).textTheme.bodySmall!.color! ,width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide:  BorderSide(color: context.adaptivePrimaryColor, width: 0.5),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          labelText: widget.label,
          labelStyle: robotoMedium
        ),

      ),
    );
  }
}
