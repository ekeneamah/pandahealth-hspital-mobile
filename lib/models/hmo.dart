import 'package:pandahealthhospital/models/validator.dart';

class Hmo {
  String name = "";
  String email = "";
  String desc = "";
  String? tags;
  String id = "";

  Hmo({
    required this.name,
    required this.email,
    required this.desc,
    this.tags,
    required this.id,
  });

  Hmo.fromMap(Map<dynamic, dynamic> data) {
    name = validValue(name, data['name']) ?? "";
    email = validValue(email, data['email']) ?? "";
    desc = validValue(desc, data['desc']) ?? "";
    tags = validValue(tags, data['tags']);
    id = validValue(id, data['id']) ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'desc': desc,
      'tags': tags,
      'id': id,
    };
  }
}
