class DiagnosticCenter {
  String userType;
  bool approved;
  String centerLogo;
  String profileUrl;
  String coverImg;
  String name;
  String? firstName;
  String? lastName;
  String email;
  String state;
  String city;
  int openingTimeOfDay;
  int closingTimeOfDay;
  num dist;
  String phoneNumber;
  String address;
  String website;
  String about;
  String id;
  double lat;
  double lng;
  List<CenterDocument> documents;

  DiagnosticCenter({
    this.userType = '',
    this.approved = false,
    this.centerLogo = '',
    this.profileUrl = '',
    this.coverImg = '',
    this.name = '',
    this.email = '',
    this.state = '',
    this.city = '',
    this.dist = 0,
    this.openingTimeOfDay = 0,
    this.closingTimeOfDay = 0,
    this.phoneNumber = '',
    this.address = '',
    this.website = '',
    this.about = '',
    this.id = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.documents = const [],
  });

  factory DiagnosticCenter.fromMap(data) {
    return DiagnosticCenter(
      userType: data['userType'] ?? '',
      approved: data['approved'] ?? false,
      centerLogo: data['centerLogo'] ?? '',
      profileUrl: data['profileUrl'] ?? '',
      coverImg: data['coverImg'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      dist: data['dist'] ?? 0,
      openingTimeOfDay: data['openingTimeOfDay'] ?? 0,
      closingTimeOfDay: data['closingTimeOfDay'] ?? 0,
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      website: data['website'] ?? '',
      about: data['about'] ?? '',
      id: data['id'] ?? '',
      lat: data['lat'] ?? 0.0,
      lng: data['lng'] ?? 0.0,
      documents: (data['documents'] as List<dynamic>?)
          ?.map((doc) => CenterDocument.fromMap(doc))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'approved': approved,
      'centerLogo': centerLogo,
      'profileUrl': profileUrl,
      'coverImg': coverImg,
      'name': name,
      'email': email,
      'state': state,
      'city': city,
      'dist': dist,
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
    };
  }
}

class CenterDocument {
  String name;
  String url;

  CenterDocument({
    this.name = '',
    this.url = '',
  });

  factory CenterDocument.fromMap(data) {
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
