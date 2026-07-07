import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pilot_repair/models/chat_message.dart';
import 'package:pilot_repair/models/order.dart';
import 'package:pilot_repair/services/api_service.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:pilot_repair/services/user_api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatPage extends StatefulWidget {
  final Order order;

  const ChatPage({
    super.key,
    required this.order,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _refreshTimer;
  String _otherUserName = '';
  String _userRole = '';
  bool _isTechnician = false;

  // Modern color scheme
  final Color primaryColor = const Color(0xFF0077FF);
  final Color secondaryColor = const Color(0xFF1ABC9C);
  final Color accentColor = const Color(0xFFE8F8F5);
  final Color successColor = const Color(0xFF16A07A);
  final Color warningColor = const Color(0xFFF59E0B);
  final Color dangerColor = const Color(0xFFDC2626);
  final Color surfaceColor = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadMessages();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) return;

      _isTechnician = currentUser.role == 'technician';

      if (_isTechnician) {
        // If current user is technician, load customer data
        if (widget.order.userId != null) {
          final customer = await UserApiService.getUserProfile(widget.order.userId!);
          if (mounted) {
            setState(() {
              _otherUserName = customer.name;
              _userRole = customer.role; // Role berdasarkan nama user
            });
          }
        } else {
          setState(() {
            _otherUserName = 'Pelanggan';
            _userRole = 'Pelanggan';
          });
        }
      } else {
        // If current user is customer, load technician data
        if (widget.order.technicianId != null) {
          final technician = await UserApiService.getUserProfile(widget.order.technicianId!);
          if (mounted) {
            setState(() {
              _otherUserName = technician.name;
              _userRole = technician.role; // Role berdasarkan nama user
            });
          }
        } else {
          setState(() {
            _otherUserName = 'Teknisi';
            _userRole = 'Teknisi';
          });
        }
      }
    } catch (e) {
      // Set default values if loading fails
      setState(() {
        _otherUserName = _isTechnician ? 'Pelanggan' : 'Teknisi';
        _userRole = _isTechnician ? 'Pelanggan' : 'Teknisi';
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await ApiService.fetchChatMessages(widget.order.id!);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pesan: $e'),
            backgroundColor: dangerColor,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String content, {String messageType = 'text'}) async {
    if (content.trim().isEmpty) return;

    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk mengirim pesan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final newMessage = await ApiService.sendChatMessage(
        orderId: widget.order.id!,
        senderId: currentUser.id!,
        content: content,
        messageType: messageType,
      );

      setState(() {
        _messages.add(newMessage);
        _isSending = false;
      });

      _messageController.clear();
      _scrollToBottom();
      await _loadMessages();
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim pesan: $e'),
          backgroundColor: dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _otherUserName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              _userRole,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(successColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat pesan...',
                          style: GoogleFonts.inter(
                            color: textColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada pesan',
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Segera lakukan pemesanan untuk memulai chat',
                              style: GoogleFonts.inter(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/',
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart, size: 18),
                              label: const Text('Buat Pesanan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: successColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                          final isMe = message.senderId == AuthService.currentUser?.id;
                          final isSystem = message.messageType == 'system';
                          final isQuickReply = message.messageType == 'quick_reply';

                          return _buildMessageBubble(
                            message,
                            isMe: isMe,
                            isSystem: isSystem,
                            isQuickReply: isQuickReply,
                          ).animate().fadeIn(duration: 300.ms).slideY(
                                begin: 0.3,
                                end: 0,
                                duration: 300.ms,
                                curve: Curves.easeOut,
                              );
                        },
                      ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      hintStyle: GoogleFonts.inter(
                        color: textColor.withOpacity(0.4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: successColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _isSending
                        ? null
                        : () => _sendMessage(_messageController.text),
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message, {
    required bool isMe,
    required bool isSystem,
    required bool isQuickReply,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSystem || (isSystem && !isMe)) ...[
            if (!isMe || (isSystem && !isMe)) ...[
              // Avatar lawan bicara di kiri (termasuk pesan system yang masuk ke teknisi)
              Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: successColor.withOpacity(0.2),
                    child: Text(
                      (message.senderName?.isNotEmpty == true ? message.senderName![0].toUpperCase() : 'U'),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: successColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ]
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (isSystem && isMe)
                      ? successColor
                      : (isSystem && !isMe)
                          ? Colors.white
                          : isMe
                              ? successColor
                              : Colors.white,
                  borderRadius: BorderRadius.circular(20).copyWith(
                    bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.18),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((message.senderName?.isNotEmpty ?? false) && (!isSystem || (isSystem && !isMe)))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          message.senderName!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (isSystem && !isMe)
                                ? Colors.white.withOpacity(0.85)
                                : isMe
                                    ? Colors.white.withOpacity(0.85)
                                    : textColor.withOpacity(0.85),
                          ),
                        ),
                      ),
                    Text(
                      message.content,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: (isSystem && isMe)
                            ? Colors.white
                            : (isSystem && !isMe)
                                ? textColor
                                : isMe
                                    ? Colors.white
                                    : textColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm', 'id_ID').format(
                        message.createdAt?.toLocal() ?? DateTime.now().toLocal()
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: (isSystem && isMe)
                            ? Colors.white.withOpacity(0.8)
                            : (isSystem && !isMe)
                                ? textColor.withOpacity(0.5)
                                : isMe
                                    ? Colors.white.withOpacity(0.8)
                                    : textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if ((isMe && !isSystem) || (isSystem && isMe)) ...[
            const SizedBox(width: 8),
            // Avatar pengirim di kanan (termasuk pesan system yang dikirim sendiri)
            Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: successColor.withOpacity(0.2),
                  child: Text(
                    (AuthService.currentUser?.name?.isNotEmpty == true ? AuthService.currentUser!.name![0].toUpperCase() : 'S'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: successColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 