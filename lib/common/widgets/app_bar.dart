import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final String? subtitle;
  final bool centerTitle;
  final Function()? onBackPressed;
  final Widget? actionWidget;
  final double? elevation;
  const CustomAppBar({super.key,required this.title,this.centerTitle= false,this.onBackPressed, this.actionWidget, this.subtitle, this.elevation});

  static Color foregroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor(context);
    final titleStyle = robotoBold.copyWith(
      fontSize: Dimensions.fontSizeLarge,
      color: color,
    );
    return AppBar(
      elevation: elevation ?? 5,
      titleSpacing: 0,
      foregroundColor: color,
      iconTheme: IconThemeData(color: color, size: 20),
      surfaceTintColor: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).cardColor,
      shadowColor: Get.isDarkMode?Theme.of(context).primaryColor.withValues(alpha:0.5):Theme.of(context).primaryColor.withValues(alpha:0.1),
      centerTitle: centerTitle,
      titleTextStyle: titleStyle,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          if(subtitle!=null) Text(subtitle!,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: color)),
        ],
      ),
      leading: IconButton(
        onPressed: onBackPressed ?? (){
          Get.back();
        },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
      ),
      actions: actionWidget!=null?[actionWidget!]:null,
    );
  }
  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}

