import 'diagnostic_center.dart';

class DiagnosticTest {
  String id;
  String name;
  String desc;
  String centerId;
  String appointmentId;
  double price;
  DiagnosticCenter? center;

  DiagnosticTest({
    this.id = '',
    this.name = '',
    this.desc = '',
    this.centerId = '',
    this.appointmentId = '',
    this.price = 0.0,
    this.center
  });

  factory DiagnosticTest.fromMap(data) {
    return DiagnosticTest(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      desc: data['desc'] ?? '',
      centerId: data['centerId'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      center: data['center'] != null ? DiagnosticCenter.fromMap(data['center']): null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'centerId': centerId,
      'appointmentId': appointmentId,
      'price': price,
      'center': center?.toMap()
    };
  }
}
