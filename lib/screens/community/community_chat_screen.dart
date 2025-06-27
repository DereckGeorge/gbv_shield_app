import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../auth/provider/auth_provider.dart';
import 'dart:convert';

class CommunityMessage {
  final String id;
  final String content;
  final String userId;
  final String userName;
  final DateTime createdAt;
  List<CommunityReply> replies;
  int likesCount;
  bool isLikedByUser;
  bool isSelected;

  CommunityMessage({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.replies,
    required this.likesCount,
    required this.isLikedByUser,
    this.isSelected = false,
  });

  factory CommunityMessage.fromJson(Map<String, dynamic> json) {
    return CommunityMessage(
      id: json['id'],
      content: json['content'],
      userId: json['user']['id'],
      userName: json['user']['name'],
      createdAt: DateTime.parse(json['created_at']),
      replies: (json['replies'] as List?)
          ?.map((reply) => CommunityReply.fromJson(reply))
          .toList() ?? [],
      likesCount: json['likes_count'] ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
    );
  }
}

class CommunityReply {
  final String id;
  final String content;
  final String userId;
  final String userName;
  final DateTime createdAt;
  int likesCount;
  bool isLikedByUser;
  bool isSelected;

  CommunityReply({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.likesCount,
    required this.isLikedByUser,
    this.isSelected = false,
  });

  factory CommunityReply.fromJson(Map<String, dynamic> json) {
    return CommunityReply(
      id: json['id'],
      content: json['content'],
      userId: json['user']['id'],
      userName: json['user']['name'],
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'] ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
    );
  }
}

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({Key? key}) : super(key: key);

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CommunityMessage> _messages = [];
  final Set<String> _selectedMessageIds = {};
  final Set<String> _selectedReplyIds = {};
  CommunityMessage? _replyToMessage;
  String? _lastTimestamp;
  Timer? _pollingTimer;
  bool _isLoading = false;
  String? _currentUserId;
  late ApiService _apiService;
  bool _isInSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    _scrollController.addListener(_onScroll);
    _initApiService();
    _startPolling();
  }

  void _onScroll() {
    // Add this to prevent unnecessary scrolling while user is actively scrolling
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      return;
    }
  }

  Future<void> _initApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    await _loadMessages();
    _scrollToBottom();
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

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isLoading) {
        _loadMessages();
      }
    });
  }

  Future<void> _loadMessages() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.get(
        '/api/community/messages',
        requiresAuth: true,
      );

      if (response != null) {
        final List<CommunityMessage> newMessages = (response['data']['data'] as List)
            .map((message) => CommunityMessage.fromJson(message))
            .toList();

        setState(() {
          // Keep existing messages if they're not in the new list
          final existingMessages = Map.fromEntries(
            _messages.map((m) => MapEntry(m.id, m)),
          );

          // Update existing messages with new data
          for (var newMessage in newMessages) {
            if (existingMessages.containsKey(newMessage.id)) {
              final existing = existingMessages[newMessage.id]!;
              // Preserve selection state and update other properties
              newMessage.isSelected = existing.isSelected;
              // If the message was liked by the user, preserve that state
              if (existing.isLikedByUser) {
                newMessage.isLikedByUser = true;
              }
            }
          }

          _messages.clear();
          _messages.addAll(newMessages);
          // Sort messages by createdAt in ascending order (oldest to newest)
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _isLoading = false;
        });

        // Scroll to bottom on initial load or when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final endpoint = _replyToMessage != null 
          ? '/api/community/messages/${_replyToMessage!.id}/reply'
          : '/api/community/messages';

      final response = await _apiService.post(
        endpoint,
        {'content': _messageController.text.trim()},
        requiresAuth: true,
      );

      if (response != null) {
        _messageController.clear();
        setState(() => _replyToMessage = null);
        
        // Add the new message immediately
        if (response['data'] != null) {
          if (_replyToMessage != null) {
            // Handle reply
            final newReply = CommunityReply.fromJson(response['data']);
            setState(() {
              final parentMessage = _messages.firstWhere(
                (m) => m.id == _replyToMessage!.id,
              );
              parentMessage.replies.add(newReply);
            });
          } else {
            // Handle new message
            final newMessage = CommunityMessage.fromJson(response['data']);
            setState(() {
              _messages.add(newMessage);
              _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            });
          }
          // Ensure we scroll to bottom after sending a message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<void> _toggleLike(String messageId) async {
    try {
      final response = await _apiService.post(
        '/api/community/messages/$messageId/toggle-like',
        {},
        requiresAuth: true,
      );

      if (response != null) {
        setState(() {
          final message = _messages.firstWhere((m) => m.id == messageId);
          message.isLikedByUser = response['is_liked_by_user'];
          message.likesCount = response['likes_count'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling like: $e')),
      );
    }
  }

  Future<void> _toggleReplyLike(String replyId) async {
    try {
      final response = await _apiService.post(
        '/api/community/replies/$replyId/toggle-like',
        {},
        requiresAuth: true,
      );

      if (response != null) {
        setState(() {
          for (var message in _messages) {
            for (var reply in message.replies) {
              if (reply.id == replyId) {
                reply.isLikedByUser = response['is_liked_by_user'];
                reply.likesCount = response['likes_count'];
                break;
              }
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling reply like: $e')),
      );
    }
  }

  void _toggleMessageSelection(CommunityMessage message) {
    setState(() {
      message.isSelected = !message.isSelected;
      if (message.isSelected) {
        _selectedMessageIds.add(message.id);
        // When selecting a message, also select all its replies
        for (var reply in message.replies) {
          reply.isSelected = true;
          _selectedReplyIds.add(reply.id);
        }
      } else {
        _selectedMessageIds.remove(message.id);
        // Deselect all replies of this message when message is deselected
        for (var reply in message.replies) {
          reply.isSelected = false;
          _selectedReplyIds.remove(reply.id);
        }
      }
      _isInSelectionMode = _selectedMessageIds.isNotEmpty || _selectedReplyIds.isNotEmpty;
    });
  }

  void _toggleReplySelection(CommunityReply reply, CommunityMessage parentMessage) {
    setState(() {
      reply.isSelected = !reply.isSelected;
      if (reply.isSelected) {
        _selectedReplyIds.add(reply.id);
        // If all replies are selected, also select the parent message
        if (parentMessage.replies.every((r) => r.isSelected)) {
          parentMessage.isSelected = true;
          _selectedMessageIds.add(parentMessage.id);
        }
      } else {
        _selectedReplyIds.remove(reply.id);
        // If any reply is deselected, also deselect the parent message
        parentMessage.isSelected = false;
        _selectedMessageIds.remove(parentMessage.id);
      }
      _isInSelectionMode = _selectedMessageIds.isNotEmpty || _selectedReplyIds.isNotEmpty;
    });
  }

  Future<void> _deleteSelected() async {
    try {
      final List<Future> deletionFutures = [];

      // Delete messages
      if (_selectedMessageIds.isNotEmpty) {
        deletionFutures.add(
          _apiService.post(
            '/api/community/messages/bulk-delete',
            {'message_ids': _selectedMessageIds.toList()},
            requiresAuth: true,
          ),
        );
      }

      // Delete replies
      if (_selectedReplyIds.isNotEmpty) {
        deletionFutures.add(
          _apiService.post(
            '/api/community/replies/bulk-delete',
            {'reply_ids': _selectedReplyIds.toList()},
            requiresAuth: true,
          ),
        );
      }

      // Wait for all deletion requests to complete
      await Future.wait(deletionFutures);

      // Clear selection state
      setState(() {
        _selectedMessageIds.clear();
        _selectedReplyIds.clear();
        for (var message in _messages) {
          message.isSelected = false;
          for (var reply in message.replies) {
            reply.isSelected = false;
          }
        }
        _isInSelectionMode = false;
      });

      // Reload messages to reflect deletions
      await _loadMessages();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected items deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting selected items: $e')),
      );
    }
  }

  Widget _buildReplyBubble(CommunityReply reply, bool isCurrentUser, CommunityMessage parentMessage) {
    return GestureDetector(
      onLongPress: () {
        if (!_isInSelectionMode) {
          setState(() => _isInSelectionMode = true);
        }
        _toggleReplySelection(reply, parentMessage);
      },
      child: Container(
        margin: EdgeInsets.only(
          left: isCurrentUser ? 64 : 16,
          right: isCurrentUser ? 8 : 64,
          bottom: 2,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 100,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: reply.isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : isCurrentUser
                          ? const Color(0xFFE8E3FF)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isCurrentUser 
                            ? const Color(0xFFD8D0FF)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                        border: Border(
                          left: BorderSide(
                            color: isCurrentUser 
                                ? const Color(0xFF7C3AED)
                                : Colors.grey[400]!,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            parentMessage.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isCurrentUser 
                                  ? const Color(0xFF7C3AED)
                                  : Colors.grey[700],
                            ),
                          ),
                          Text(
                            parentMessage.content,
                        style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      reply.content,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(reply.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _toggleReplyLike(reply.id),
                        child: Row(
                          children: [
                              Icon(
                                reply.isLikedByUser ? Icons.favorite : Icons.favorite_border,
                                size: 13,
                                color: reply.isLikedByUser ? Colors.red : Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                reply.likesCount.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(CommunityMessage message, bool isCurrentUser) {
    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        setState(() => _replyToMessage = message);
        return false;
      },
      child: GestureDetector(
        onLongPress: () {
          if (!_isInSelectionMode) {
            setState(() => _isInSelectionMode = true);
          }
          _toggleMessageSelection(message);
        },
        onTap: () {
          if (_isInSelectionMode) {
            _toggleMessageSelection(message);
          }
        },
        child: Container(
          margin: EdgeInsets.only(
            left: isCurrentUser ? 64 : 8,
            right: isCurrentUser ? 8 : 64,
            bottom: message.replies.isEmpty ? 4 : 2,
          ),
          child: Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                  minWidth: 100,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: message.isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : isCurrentUser
                            ? const Color(0xFFE8E3FF)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isCurrentUser ? const Color(0xFF7C3AED) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message.content,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _toggleLike(message.id),
                            child: Row(
                              children: [
                                Icon(
                                  message.isLikedByUser ? Icons.favorite : Icons.favorite_border,
                                  size: 13,
                                  color: message.isLikedByUser ? Colors.red : Colors.grey[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  message.likesCount.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
                    ],
                  ),
                ),
              ),
              if (message.replies.isNotEmpty) ...[
                const SizedBox(height: 2),
                ...message.replies.map((reply) {
                  final isReplyFromCurrentUser = reply.userId == _currentUserId;
                  return _buildReplyBubble(reply, isReplyFromCurrentUser, message);
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isInSelectionMode 
            ? const Text('Community Chat')
            : Text('${_selectedMessageIds.length + _selectedReplyIds.length} Selected'),
        backgroundColor: const Color(0xFF7C3AED),
        actions: _isInSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedMessageIds.clear();
                      _selectedReplyIds.clear();
                      for (var message in _messages) {
                        message.isSelected = false;
                        for (var reply in message.replies) {
                          reply.isSelected = false;
                        }
                      }
                      _isInSelectionMode = false;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (_isLoading && _messages.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = message.userId == _currentUserId;
                  return _buildMessageBubble(message, isCurrentUser);
                },
              ),
            ),
          if (_replyToMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
                  child: Row(
                    children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Text(
                          'Replying to ${_replyToMessage!.userName}',
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                          _replyToMessage!.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                      ),
                    ],
                  ),
                ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _replyToMessage = null),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
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
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF7C3AED),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
