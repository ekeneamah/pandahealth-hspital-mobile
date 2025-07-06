import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_avatar.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Doctor> doctors = [];
  String searchInput = '';
  bool isLoading = true;

  late String hospitalId;

  final FirebaseServices _firebaseServices = FirebaseServices();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hospitalId = Provider.of<UserStore>(context, listen: false).hospital!.id;
    fetchDoctors();

    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        fetchDoctors();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Doctor>> fetchDoctors() async {
    setState(() => isLoading = true);
    try {
      doctors = await _firebaseServices.getHospitalsDoctors(hospitalId, null);
      setState(() {});
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
    return doctors;
  }

  Future<void> handleApproval(String doctorId, bool approved) async {
    await _firebaseServices
        .updateDoctorInfo(doctorId, {'hospitalApproved': true});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(approved ? 'Doctor Approved' : 'Doctor Rejected'),
    ));
    fetchDoctors(); // Reload the doctors list
  }

  handleSearch(String query) async {
    if (query.isEmpty) {
      return;
    }

    setState(() => isLoading = true);
    try {
      doctors =
          await _firebaseServices.searchForHospitalDoctors(hospitalId, query);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomTitleBar(
        showBackButton: false,
        title: 'Hospitals Doctors',
      ),
      body: Container(
        decoration: backgroundDecoration(false),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(appPrimaryColor),
                          ),
                        )
                      : doctors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/empty.png',
                                    width: 90,
                                    height: 90,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('No Doctors',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: appPrimaryColor)),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 32),
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
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CustomAvatar(doctor),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Dr ${doctor.firstName} ${doctor.lastName}',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Text('Doctor',
                                                    style: TextStyle(
                                                        color:
                                                            appPrimaryColor)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.email,
                                                    color: appPrimaryColor),
                                                const SizedBox(width: 8),
                                                Text(doctor.email),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    color: appPrimaryColor),
                                                const SizedBox(width: 8),
                                                Text(dateFormatter(
                                                    DateTime.parse(
                                                        doctor.dateOfBirth))),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.phone,
                                                    color: appPrimaryColor),
                                                const SizedBox(width: 8),
                                                Text(doctor.phoneNumber),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.person,
                                                    color: appPrimaryColor),
                                                const SizedBox(width: 8),
                                                Text(doctor.gender),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        doctor.hospitalApproved == null
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        handleApproval(
                                                            doctor.id, true),
                                                    child: const Text('Approve'),
                                                  ),
                                                  OutlinedButton(
                                                    onPressed: () =>
                                                        handleApproval(
                                                            doctor.id, false),
                                                    child: const Text('Deny'),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
