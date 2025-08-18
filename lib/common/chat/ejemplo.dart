import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatWidget extends StatefulWidget {
  final String? conversationId;
  final String? otherUserId;

  const ChatWidget({super.key, this.conversationId, this.otherUserId});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final supabase = Supabase.instance.client;
  late String conversationId;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    if (widget.conversationId != null) {
      conversationId = widget.conversationId!;
    } else {
      final response = await supabase.rpc(
        'create_or_get_conversation',
        params: {'other_user': widget.otherUserId},
      );
      conversationId = response as String;
    }
    setState(() {});
  }

  Stream<List<Map<String, dynamic>>> _messagesStream() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows.map((r) => r).toList());
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': supabase.auth.currentUser!.id,
      'content': text,
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (conversationId.isEmpty) return const CircularProgressIndicator();

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _messagesStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data!;
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['sender_id'] == supabase.auth.currentUser!.id;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['content']),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            )
          ],
        )
      ],
    );
  }
}