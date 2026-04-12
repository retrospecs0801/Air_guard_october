// lib/community/community_screen.dart

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../screens/community/policy_simulation_tab.dart';

// =============================================================================
// DATA MODEL & SERVICE (Moved from original chat file)
// =============================================================================
class CommunityMessage {
  final String id;
  final String userName;
  final String userAvatar;
  final String message;
  final DateTime timestamp;
  final bool isCurrentUser;

  CommunityMessage({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.message,
    required this.timestamp,
    this.isCurrentUser = false,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}';
  }
}

class _MessageService {
  static List<CommunityMessage> _messages = [];

  static List<CommunityMessage> getMessages() {
    if (_messages.isEmpty) _initializeMockData();
    return List.from(_messages.reversed);
  }

  static void addMessage(String text) {
    _messages.add(CommunityMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'You',
      userAvatar: '😊',
      message: text,
      timestamp: DateTime.now(),
      isCurrentUser: true,
    ));
  }

  static void _initializeMockData() {
    final now = DateTime.now();
    _messages = [
      CommunityMessage(
        id: '1',
        userName: 'Priya Sharma',
        userAvatar: '👩',
        message: 'The air quality in Gomti Nagar is terrible today.',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      CommunityMessage(
        id: '2',
        userName: 'Rahul Verma',
        userAvatar: '👨',
        message: 'I\'ve started using N95 masks daily. It helps a lot.',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }
}

// =============================================================================
// MAIN TABBED SCREEN
// =============================================================================
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: const Color(0xFFF4F6F8),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            snap: true,
            pinned: true,
            title: const Text(
              'Community',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: 0.3,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                color: const Color(0xFFF4F6F8),
                child: TabBar(
                  controller: _tabController,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  labelColor: const Color(0xFF1E293B),
                  unselectedLabelColor: const Color(0xFF9CA3AF),
                  indicatorColor: const Color(0xFF0F766E),
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'Discussion'),
                    Tab(text: 'Policy Sim'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _DiscussionTab(), // Integrated Chat UI
            PolicySimulationTab(),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// INTEGRATED DISCUSSION TAB (Original Chat logic)
// =============================================================================
class _DiscussionTab extends StatefulWidget {
  const _DiscussionTab();

  @override
  State<_DiscussionTab> createState() => _DiscussionTabState();
}

class _DiscussionTabState extends State<_DiscussionTab> {
  late List<CommunityMessage> _messages;
  final _textController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messages = _MessageService.getMessages();
    _textController.addListener(() {
      setState(() => _hasText = _textController.text.trim().isNotEmpty);
    });
  }

  void _handleSendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _MessageService.addMessage(text);
        _messages = _MessageService.getMessages();
        _textController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message posted to community!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildMessageList()),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(child: Text('No messages yet. Start the conversation!'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
    );
  }

  Widget _buildMessageBubble(CommunityMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: message.isCurrentUser ? Colors.green.shade200 : Colors.blue.shade100,
            child: Text(message.userAvatar, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(message.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 8),
                    Text(message.formattedTime, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isCurrentUser ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: message.isCurrentUser ? Colors.green.shade200 : Colors.grey.shade300),
                  ),
                  child: Text(message.message, style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _hasText ? _handleSendMessage : null,
            icon: Icon(Icons.send, color: _hasText ? Colors.green : Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}