import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandahealthhospital/models/drug_interaction_models.dart';
import 'package:pandahealthhospital/services/drug_interaction_service.dart';


class AiChatScreen extends StatefulWidget {
  final DrugInteractionResult initialResult;
  final List<Drug> drugs;
  final PatientInfo patientInfo;

  const AiChatScreen({
    super.key,
    required this.initialResult,
    required this.drugs,
    required this.patientInfo,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DrugInteractionService _service = DrugInteractionService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    
    _initializeChat();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Add initial interaction result as first message
    final initialMessage = ChatMessage(
      id: '1',
      content: _formatInitialResult(),
      isUser: false,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.interactionResult,
    );
    
    setState(() {
      _messages.add(initialMessage);
    });
  }

  String _formatInitialResult() {
    final buffer = StringBuffer();
    
    buffer.writeln('🔍 **Drug Interaction Assessment**\n');
    buffer.writeln('**Drugs Checked:** ${widget.initialResult.drugsChecked.join(', ')}');
    buffer.writeln('**Patient Context:** ${widget.initialResult.patientContext}\n');
    
    buffer.writeln('**1. Drug Profile**');
    for (final profile in widget.initialResult.drugProfile) {
      buffer.writeln('• $profile');
    }
    buffer.writeln('');
    
    buffer.writeln('**2. Adverse Effects**');
    for (final effect in widget.initialResult.adverseEffects) {
      buffer.writeln('• $effect');
    }
    buffer.writeln('');
    
    buffer.writeln('**3. Mechanism of Action**');
    for (final mechanism in widget.initialResult.mechanismOfAction) {
      buffer.writeln('• $mechanism');
    }
    buffer.writeln('');
    
    buffer.writeln('**4. Risk Profile**');
    buffer.writeln('• **Severity:** ${widget.initialResult.riskProfile.severity}');
    buffer.writeln('• **Action:** ${widget.initialResult.riskProfile.action}');
    
    return buffer.toString();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: messageText,
      isUser: true,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.question,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Simulate AI response - replace with actual AI service call
      final aiResponse = await _service.askFollowUpQuestion(
        messageText,
        widget.drugs,
        widget.patientInfo,
        widget.initialResult,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: ChatMessageType.answer,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showErrorSnackBar('Failed to get AI response: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Drug Interaction Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'About this chat',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _ChatMessageBubble(
                    message: message,
                    onCopy: () => _copyMessage(message.content),
                  );
                },
              ),
            ),
            
            // Loading indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI is thinking...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Message input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask about drug interactions, dosages, alternatives...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    mini: true,
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drug Interaction Assistant'),
        content: const Text(
          'This AI assistant can help you with:\n\n'
          '• Drug interaction clarifications\n'
          '• Alternative medication suggestions\n'
          '• Dosage recommendations\n'
          '• Patient-specific concerns\n'
          '• Clinical guidance\n\n'
          'Always consult with healthcare professionals for final decisions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onCopy;

  const _ChatMessageBubble({
    required this.message,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: !isUser ? Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.messageType == ChatMessageType.interactionResult)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.assessment_outlined,
                            size: 16,
                            color: isUser ? Colors.white70 : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Initial Assessment',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isUser ? Colors.white70 : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUser 
                              ? Colors.white60 
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      
                      if (!isUser)
                        InkWell(
                          onTap: onCopy,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType messageType;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.messageType,
  });
}

enum ChatMessageType {
  interactionResult,
  question,
  answer,
}