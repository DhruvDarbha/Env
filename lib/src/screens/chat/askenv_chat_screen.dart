import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/message.dart';
import '../../models/recipe.dart';
import '../../services/cerebras_service.dart';
import '../../services/recipe_storage_service.dart';
import '../../widgets/background_wrapper_light.dart';

class AskEnvChatScreen extends StatefulWidget {
  final String? imageContext;
  final String? imagePath;

  const AskEnvChatScreen({
    super.key,
    this.imageContext,
    this.imagePath,
  });

  @override
  State<AskEnvChatScreen> createState() => _AskEnvChatScreenState();
}

class _AskEnvChatScreenState extends State<AskEnvChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _hasShownImageContext = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Add welcome message
    _messages.add(Message(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      content: '👋 Hi! I\'m AskEnv, your environmental sustainability assistant. I can help you with food analysis, storage tips, recipe suggestions, and waste reduction strategies. How can I assist you today?',
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      senderName: 'AskEnv',
    ));

    // If there's image context, show it and ask about it
    if (widget.imageContext != null && widget.imageContext!.isNotEmpty) {
      _messages.add(Message(
        id: 'context_${DateTime.now().millisecondsSinceEpoch}',
        content: '🔍 I can see you just analyzed some food! Based on the analysis results, feel free to ask me about storage recommendations, freshness tips, recipe ideas, or anything else related to your food.',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        senderName: 'AskEnv',
      ));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    final userMessage = Message(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: messageText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Include image context only on first message or if specifically asking about the image
      String? contextToInclude;
      if (!_hasShownImageContext && widget.imageContext != null) {
        contextToInclude = widget.imageContext;
        _hasShownImageContext = true;
      }

      final botResponse = await CerebrasService.sendChatMessage(
        userMessage: messageText,
        imageContext: contextToInclude,
        imagePath: widget.imagePath,
        previousMessages: _messages.where((m) => m.sender != MessageSender.bot || m.senderName == 'AskEnv').toList(),
      );

      setState(() {
        _messages.add(botResponse);
        _isLoading = false;
      });

      _scrollToBottom();

      // Check if the response contains a recipe and prompt to save
      if (botResponse.detectedRecipe != null) {
        _promptToSaveRecipe(botResponse.detectedRecipe!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _promptToSaveRecipe(Recipe recipe) async {
    // Add a small delay to let the message appear first
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Recipe Detected!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AskEnv shared a recipe for "${recipe.name}". Would you like to save it to your Recipes tab?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 16,
                      ),
                    ),
                    if (recipe.servings > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Serves ${recipe.servings}',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (recipe.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${recipe.ingredients.length} ingredients',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Not Now',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveRecipeToTab(recipe);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save Recipe'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRecipeToTab(Recipe recipe) async {
    try {
      final success = await RecipeStorageService.saveRecipe(recipe);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Recipe "${recipe.name}" saved to Recipes tab!'),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to Recipes tab (assuming it's tab index 1 in consumer dashboard)
                context.pop(); // Close chat
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save recipe. Please try again.'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving recipe: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AskEnv',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Environmental AI Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        elevation: 1,
      ),
      body: BackgroundWrapperLight(
        child: Column(
          children: [
            // Image context display (if available)
            if (widget.imagePath != null) _buildImageContextHeader(),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingMessage();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Input field
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContextHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(widget.imagePath!),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Context info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📸 Analyzed Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ask me about this food analysis!',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // AskEnv can see the image indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'AskEnv can see this',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.sender == MessageSender.user;
    final isAskEnv = message.senderName == 'AskEnv';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isAskEnv ? Colors.green[600] : Colors.blue[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isAskEnv ? Icons.eco : Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.green[600]
                    : (isAskEnv ? Colors.green[50] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
                border: isAskEnv && !isUser
                    ? Border.all(color: Colors.green[200]!)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser && message.senderName != null) ...[
                    Text(
                      message.senderName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isAskEnv ? Colors.green[700] : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isAskEnv ? Colors.green[800] : Colors.black87),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            // User avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AskEnv avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.eco,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),

          // Loading bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AskEnv is thinking...',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask AskEnv about food, sustainability, recipes...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.green[600]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: _isLoading ? Colors.grey[400] : Colors.green[600],
                  ),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ],
      ),
    );
  }
}