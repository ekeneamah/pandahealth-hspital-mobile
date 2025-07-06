import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/constants/data.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/custom_widgets/user_avatar.dart';
import 'package:pandahealthhospital/models/chat.dart';
import 'package:pandahealthhospital/models/chat_message.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/patient.dart';
import 'package:pandahealthhospital/screens/connect/profile_info.dart';
import 'package:pandahealthhospital/screens/medical_appointment/result_view.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Object user;
  final Chat chat;
  final bool isAi;

  const ChatScreen(this.chat, this.user, {this.isAi = false, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late var user;
  late Chat chat;
  late String otherUserType;

  final FirebaseServices _firebaseServices = FirebaseServices();

  final ScrollController _myScrollController = ScrollController();

  List<Map> existentDates = [];

  final TextEditingController _messageController = TextEditingController();

  late String myId;
  late Doctor me;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = widget.user;
    chat = widget.chat;
    otherUserType = removeFirstInstance(chat.participantTypes, 'doctor').first;

    myId = Provider.of<UserStore>(context, listen: false).doctor?.id ?? "";
    me = Provider.of<UserStore>(context, listen: false).doctor!;
  }

  _scrollToBottom() {
    //This way this runs after the build
    // After 1 second, it takes you to the bottom of the ListView
    Timer(
      const Duration(milliseconds: 500),
      () => _myScrollController
          .jumpTo(_myScrollController.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = getWidth(context);
    final height = getHeight(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_ios, color: Colors.grey))),
        backgroundColor: actualLightGreen,
        elevation: 0,
        title: ListTile(
            onTap: () {
              if (widget.isAi) {
                return;
              }
              push(ProfileInfo(user));
            },
            title: widget.isAi
                ? const Text("Panda Health Ai")
                : Text(
                    user is Doctor || user is Patient
                        ? "${user.firstName} ${user.lastName}"
                        : user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            subtitle: Text(otherUserType),
            leading: widget.isAi
                ? CustomProfileAvatar()
                : CustomProfileAvatar(profileImg: user.profileUrl)),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.grey))
        ],
      ),
      body: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultHorizontalPadding,
                      vertical: defaultVerticalPadding),
                  child: StreamBuilder(
                    stream: _firebaseServices.listenForChatStream(chat),
                    builder: (context, stream) {
                      if (stream.hasData) {
                        List<ChatMessage> messages = stream.data;

                        if (messages.isNotEmpty) {
                          Timer.run(() {
                            _scrollToBottom();
                          });

                          return ListView.builder(
                              controller: _myScrollController,
                              itemCount: messages.length + 1,
                              itemBuilder: (context, ind) {
                                if (ind == 0) {
                                  existentDates = [];
                                }

                                if (ind == messages.length) {
                                  return const SizedBox(height: 100);
                                }

                                ChatMessage message = messages[ind];

                                //This is so that it adds this to the list after the widget builds
                                if (existentDates
                                    .where((element) =>
                                        element['day'] ==
                                            message.timestamp.day &&
                                        element['month'] ==
                                            message.timestamp.month)
                                    .isEmpty) {
                                  existentDates.add({
                                    "no": 1,
                                    "day": message.timestamp.day,
                                    "month": message.timestamp.month
                                  });
                                } else {
                                  var currentDate = existentDates
                                      .where((element) =>
                                          element["day"] ==
                                          message.timestamp.day)
                                      .first;
                                  existentDates[existentDates
                                      .indexOf(currentDate)]['no'] += 1;
                                }

                                //Add a space at the end of the page so that the user can see the last message with ease

                                return Column(
                                  crossAxisAlignment: myId == message.sender
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                        width: width,
                                        child: existentDates
                                                    .where((element) =>
                                                        element['day'] ==
                                                            message.timestamp
                                                                .day &&
                                                        element['month'] ==
                                                            message.timestamp
                                                                .month &&
                                                        element['no'] < 2).isNotEmpty
                                            ? message.timestamp.day ==
                                                    DateTime.now().day
                                                ? const Text("Today")
                                                : Text(
                                                    DateFormat('dd/MM/yyyy').format(message.timestamp))
                                            : Container()),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minWidth: 100, maxWidth: width * 0.7),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: const Radius.circular(20),
                                                topRight: const Radius.circular(20),
                                                bottomRight:
                                                    myId == message.sender
                                                        ? const Radius.circular(0)
                                                        : const Radius.circular(20),
                                                bottomLeft:
                                                    myId != message.sender
                                                        ? const Radius.circular(0)
                                                        : const Radius.circular(20))),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                myId == message.sender
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                myId != message.sender &&
                                                        widget.isAi
                                                    ? "Panda Health ai"
                                                    : "${me.firstName} ${me.lastName}",
                                                style: const TextStyle(
                                                    color: lightGreen),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(message.message),
                                              //Here if the image is a result
                                              message.type == 'result'
                                                  ? SizedBox(
                                                      width: width * 0.4,
                                                      height: 100,
                                                      child: InkWell(
                                                        onTap: () {
                                                          push(ResultView(message
                                                                  .data[
                                                              'appointmentId']));
                                                        },
                                                        child: const Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(Icons.folder,
                                                                size: 70,
                                                                color:
                                                                    appPrimaryColor),
                                                            Text("Tap to View",
                                                                style: TextStyle(
                                                                    color:
                                                                        actualDarkGreen))
                                                          ],
                                                        ),
                                                      ))
                                                  : Container(width: 0),
                                              Text(
                                                "${message.timestamp.hour}: ${message.timestamp.minute}",
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: lightGreen),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        } else {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded,
                                    color: Colors.white, size: 40),
                                Text("No Messages Yet")
                              ],
                            ),
                          );
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultHorizontalPadding,
                    vertical: defaultVerticalPadding),
                color: actualLightGreen,
                child: SafeArea(
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.paperclip, size: 30),
                      ),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            width: width * 0.5,
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                  hintText: "Type your message",
                                  border: InputBorder.none),
                            )),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (_messageController.text.isNotEmpty) {
                            String text = _messageController.text;
                            _messageController.value = TextEditingValue.empty;
                            bool res = await _firebaseServices.sendMessage(
                                chat.id, {'sender': myId, 'message': text});
                            if (!res) {
                              _messageController.value =
                                  TextEditingValue(text: text);
                              showCustomErrorToast("Couldn't Send Message");
                            }
                          }
                        },
                        icon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.send, size: 30),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
