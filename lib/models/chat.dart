

class Chat {
  String id;
  String lastMessage;
  List<String> participants;
  List<String> participantTypes;
  String lastMessageTimestamp;
  String lastMessageSender;

  Chat({
    required this.id,
    required this.lastMessage,
    required this.participants,
    required this.participantTypes,
    required this.lastMessageTimestamp,
    required this.lastMessageSender,
  });

  factory Chat.fromMap(Map<dynamic, dynamic> data) {
    return Chat(
      id: data['id'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      participantTypes: List<String>.from(data['participantTypes'] ?? []),
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? '',
      lastMessageSender: data['lastMessageSender'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'participants': participants,
      'participantTypes': participantTypes,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSender': lastMessageSender,
    };
  }
}
