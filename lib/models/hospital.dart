import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pandahealthhospital/models/validator.dart';

class Hospital {
  String userType = "";
  bool approved = false;
  String centerLogo = "";
  String coverImg = "";
  String name = "";
  String email = "";
  String state = "";
  String city = "";
  int openingTimeOfDay = 9;
  int closingTimeOfDay = 18;
  String phoneNumber = "";
  String address = "";
  String website = "";
  String about = "";
  String id = "";
  double lat = 0.0;
  double lng = 0.0;
  List<CenterDocument> documents = [];
  DateTime createdOn = DateTime.now();

  Hospital.fromMap(Map<dynamic, dynamic> data) {
    print("Here");
    print(data);

    userType = validValue(userType, data['userType']);
    approved = validValue(approved, data['approved']);
    centerLogo = validValue(centerLogo, data['centerLogo']);
    coverImg = validValue(coverImg, data['coverImg']);
    name = validValue(name, data['name']);
    email = validValue(email, data['email']);
    state = validValue(state, data['state']);
    city = validValue(city, data['city']);
    openingTimeOfDay = validValue(openingTimeOfDay, data['openingTimeOfDay']);
    closingTimeOfDay = validValue(closingTimeOfDay, data['closingTimeOfDay']);
    phoneNumber = validValue(phoneNumber, data['phoneNumber']);
    address = validValue(address, data['address']);
    website = validValue(website, data['website']);
    about = validValue(about, data['about']);
    id = validValue(id, data['id']);
    lat = validValue(lat, data['lat']);
    lng = validValue(lng, data['lng']);
    documents = validValue(documents, data['documents']);
    // createdOn = validValue(createdOn, DateTime.parse(data['createdOn'] ?? DateTime.now().toString()));

    print("Second Here");
  }

  Hospital.fromFirebaseDocument(DocumentSnapshot snapshot) {
    var documentDetails = snapshot.data() as Map;

    userType = validValue(userType, documentDetails['userType']);
    approved = validValue(approved, documentDetails['approved']);
    centerLogo = validValue(centerLogo, documentDetails['centerLogo']);
    coverImg = validValue(coverImg, documentDetails['coverImg']);
    name = validValue(name, documentDetails['name']);
    email = validValue(email, documentDetails['email']);
    state = validValue(state, documentDetails['state']);
    city = validValue(city, documentDetails['city']);
    openingTimeOfDay =
        validValue(openingTimeOfDay, documentDetails['openingTimeOfDay']);
    closingTimeOfDay =
        validValue(closingTimeOfDay, documentDetails['closingTimeOfDay']);
    phoneNumber = validValue(phoneNumber, documentDetails['phoneNumber']);
    address = validValue(address, documentDetails['address']);
    website = validValue(website, documentDetails['website']);
    about = validValue(about, documentDetails['about']);
    id = validValue(id, documentDetails['id']);
    lat = validValue(lat, documentDetails['lat']);
    lng = validValue(lng, documentDetails['lng']);
    documents = validValue(documents, documentDetails['documents']);
    createdOn = validValue(
        createdOn, documentDetails['createdOn']?.toDate() ?? DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'approved': approved,
      'centerLogo': centerLogo,
      'coverImg': coverImg,
      'name': name,
      'email': email,
      'state': state,
      'city': city,
      'openingTimeOfDay': openingTimeOfDay,
      'closingTimeOfDay': closingTimeOfDay,
      'phoneNumber': phoneNumber,
      'address': address,
      'website': website,
      'about': about,
      'id': id,
      'lat': lat,
      'lng': lng,
      'documents': documents.map((doc) => doc.toMap()).toList(),
      'createdOn': createdOn,
    };
  }
}

class CenterDocument {
  String name = "";
  String url = "";

  CenterDocument({
    this.name = '',
    this.url = '',
  });

  factory CenterDocument.fromMap(Map<String, dynamic> data) {
    return CenterDocument(
      name: data['name'] ?? '',
      url: data['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
    };
  }
}
