import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user_model.dart';

class ChatPage extends StatefulWidget {
  final String recipientId;
  const ChatPage({super.key, required this.recipientId});
  @override
  State<ChatPage> createState() => _ChatPageState();
}



class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  StompClient? stompClient;
  bool isConnected = false;
  bool isConnecting = false;
  String connectionStatus = "Disconnected";

  Timer? reconnectTimer;

  late String userId; // userId from provider
  late String recipientId; // passed from widget

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    userId = userModel.user?['userId'].toString() ?? '';
    recipientId = widget.recipientId;
    connectToWebSocket();
  }

  void connectToWebSocket() {
    if (isConnecting || userId.isEmpty) return;

    setState(() {
      isConnecting = true;
      connectionStatus = "Connecting...";
    });

    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://localhost:8080/ws',
        onConnect: onConnect,
        onDisconnect: onDisconnect,
        onWebSocketError: (error) {
          print('WebSocket Error: $error');
          handleConnectionError();
        },
        stompConnectHeaders: {
          'userId': userId,
        },
        webSocketConnectHeaders: {
          'userId': userId,
        },
      ),
    );

    try {
      stompClient!.activate();
    } catch (e) {
      print('Error activating STOMP client: $e');
      handleConnectionError();
    }
  }

  void onConnect(StompFrame frame) {
    print('✅ Connected to WebSocket');

    setState(() {
      isConnected = true;
      isConnecting = false;
      connectionStatus = "Connected";
    });

    reconnectTimer?.cancel();

    stompClient!.subscribe(
      destination: '/user/$userId/queue/messages',
      callback: (frame) {
        if (frame.body == null) return;

        try {
          final body = jsonDecode(frame.body!);
          print('Received message: $body');

          final message = ChatMessage(
            text: body['content'] ?? 'Empty message',
            isMe: body['senderId'].toString() == userId,
            timestamp: DateTime.now(),
            status: MessageStatus.received,
          );

          setState(() {
            _messages.insert(0, message);
          });
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
    );

    registerUser();
    fetchExistingMessages();
  }

  void onDisconnect(StompFrame frame) {
    print('Disconnected from WebSocket');
    setState(() {
      isConnected = false;
      connectionStatus = "Disconnected";
    });
    handleConnectionError();
  }

  void handleConnectionError() {
    setState(() {
      isConnected = false;
      isConnecting = false;
      connectionStatus = "Connection failed. Retrying...";
    });

    reconnectTimer?.cancel();
    reconnectTimer = Timer(Duration(seconds: 5), connectToWebSocket);
  }

  void registerUser() {
    try {
      stompClient!.send(
        destination: 'users/app/user.addUser',
        body: jsonEncode({
          "userId": int.parse(userId),
          "nickName": "user$userId",
          "fullName": "User Full Name",
          "status": "ONLINE"
        }),
        headers: {"content-type": "application/json"},
      );
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  void fetchExistingMessages() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;

    final response = await http.get(
      Uri.parse('http://localhost:8080/messages/$userId/$recipientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messages = jsonDecode(response.body);
      setState(() {
        for (var msg in messages) {
          _messages.add(ChatMessage(
            text: msg['content'],
            isMe: msg['senderId'].toString() == userId,
            timestamp: DateTime.parse(msg['timestamp']),
            status: MessageStatus.received,
          ));
        }
      });
    }
  }

  void sendMessage(String text) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not connected to server. Reconnecting...'),
          backgroundColor: Colors.red,
        ),
      );
      connectToWebSocket();
      return;
    }

    final newMessage = ChatMessage(
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.insert(0, newMessage);
      _controller.clear();
    });

    try {
      final message = {
        "senderId": userId,
        "recipientId": recipientId,
        "content": text,
        "timestamp": DateTime.now().toIso8601String(),
      };

      stompClient!.send(
        destination: '/app/chat',
        body: jsonEncode(message),
        headers: {"content-type": "application/json"},
      );

      setState(() {
        newMessage.status = MessageStatus.sent;
      });
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        newMessage.status = MessageStatus.failed;
      });
    }
  }

  @override
  void dispose() {
    reconnectTimer?.cancel();
    stompClient?.deactivate();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with User $recipientId'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  connectionStatus,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text('No messages yet'))
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(message: msg);
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) sendMessage(text);
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) sendMessage(text);
                  },
                  child: Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


enum MessageStatus {
  sending, sent, delivered, received, read, failed
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  MessageStatus status;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.status = MessageStatus.sending,
  });
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text),
            SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                if (message.isMe) SizedBox(width: 4),
                if (message.isMe)
                  Icon(
                    _getStatusIcon(message.status),
                    size: 12,
                    color: message.status == MessageStatus.failed
                        ? Colors.red
                        : Colors.grey[600],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.received:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
      default:
        return Icons.check;
    }
  }
}