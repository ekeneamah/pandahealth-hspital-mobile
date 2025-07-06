import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/hospital.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SelectDoctorScreen extends StatefulWidget {
  final String reportId;

  const SelectDoctorScreen({super.key, required this.reportId});

  @override
  _SelectDoctorScreenState createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool isLoading = false;
  List<Doctor> doctors = [];
  Doctor? selectedDoctor;
  late Hospital hospital;

  @override
  void initState() {
    super.initState();
    hospital = Provider.of<UserStore>(context, listen: false).hospital!;
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => isLoading = true);
    try {
      final result =
          await _firebaseServices.getHospitalsDoctors(hospital.id, null);
      if (mounted) {
        setState(() {
          doctors = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load doctors: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendReport() async {
    if (selectedDoctor == null) return;

    setState(() => isLoading = true);

    try {
      await _firebaseServices.sendReportToDoctor(
        reportId: widget.reportId,
        doctorId: selectedDoctor!.id,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send report: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _generateShareLink() async {
    setState(() => isLoading = true);
    try {
      final clerkingReport =
          await _firebaseServices.getClerkingReportFromId(widget.reportId);

      if (clerkingReport != null) {
        await Share.share(
          "Tap the link to access the clerking details and collaborate on it. $clerkingTemplateBaseUrl/${clerkingReport.id}. The passcode is ${clerkingReport.passcode}",
          subject: 'PandaHealth Clerking Report',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate share link')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate share link')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Doctor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _generateShareLink,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return RadioListTile<Doctor>(
                        value: doctor,
                        groupValue: selectedDoctor,
                        title:
                            Text('Dr ${doctor.firstName} ${doctor.lastName}'),
                        subtitle: Text(doctor.speciality),
                        onChanged: (Doctor? value) {
                          setState(() => selectedDoctor = value);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: selectedDoctor == null ? null : _sendReport,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Center(
                        child: Text('Send Report'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
