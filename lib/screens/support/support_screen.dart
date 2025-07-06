import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class ContactSupportView extends StatefulWidget {
  const ContactSupportView({super.key});

  @override
  State<ContactSupportView> createState() => _ContactSupportViewState();
}

class _ContactSupportViewState extends State<ContactSupportView> {
  @override
  Widget build(BuildContext context) {
    final height = getHeight(context);
    final width = getWidth(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomTitleBar(
        title: 'Contact Support',
      ),
      body: Container(
        width: width,
        height: height,
        decoration: backgroundDecoration(true),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: width,
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset("images/support.png"),
                          ),
                          const SmallSpace(),
                          // ListTile(
                          //   onTap: () => openLink('tel:+2348055091316'),
                          //   leading: Image.asset("images/phone.png", width: 30),
                          //   title: Text(
                          //     "+234 805 509 1316",
                          //     style: headerTextStyle.copyWith(fontSize: 15),
                          //   ),
                          //   subtitle: const Text("Phone",
                          //       style: TextStyle(color: Colors.grey)),
                          // ),
                          ListTile(
                            onTap: () =>
                                openLink('https://wa.me/2348055091316'),
                            leading:
                                Image.asset("images/whatsapp.png", width: 30),
                            title: Text("+234 805 509 1316",
                                style: headerTextStyle.copyWith(fontSize: 15)),
                            subtitle: const Text("WhatsApp",
                                style: TextStyle(color: Colors.grey)),
                          ),
                          ListTile(
                            onTap: () => openLink('mailto:$contactEmail'),
                            leading: Image.asset("images/mail.png", width: 30),
                            title: Text(
                              contactEmail,
                              style: headerTextStyle.copyWith(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: const Text("Email",
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
