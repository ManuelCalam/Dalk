import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/services/notification_service.dart';

import 'chat_model.dart';
export 'chat_model.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    String? userName,
    String? status,
    required this.walkerId,
    required this.ownerId,
    this.senderId,
  })  : userName = userName ?? '[userName]',
        status = status ?? '[status]';

  final String userName;
  final String status;
  final String walkerId;
  final String ownerId;
  final String? senderId;

  static String routeName = 'chat';
  static String routePath = '/chat';

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _supabase = Supabase.instance.client;
  final _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  RealtimeChannel? _channel;
  late TextEditingController _textController;
  String? _myUserId;

  // datos del otro usuario (dueño o paseador según corresponda)
  String? otherUserName;
  String? otherUserPhotoUrl;
  
  @override
  void initState() {
    super.initState();
    _myUserId = _supabase.auth.currentUser?.id;
    _textController = TextEditingController();
    
    if (widget.ownerId.isNotEmpty && widget.walkerId.isNotEmpty) {
      _loadOtherUserInfo();
      _loadInitial();
      _subscribeRealtime();
    }
  }

  Future<void> _loadOtherUserInfo() async {
    if (widget.ownerId.isEmpty || widget.walkerId.isEmpty || _myUserId == null) {
      return;
    }
    
    try {
      final String otherId = (_myUserId == widget.walkerId)
          ? widget.ownerId
          : widget.walkerId;

      final data = await _supabase
          .from('users')
          .select('name, photoUrl')
          .eq('uuid', otherId)
          .maybeSingle();

      if (data != null) {
        setState(() {
          otherUserName = data['name'];
          otherUserPhotoUrl = data['photoUrl'];
        });
      }
    } catch (e) {
      // Error silencioso
    }
  }
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _loadInitial() async {
    final rows = await _supabase
        .from('messages')
        .select()
        .or('and(owner_id.eq.${widget.ownerId},walker_id.eq.${widget.walkerId})')
        .order('created_at', ascending: true);

    _messages
      ..clear()
      ..addAll(List<Map<String, dynamic>>.from(rows));

    if (mounted) setState(() {});
    _jumpToBottom();
  }

  void _subscribeRealtime() {
    _channel = _supabase.channel('public:messages')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        callback: (payload) {
          final newMessage = payload.newRecord;
          // Verificamos que pertenezca al par owner-walker de este chat
          if ((newMessage['owner_id'] == widget.ownerId &&
                  newMessage['walker_id'] == widget.walkerId) ||
              (newMessage['owner_id'] == widget.walkerId &&
                  newMessage['walker_id'] == widget.ownerId)) {
            setState(() {
              _messages.add(newMessage);
            });
            _jumpToBottom();
          }
        },
      )
      ..subscribe();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _myUserId == null) return;

    final String receiverId = (_myUserId == widget.ownerId) 
        ? widget.walkerId 
        : widget.ownerId;

    try {
      await _supabase.from('messages').insert({
        'owner_id': widget.ownerId,
        'walker_id': widget.walkerId,
        'sender_id': _myUserId,
        'content': text,
      });

      _textController.clear();

      try {
        await _supabase.functions.invoke(
          'send-chat-notification', 
          body: {
            'sender_id': _myUserId,
            'receiver_id': receiverId,
            'message': text,
            'owner_id': widget.ownerId,
            'walker_id': widget.walkerId,
          }
        ).timeout(Duration(seconds: 10));
      } catch (notificationError) {
        await _showLocalFallbackNotification(text);
      }

    } catch (e) {
      _textController.text = text;
    }
  }

  Future<void> _showLocalFallbackNotification(String message) async {
    try {
      final notificationService = NotificationService();
      await notificationService.showLocalNotification(
        title: "Nuevo mensaje",
        body: "${otherUserName ?? 'Usuario'}: ${message.length > 50 ? message.substring(0, 50) + '...' : message}",
        payload: 'chat_fallback',
      );
    } catch (e) {
      // Error silencioso
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    if (_channel != null) {
      _channel!.unsubscribe();
      _supabase.removeChannel(_channel!);
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: SafeArea(
          top: true,
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).tertiary,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                /// HEADER
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.2,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    boxShadow: [
                      const BoxShadow(
                        blurRadius: 4,
                        color: Color(0xFF162C43),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Back + Title + Notifications
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: InkWell(
                              onTap: () => context.safePop(),
                              child: Icon(
                                Icons.chevron_left_outlined,
                                color: FlutterFlowTheme.of(context).accent2,
                                size: 32,
                              ),
                            ),
                          ),
                          Text(
                            'Chat',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexend(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: FlutterFlowTheme.of(context).accent2,
                                  fontSize: 18,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Icon(
                              Icons.notifications_sharp,
                              color: FlutterFlowTheme.of(context).accent2,
                              size: 32,
                            ),
                          ),
                        ],
                      ),

                      /// Avatar + Nombre
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: otherUserPhotoUrl != null
                                  ? NetworkImage(otherUserPhotoUrl!)
                                  : null,
                              child: otherUserPhotoUrl == null
                                  ? const Icon(Icons.person, size: 35)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              otherUserName ?? 'Cargando...',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 20,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// MENSAJES
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMine = msg['sender_id'] == _myUserId;
                          return Align(
                            alignment:
                                isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? FlutterFlowTheme.of(context).primary
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['content'],
                                style: TextStyle(
                                  color: isMine
                                      ? FlutterFlowTheme.of(context).info
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                /// INPUT
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.95,
                    height: MediaQuery.sizeOf(context).height * 0.065,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                controller: _textController,
                                decoration: const InputDecoration(
                                  hintText: 'Mensaje',
                                  border: InputBorder.none,
                                ),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexend(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FlutterFlowIconButton(
                          borderRadius: 35,
                          buttonSize: 45,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: Icon(
                            Icons.send,
                            color: FlutterFlowTheme.of(context).info,
                            size: 23,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
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