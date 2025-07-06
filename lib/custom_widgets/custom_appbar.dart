import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';

class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? image;
  final IconData? icon;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showBackButton;
  final Widget? leading;

  const CustomTitleBar({
    super.key,
    this.title = '',
    this.icon,
    this.image,
    this.backgroundColor,
    this.showBackButton = true,
    this.actions = const [],
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? leading ??
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  icon ?? Icons.arrow_back,
                  color: darkBlue,
                ),
              )
          : null,
      title: image != null
          ? Image.asset(image!, height: 50)
          : Text(
              title!,
              style: const TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
      actions: actions?.isNotEmpty == true ? actions : null,
    );
  }
}
