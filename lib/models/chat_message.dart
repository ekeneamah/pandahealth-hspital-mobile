import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String sender = "";
  String message = "";
  String type = "";
  String imageUrl = "";
  dynamic data;
  DateTime timestamp = DateTime.now();

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.type,
    this.data,
    this.imageUrl = '',
  });

  factory ChatMessage.fromFirebaseDocument(DocumentSnapshot snapshot) {
    var documentDetails = snapshot.data() as Map;
    return ChatMessage(
      type: documentDetails['type'] ?? '',
      sender: documentDetails['sender'] ?? '',
      message: documentDetails['message'] ?? '',
      data: documentDetails['data'] ?? '',
      timestamp: documentDetails['timestamp'].toDate() ?? '',
      imageUrl: documentDetails['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
