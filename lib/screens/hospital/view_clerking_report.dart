import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/models/chat_message.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/clerking_report.dart';
import 'package:pandahealthhospital/screens/hospital/select_doctor.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pandahealthhospital/screens/hospital/document_viewer.dart';

class ClerkingReportDetail extends StatefulWidget {
  final ClerkingReport clerkingReport;

  const ClerkingReportDetail({super.key, required this.clerkingReport});

  @override
  _ClerkingReportDetailState createState() => _ClerkingReportDetailState();
}

class _ClerkingReportDetailState extends State<ClerkingReportDetail>
    with SingleTickerProviderStateMixin {
  late TextEditingController _doctorNotesController;
  late TabController _tabController;
  bool _isLoading = false;
  bool _hasChanges = false;
  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _doctorNotesController =
        TextEditingController(text: widget.clerkingReport.doctorsNotes);
    _doctorNotesController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final hasChanges =
        _doctorNotesController.text != widget.clerkingReport.doctorsNotes;
    if (_hasChanges != hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title:
              const Text('Clerking Report', style: TextStyle(color: darkBlue)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: appPrimaryColor,
            labelColor: appPrimaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Analysis'),
              Tab(text: 'Chat'),
            ],
          ),
          actions: [
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    'Unsaved changes',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ),
              ),
            _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: darkBlue),
                    ),
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: darkBlue),
                        onPressed: _shareWithDoctor,
                      ),
                      if (_hasChanges)
                        IconButton(
                          icon: const Icon(Icons.save, color: darkBlue),
                          onPressed: _updateReport,
                        ),
                    ],
                  ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AnalysisTabView(
              clerkingReport: widget.clerkingReport,
              doctorNotesController: _doctorNotesController,
              isLoading: _isLoading,
              onUpdateReport: _updateReport,
            ),
            ChatTabView(
              clerkingReportId: widget.clerkingReport.id,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'You have unsaved changes. Do you want to save them before leaving?'),
          actions: [
            TextButton(
              child: const Text('Discard'),
              onPressed: () {
                _doctorNotesController.clear();
                Navigator.of(context).pop(false);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                await _updateReport();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  Future<void> _shareWithDoctor() async {
    if (_hasChanges) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Save changes before sharing?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        await _updateReport();
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDoctorScreen(
          reportId: widget.clerkingReport.id,
        ),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report shared successfully')),
      );
    }
  }

  Future<void> _updateReport() async {
    setState(() {
      _isLoading = true;
    });

    // Call your update function here
    bool success = await _firebaseServices.updateClerkingReport(
        widget.clerkingReport.id,
        {'doctorsNotes': _doctorNotesController.text});

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report updated')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to update report')));
    }

    setState(() {
      _isLoading = false;
    });
  }
}

class ChatTabView extends StatefulWidget {
  final String clerkingReportId;

  const ChatTabView({
    super.key,
    required this.clerkingReportId,
  });

  @override
  State<ChatTabView> createState() => _ChatTabViewState();
}

class _ChatTabViewState extends State<ChatTabView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    if (!mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && mounted) {
      setState(() => _isUploading = true);
      try {
        final file = result.files.first;
        final imageUrl = await _firebaseServices.uploadFile(
          file.path!,
          'clerking_chats/${widget.clerkingReportId}/${DateTime.now().millisecondsSinceEpoch}',
        );

        if (!mounted) return;

        final userId =
            Provider.of<UserStore>(context, listen: false).hospital?.id;
        await _firebaseServices.sendClerkingReportMessage(
          userId!,
          widget.clerkingReportId,
          '',
          patientPhone: null,
          type: 'image',
          imageUrl: imageUrl,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _isUploading ? null : _pickImage,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.image, color: appPrimaryColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: appPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _firebaseServices
                .listenForClerkingReportChat(widget.clerkingReportId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!;

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.sender ==
                      Provider.of<UserStore>(context, listen: false)
                          .hospital
                          ?.id;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? appPrimaryColor : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMessageContent(message, isMe),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        _buildInputSection(),
      ],
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userId = Provider.of<UserStore>(context, listen: false).hospital?.id;

    _firebaseServices.sendClerkingReportMessage(
        userId!, widget.clerkingReportId, _messageController.text.trim());

    _messageController.clear();
  }

  Widget _buildMessageContent(ChatMessage message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.imageUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (message.message.isNotEmpty)
          Text(
            message.message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          DateFormat.jm().format(message.timestamp),
          style: TextStyle(
            fontSize: 12,
            color: isMe ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class AnalysisTabView extends StatelessWidget {
  final ClerkingReport clerkingReport;
  final TextEditingController doctorNotesController;
  final bool isLoading;
  final Function onUpdateReport;
  final FirebaseServices _firebaseServices = FirebaseServices();

  AnalysisTabView({
    super.key,
    required this.clerkingReport,
    required this.doctorNotesController,
    required this.isLoading,
    required this.onUpdateReport,
  });

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildTextField(
    String label, {
    TextEditingController? controller,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        labelText: label,
      ),
    );
  }

  Widget _buildDoctorTile(String doctorId) {
    return FutureBuilder<Doctor?>(
      future: _firebaseServices.getDoctorFromId(doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(strokeWidth: 2),
            title: Text('Loading...'),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const ListTile(
            leading: Icon(Icons.error_outline, color: Colors.red),
            title: Text('Doctor not found'),
          );
        }

        final doctor = snapshot.data!;
        return ListTile(
          leading: const Icon(Icons.person, color: darkBlue),
          title: Text('Dr. ${doctor.firstName} ${doctor.lastName}'),
          subtitle: Text(doctor.email),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Created on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(clerkingReport.createdOn))}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Passcode: ${clerkingReport.passcode}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Doctor\'s Notes',
                  _buildTextField(
                    '',
                    controller: doctorNotesController,
                    maxLines: 5,
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'AI Analysis',
                  Text(
                    clerkingReport.aiAnalysis,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
                if (clerkingReport.doctors.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSection(
                    'Shared With',
                    Column(
                      children: clerkingReport.doctors
                          .map((doctorId) =>
                              _buildDoctorTile(doctorId.toString()))
                          .toList(),
                    ),
                  ),
                ],
                if (clerkingReport.documents.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSection(
                    'Attached Documents',
                    Column(
                      children:
                          clerkingReport.documents.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;

                        return ListTile(
                          leading: const Icon(Icons.attach_file),
                          title: Text('Document ${index + 1}'),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                child: DocumentViewer(
                                  url: doc,
                                  title: 'Document ${index + 1}',
                                ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () =>
                                openLink(doc), // Open in external browser
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
