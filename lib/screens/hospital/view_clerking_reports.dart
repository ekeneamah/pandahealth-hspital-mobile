import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/models/clerking_report.dart';
import 'package:pandahealthhospital/screens/hospital/view_clerking_report.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ViewClerkingReports extends StatefulWidget {
  const ViewClerkingReports({super.key});

  @override
  _ViewClerkingReportsState createState() => _ViewClerkingReportsState();
}

class _ViewClerkingReportsState extends State<ViewClerkingReports> {
  List<ClerkingReport> reports = [];
  List<ClerkingReport> filteredReports = [];
  bool isLoading = false;
  late String hospitalId;
  final FirebaseServices _firebaseServices = FirebaseServices();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hospitalId = Provider.of<UserStore>(context, listen: false).hospital!.id;
    fetchClerkingReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchClerkingReports() async {
    setState(() => isLoading = true);
    try {
      final fetchedReports =
          await _firebaseServices.getHospitalsClerkingReports(hospitalId, null);
      setState(() {
        reports = fetchedReports;
        filteredReports = fetchedReports;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reports: ${e.toString()}')),
      );
    }
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReports = reports;
      } else {
        filteredReports = reports.where((report) {
          final searchLower = query.toLowerCase();
          final aiAnalysis = report.aiAnalysis.toLowerCase();
          final date = DateFormat('dd/MM/yyyy')
              .format(adjustServerTime(report.createdOn));

          return aiAnalysis.contains(searchLower) || date.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:
            const Text('Clerking Reports', style: TextStyle(color: darkBlue)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: _handleSearch,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: darkBlue))
                : RefreshIndicator(
                    onRefresh: fetchClerkingReports,
                    child: filteredReports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'images/empty.png',
                                  width: 150,
                                  height: 100,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  reports.isEmpty
                                      ? 'No Reports Available'
                                      : 'No matching reports found',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ClerkingReportDetail(
                                        clerkingReport: report,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 16,
                                                color: appPrimaryColor),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat('dd/MM/yyyy HH:mm')
                                                  .format(adjustServerTime(
                                                      report.createdOn)),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delete Report'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this report? This action cannot be undone.'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                        onPressed: () async {
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() =>
                                                              isLoading = true);
                                                          final success =
                                                              await _firebaseServices
                                                                  .deleteClerkingReport(
                                                                      report
                                                                          .id);
                                                          setState(() =>
                                                              isLoading =
                                                                  false);
                                                          if (success) {
                                                            setState(() {
                                                              reports.removeWhere(
                                                                  (r) =>
                                                                      r.id ==
                                                                      report
                                                                          .id);
                                                              filteredReports
                                                                  .removeWhere(
                                                                      (r) =>
                                                                          r.id ==
                                                                          report
                                                                              .id);
                                                            });
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Report deleted successfully')),
                                                            );
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Failed to delete report')),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          report.aiAnalysis.length > 100
                                              ? '${report.aiAnalysis.substring(0, 100)}...'
                                              : report.aiAnalysis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
