import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_avatar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:provider/provider.dart';

class SelectHospitalDoctor extends StatefulWidget {
  Doctor selectedDoctor;

  SelectHospitalDoctor({super.key, required this.selectedDoctor});

  @override
  _SelectHospitalDoctorState createState() => _SelectHospitalDoctorState();
}

class _SelectHospitalDoctorState extends State<SelectHospitalDoctor> {
  List<Doctor> doctors = [];

  String searchInput = '';

  late String hospitalId;

  bool loading = false;

  final FirebaseServices _firebaseServices = FirebaseServices();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hospitalId = Provider.of<UserStore>(context, listen: false).hospital!.id;
    // getHospitalsDoctors();
  }

  getHospitalsDoctors() async {
    doctors = await _firebaseServices.getHospitalsDoctors(hospitalId, null);

    doctors =
        doctors.where((doc) => doc.id != widget.selectedDoctor.id).toList();

    return doctors;
  }

  // void filterSearchOptions(String input) {
  //   setState(() {
  //     searchInput = input;
  //     if (searchInput.isNotEmpty) {
  //       filteredDoctors = widget.doctors.where((doc) {
  //         final name = '${doc.firstName} ${doc.lastName}'.toLowerCase();
  //         final search = searchInput.toLowerCase();
  //         return name.contains(search) && doc.id != widget.selectedDoctor.id;
  //       }).toList();
  //     } else {
  //       filteredDoctors = widget.doctors.where((doc) => doc.id != widget.selectedDoctor.id).toList();
  //     }
  //   });
  // }

  handleSearch(String query) async {
    doctors =
        await _firebaseServices.searchForHospitalDoctors(hospitalId, query);
    doctors =
        doctors.where((doc) => doc.id != widget.selectedDoctor.id).toList();
    return doctors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Doctor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Doctors',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: handleSearch,
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: _searchController.text.isEmpty
                ? getHospitalsDoctors()
                : handleSearch(_searchController.text),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                doctors = snapshot.data as List<Doctor>;

                return doctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/empty.png', // Ensure you have this image in your assets
                              width: 90,
                              height: 90,
                            ),
                            const SizedBox(height: 16),
                            const Text('No Doctors',
                                style: TextStyle(
                                    fontSize: 18, color: appPrimaryColor)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Doctors in your center can apply to join this hospital via the Doctor App',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return ListTile(
                            leading: CustomAvatar(doctor),
                            title: Text(
                                'Dr ${doctor.firstName} ${doctor.lastName}'),
                            subtitle: const Text('Doctor'),
                            onTap: () {
                              Navigator.pop(context, doctor);
                            },
                          );
                        },
                      );
              } else {
                return const Center(child: CustomLoadingWidget());
              }
            },
          )),
        ],
      ),
    );
  }
}
