import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pandahealthhospital/models/validator.dart';

class Doctor {
  String firstName = "";
  String lastName = "";
  String name = "";
  String userType = ""; // Replace with the actual type, e.g., UserTypes.patient
  String id = "";
  String hospitalId = "";
  String address = "";
  String speciality = "";
  String qualifications = "";
  String gender = "";
  String dateOfBirth = "";
  String profileUrl = "";
  String centerLogo = "";
  String email = "";
  String phoneNumber = "";
  bool available = false;
  bool hospitalApproved = false;
  bool phoneVerified = false;
  bool emailVerified = false;
  List documents = [];
  DateTime createdOn = DateTime.now();

  Doctor.fromMap(Map<dynamic, dynamic> data) {
    firstName = validValue(firstName, data['firstName']);
    lastName = validValue(lastName, data['lastName']);
    name = validValue(name, data['name']);
    userType = validValue(userType, data['userType']);
    id = validValue(id, data['id']);
    hospitalId = validValue(hospitalId, data['hospitalId']);
    address = validValue(address, data['address']);
    speciality = validValue(speciality, data['speciality']);
    qualifications = validValue(qualifications, data['qualifications']);
    gender = validValue(gender, data['gender']);
    dateOfBirth = validValue(dateOfBirth, data['dateOfBirth']);
    profileUrl = validValue(profileUrl, data['profileUrl']);
    centerLogo = validValue(centerLogo, data['centerLogo']);
    email = validValue(email, data['email']);
    phoneNumber = validValue(phoneNumber, data['phoneNumber']);
    available = validValue(available, data['available']);
    phoneVerified = validValue(phoneVerified, data['phoneVerified']);
    emailVerified = validValue(emailVerified, data['emailVerified']);
    documents = validValue(documents, data['documents']);
    createdOn = validValue(createdOn, DateTime.parse(data['createdOn'] ?? ""));
  }

  Doctor.fromFirebaseDocument(DocumentSnapshot snapshot) {
    var documentDetails = snapshot.data() as Map;

    firstName = validValue(firstName, documentDetails['firstName']);
    lastName = validValue(lastName, documentDetails['lastName']);
    name = validValue(name, documentDetails['name']);
    userType = validValue(userType, documentDetails['userType']);
    id = validValue(id, documentDetails['id']);
    hospitalId = validValue(hospitalId, documentDetails['hospitalId']);
    address = validValue(address, documentDetails['address']);
    speciality = validValue(speciality, documentDetails['speciality']);
    qualifications =
        validValue(qualifications, documentDetails['qualifications']);
    gender = validValue(gender, documentDetails['gender']);
    dateOfBirth = validValue(dateOfBirth, documentDetails['dateOfBirth']);
    profileUrl = validValue(profileUrl, documentDetails['profileUrl']);
    centerLogo = validValue(centerLogo, documentDetails['centerLogo']);
    email = validValue(email, documentDetails['email']);
    phoneNumber = validValue(phoneNumber, documentDetails['phoneNumber']);
    available = validValue(available, documentDetails['available']);
    phoneVerified = validValue(phoneVerified, documentDetails['phoneVerified']);
    emailVerified = validValue(emailVerified, documentDetails['emailVerified']);
    documents = validValue(documents, documentDetails['documents']);
    createdOn = validValue(createdOn, documentDetails['createdOn']?.toDate());
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'id': id,
      'hospitalId': hospitalId,
      'address': address,
      'speciality': speciality,
      'qualifications': qualifications,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'profileUrl': profileUrl,
      'email': email,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
      'emailVerified': emailVerified,
      'documents': documents,
      'createdOn': createdOn,
    };
  }
}
