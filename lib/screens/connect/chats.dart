import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/custom_widgets/skeleton_list_tile.dart';
import 'package:pandahealthhospital/custom_widgets/user_avatar.dart';
import 'package:pandahealthhospital/models/chat.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/patient.dart';
import 'package:pandahealthhospital/screens/connect/chat.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  TextEditingController searchCtrl = TextEditingController();
  final FirebaseServices _firebaseServices = FirebaseServices();
  String myId = "";
  Future getChatsFuture = Future.value(null);

  @override
  void initState() {
    super.initState();
    myId = Provider.of<UserStore>(context, listen: false).hospital?.id ?? "";
    getChatsFuture = _firebaseServices.getMyChats(myId);
  }

  Future<Object?> fetchOtherPerson(Chat chat) async {
    List<String> otherParticipantType =
        removeFirstInstance(chat.participantTypes, 'center');
    List<String> otherPersonId = removeFirstInstance(chat.participants, myId);

    if (otherParticipantType.isNotEmpty && otherPersonId.isNotEmpty) {
      if (otherParticipantType[0] == 'patient') {
        final foundPatient =
            await _firebaseServices.getPatientFromId(otherPersonId[0]);
        return foundPatient ??
            Patient(
                id: otherPersonId[0],
                firstName: "Unknown",
                lastName: "Patient",
                profileUrl: "assets/profile-img.png");
      }
      // Add other participant type checks as needed
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomTitleBar(
        title: 'Chats',
        showBackButton: false,
      ),
      body: Container(
        decoration: backgroundDecoration(false),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    SizedBox(width: 70, child: Image.asset("images/chat.png")),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: FutureBuilder(
                      future: getChatsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Chat> chats = snapshot.data as List<Chat>;

                          if (chats.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('images/empty.png', height: 110),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No chats available",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              Chat chat = chats[index];
                              return FutureBuilder(
                                future: fetchOtherPerson(chat),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SkeletonListTile();
                                  }

                                  final user = snapshot.data;
                                  final otherUserType = removeFirstInstance(
                                          chat.participantTypes, 'center')
                                      .first;

                                  return ListTile(
                                    onTap: () => push(ChatScreen(chat, user!)),
                                    leading: CustomProfileAvatar(
                                        profileImg: user is Patient
                                            ? (user).profileUrl
                                            : ""),
                                    title: Text(
                                      user is Patient
                                          ? "${(user).firstName} ${(user).lastName}"
                                          : user is Doctor
                                              ? "${(user).firstName} ${(user).lastName}"
                                              : "Unknown User",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: appPrimaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(chat.lastMessage ?? ""),
                                    trailing: Text(otherUserType),
                                  );
                                },
                              );
                            },
                          );
                        }
                        return const Center(child: CustomLoadingWidget());
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
