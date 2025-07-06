import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/models/appointment_request.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_clerking.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  List<AppointmentRequest> appointments = [];
  List<AppointmentRequest> filteredAppointments = [];
  bool isLoading = true;
  String myId = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myId = Provider.of<UserStore>(context, listen: false).hospital?.id ?? "";
    fetchAppointments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAppointments() async {
    if (myId.isEmpty) return;
    setState(() => isLoading = true);
    try {
      final data = await _firebaseServices.getHospitalAppointmentRequests(myId);
      setState(() {
        appointments = data;
        filteredAppointments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAppointments = appointments;
      } else {
        filteredAppointments = appointments.where((appointment) {
          final name = appointment.username.toLowerCase();
          final phone = appointment.phoneNumber.toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || phone.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomTitleBar(
        title: 'Appointments',
        showBackButton: false,
      ),
      body: Container(
        decoration: backgroundDecoration(false),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: double.infinity),
                    Text(
                      'Manage your appointment requests',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by name or phone',
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
                      ? const Center(child: CustomLoadingWidget())
                      : filteredAppointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Appointments',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appointments.isEmpty
                                        ? 'You don\'t have any appointment requests yet.'
                                        : 'No appointments match your search.',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = filteredAppointments[index];
                                return AppointmentCard(
                                    appointment: appointment);
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

class AppointmentCard extends StatefulWidget {
  final AppointmentRequest appointment;

  const AppointmentCard({
    required this.appointment,
    super.key,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool isProcessing = false;
  bool isExpanded = false;

  Future<void> handleAppointmentRequest(bool approved) async {
    setState(() => isProcessing = true);
    try {
      String hospitalId =
          Provider.of<UserStore>(context, listen: false).hospital?.id ?? "";

      if (!mounted) return;

      await _firebaseServices.handleHospitalAppointmentRequest(
          hospitalId, widget.appointment.id, approved);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
      );
    } catch (error) {
      debugPrint("Error handling appointment: $error");
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Widget getStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (widget.appointment.status) {
      case AppointmentStatus.approved:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        text = 'Approved';
        break;
      case AppointmentStatus.rejected:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        text = 'Rejected';
        break;
      default:
        bgColor = Colors.yellow.shade100;
        textColor = Colors.yellow.shade700;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.appointment.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                getStatusBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.appointment.phoneNumber,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            Text(
              widget.appointment.appointmentType == 'home'
                  ? 'Home Visit'
                  : 'Consultation',
              style: const TextStyle(
                color: appPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Date',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(widget.appointment.date),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Requested ${DateFormat('dd/MM/yyyy').format(widget.appointment.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.appointment.message),
                      if (widget.appointment.status ==
                          AppointmentStatus.pending) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => handleAppointmentRequest(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 36,
                              child: OutlinedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => handleAppointmentRequest(false),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.appointment.clerkingSummary != null ||
                widget.appointment.systemsSummary != null) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Clerking Summary',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.appointment.clerkingSummary != null) ...[
                        Text(
                          widget.appointment.clerkingSummary!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (widget.appointment.systemsSummary != null)
                          const Divider(height: 24),
                      ],
                      if (widget.appointment.systemsSummary != null)
                        Text(
                          widget.appointment.systemsSummary!,
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.appointment.status == AppointmentStatus.pending) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () => handleAppointmentRequest(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing
                          ? null
                          : () => handleAppointmentRequest(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: appPrimaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  if (!widget.appointment.clerkingFinished)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HospitalClerkingPage(
                                appointmentRequest: widget.appointment,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.medical_services,
                            color: Colors.white),
                        label: const Text(
                          'Continue Clerking',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appPrimaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
            if (isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
