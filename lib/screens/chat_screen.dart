import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  // API configuration
  final String baseUrl = 'https://your-api-endpoint.com/api';
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_AUTH_TOKEN' // Replace with actual auth token
  };

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // For demo purposes, add some sample messages
    _addSampleMessages();
  }

  void _addSampleMessages() {
    // This is just for demonstration - in a real app, you'd load messages from the API
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.addAll([
            {
              'id': 1,
              'senderId': widget.receiverId,
              'receiverId': widget.senderId,
              'message': 'Hello, I\'m interested in your ride.',
              'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
              'status': 'read'
            },
            {
              'id': 2,
              'senderId': widget.senderId,
              'receiverId': widget.receiverId,
              'message': 'Hi there! Sure, I still have seats available.',
              'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 55)).toIso8601String(),
              'status': 'read'
            },
            {
              'id': 3,
              'senderId': widget.receiverId,
              'receiverId': widget.senderId,
              'message': 'Great! Can I bring a small bag with me?',
              'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 50)).toIso8601String(),
              'status': 'read'
            },
            {
              'id': 4,
              'senderId': widget.senderId,
              'receiverId': widget.receiverId,
              'message': 'Yes, that\'s no problem at all.',
              'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 45)).toIso8601String(),
              'status': 'read'
            },
            {
              'id': 5,
              'senderId': widget.receiverId,
              'receiverId': widget.senderId,
              'message': 'Perfect! I\'ll see you at the pickup point.',
              'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
              'status': 'read'
            },
          ]);
          _isLoading = false;
          _scrollToBottom();
        });
      }
    });
  }

  Future<void> _loadMessages() async {
    // ===== HTTP REQUEST CODE (COMMENTED FOR DEMONSTRATION) =====
    // try {
    //   final response = await http.get(
    //     Uri.parse('$baseUrl/messages?senderId=${widget.senderId}&receiverId=${widget.receiverId}'),
    //     headers: headers,
    //   );
    //
    //   if (response.statusCode == 200) {
    //     final List<dynamic> data = json.decode(response.body);
    //     setState(() {
    //       // In a real app, you'd use the data from the API
    //       // _messages = List<Map<String, dynamic>>.from(data);
    //       _isLoading = false;
    //     });
    //     _scrollToBottom();
    //   } else {
    //     print('Failed to load messages: ${response.body}');
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // } catch (e) {
    //   print('Error loading messages: $e');
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
    // ===== END HTTP REQUEST CODE =====

    // For demonstration, we'll just use the sample messages
    _addSampleMessages();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Clear the input field immediately for better UX
    _messageController.clear();

    // Create a temporary message with "sending" status
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch, // Temporary ID
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'sending'
    };

    setState(() {
      _messages.add(newMessage);
    });

    _scrollToBottom();

    // ===== HTTP REQUEST CODE (COMMENTED FOR DEMONSTRATION) =====
    // try {
    //   final response = await http.post(
    //     Uri.parse('$baseUrl/messages'),
    //     headers: headers,
    //     body: json.encode({
    //       'senderId': widget.senderId,
    //       'receiverId': widget.receiverId,
    //       'message': message,
    //     }),
    //   );
    //
    //   if (response.statusCode == 201) {
    //     final data = json.decode(response.body);
    //
    //     // Update the message with the server-generated ID and status
    //     setState(() {
    //       final index = _messages.indexWhere((m) =>
    //       m['id'] == newMessage['id'] &&
    //           m['message'] == message
    //       );
    //
    //       if (index != -1) {
    //         _messages[index] = {
    //           'id': data['id'] ?? newMessage['id'],
    //           'senderId': widget.senderId,
    //           'receiverId': widget.receiverId,
    //           'message': message,
    //           'timestamp': data['timestamp'] ?? newMessage['timestamp'],
    //           'status': 'sent'
    //         };
    //       }
    //     });
    //   } else {
    //     print('Failed to send message: ${response.body}');
    //
    //     // Mark the message as failed
    //     setState(() {
    //       final index = _messages.indexWhere((m) =>
    //       m['id'] == newMessage['id'] &&
    //           m['message'] == message
    //       );
    //
    //       if (index != -1) {
    //         _messages[index]['status'] = 'failed';
    //       }
    //     });
    //
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Failed to send message'),
    //         backgroundColor: Colors.red,
    //         behavior: SnackBarBehavior.floating,
    //       ),
    //     );
    //
    //     setState(() {
    //       _isSending = false;
    //     });
    //     return;
    //   }
    // } catch (e) {
    //   print('Error sending message: $e');
    //
    //   // Mark the message as failed
    //   setState(() {
    //     final index = _messages.indexWhere((m) =>
    //     m['id'] == newMessage['id'] &&
    //         m['message'] == message
    //     );
    //
    //     if (index != -1) {
    //       _messages[index]['status'] = 'failed';
    //     }
    //   });
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Error sending message'),
    //       backgroundColor: Colors.red,
    //       behavior: SnackBarBehavior.floating,
    //     ),
    //   );
    //
    //   setState(() {
    //     _isSending = false;
    //   });
    //   return;
    // }
    // ===== END HTTP REQUEST CODE =====

    // For demonstration, we'll simulate the message flow
    // First update to 'sent' status
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) =>
          m['id'] == newMessage['id'] &&
              m['message'] == message
          );

          if (index != -1) {
            _messages[index]['status'] = 'sent';
          }
        });
      }
    });

    // Simulate message being delivered after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) =>
          m['senderId'] == widget.senderId &&
              m['message'] == message
          );

          if (index != -1) {
            _messages[index]['status'] = 'delivered';
          }
        });
      }
    });

    // Simulate message being read after a longer delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) =>
          m['senderId'] == widget.senderId &&
              m['message'] == message
          );

          if (index != -1) {
            _messages[index]['status'] = 'read';
          }
          _isSending = false;
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  Widget _buildMessageStatus(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'sending':
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case 'sent':
        icon = Icons.check;
        color = Colors.grey;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case 'read':
        icon = Icons.done_all;
        color = const Color(0xFF14B8A6);
        break;
      case 'failed':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      default:
        icon = Icons.check;
        color = Colors.grey;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE6FFFA),
              child: Text(
                widget.receiverName[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.receiverName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
              ),
            )
                : _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start the conversation!',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == widget.senderId;
                final timestamp = _formatTimestamp(message['timestamp']);

                // Check if we need to show a date header
                bool showDateHeader = false;
                if (index == 0) {
                  showDateHeader = true;
                } else {
                  final prevDate = DateTime.parse(_messages[index - 1]['timestamp']).day;
                  final currentDate = DateTime.parse(message['timestamp']).day;
                  showDateHeader = prevDate != currentDate;
                }

                return Column(
                  children: [
                    if (showDateHeader)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('MMMM d, yyyy').format(DateTime.parse(message['timestamp'])),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF14B8A6) : Colors.white,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(4) : null,
                            bottomLeft: !isMe ? const Radius.circular(4) : null,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timestamp,
                                  style: TextStyle(
                                    color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  _buildMessageStatus(message['status']),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions_outlined),
                            color: Colors.grey,
                            onPressed: () {
                              // Emoji picker would go here
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF14B8A6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.send_rounded),
                      color: Colors.white,
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
