class Patient {
  String firstName;
  String lastName;
  String? name;
  String userType;
  String phoneNumber;
  String email;
  String gender;
  String hmoNo;
  String hmoName;
  String id;
  String city;
  String state;
  String sex;
  String profileUrl;
  String address;
  String dateOfBirth;
  List<String> doctorsWithAccess;

  Patient({
    this.firstName = '',
    this.lastName = '',
    this.userType = '',
    this.phoneNumber = '',
    this.email = '',
    this.hmoNo = '',
    this.hmoName = '',
    this.id = '',
    this.gender = '',
    this.city = '',
    this.state = '',
    this.sex = '',
    this.profileUrl = '',
    this.address = '',
    this.dateOfBirth = '',
    this.doctorsWithAccess = const [],
  });

  factory Patient.fromMap(Map<dynamic, dynamic> data) {
    return Patient(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      userType: data['userType'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      hmoNo: data['hmoNo'] ?? '',
      hmoName: data['hmoName'] ?? '',
      id: data['id'] ?? '',
      gender: data['gender'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      sex: data['sex'] ?? '',
      profileUrl: data['profileUrl'] ?? '',
      address: data['address'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      doctorsWithAccess: List<String>.from(data['doctorsWithAccess'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'email': email,
      'id': id,
      'gender': gender,
      'city': city,
      'state': state,
      'profileUrl': profileUrl,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'doctorsWithAccess': doctorsWithAccess,
    };
  }
}
