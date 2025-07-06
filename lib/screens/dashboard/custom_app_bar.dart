import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/badge.dart';
import 'package:pandahealthhospital/utils/utils.dart';

// import 'package:healthpanda_patient/common/utils.dart';
// import 'package:healthpanda_patient/views/notification/notification_view.dart';

class CustomHomeScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onTap;
  bool showBadge;
  CustomHomeScreenAppBar({
    super.key,
    this.showBadge = true,
    this.onTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundDecoration(true),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding, vertical: 8),
          child: Row(
            children: [
              IconButton(onPressed: onTap, icon: const Icon(Icons.menu)),
              const Spacer(),
              showBadge ? const PandaBadge() : Container(),
              const SizedBox(width: 8),
              // Stack(
              //   alignment: AlignmentDirectional.topEnd,
              //   children: [
              //     IconButton(
              //       padding: const EdgeInsets.all(2),
              //       onPressed: () => {},
              //       icon: const CircleAvatar(
              //         radius: 26,
              //       ),
              //     ),
              //     const Positioned(
              //       bottom: 0,
              //       right: -1,
              //       child: CircleAvatar(
              //         backgroundColor: Colors.white,
              //         radius: 10,
              //         child: CircleAvatar(radius: 8, backgroundColor: lightGreen),
              //       ),
              //     )
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
