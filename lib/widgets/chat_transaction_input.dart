import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import '../core/constants/colors.dart';
import '../features/transactions/presentation/cubit/transaction_cubit.dart';

class ChatTransactionInput extends StatefulWidget {
  final VoidCallback? onTransactionSaved;

  const ChatTransactionInput({super.key, this.onTransactionSaved});

  @override
  State<ChatTransactionInput> createState() => _ChatTransactionInputState();
}

class _ChatTransactionInputState extends State<ChatTransactionInput> {
  final textController = TextEditingController();
  final List<ChatMessage> messages = [];
  bool isLoading = false;
  static const String _chatHistoryKey = 'chat_transaction_history';

  final ImagePicker _imagePicker = ImagePicker();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _initSpeech();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    // Speech to text tidak support dengan baik di web
    // Gunakan Web Speech API untuk web (future enhancement)
    if (kIsWeb) {
      _speechAvailable = false;
      setState(() {});
      return;
    }

    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    setState(() {});
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_chatHistoryKey);

      if (historyJson != null) {
        final decoded = json.decode(historyJson);
        final List<dynamic> historyList = decoded as List<dynamic>;
        setState(() {
          messages.clear();
          messages.addAll(
            historyList
                .map(
                  (item) => ChatMessage.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        messages.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString(_chatHistoryKey, historyJson);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  Future<void> _clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
      setState(() {
        messages.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Riwayat chat dihapus')));
      }
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
    }
  }

  // Upload Image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          messages.add(
            ChatMessage(
              text: '📷 Gambar diunggah: ${image.name}',
              isUser: true,
              timestamp: DateTime.now(),
            ),
          );
          isLoading = true;
        });
        await _saveChatHistory();

        // TODO: Process image with OCR API
        // For now, show placeholder response
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          isLoading = false;
          messages.add(
            ChatMessage(
              text:
                  'Maaf, fitur pemrosesan gambar sedang dalam pengembangan.\n\nSilakan gunakan input teks untuk sementara.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        await _saveChatHistory();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: ${e.toString()}')),
        );
      }
    }
  }

  // Voice Input
  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition tidak tersedia di perangkat ini'),
          ),
        );
      }
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);

      try {
        await _speech.listen(
          onResult: (result) {
            setState(() {
              textController.text = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
              }
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          localeId: 'id_ID', // Indonesian language
          onSoundLevelChange: (level) => debugPrint('Sound level: $level'),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak dapat memulai pengenalan suara. Periksa izin mikrofon.',
              ),
            ),
          );
        }
      }
    }
  }

  void _showImageSourceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D3448) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Gambar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Gallery option (available for all platforms)
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              // Camera option (only for mobile platforms)
              if (!kIsWeb)
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  title: Text(
                    'Ambil Foto',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final input = textController.text.trim();
    if (input.isEmpty) return;

    final userMessage = ChatMessage(
      text: input,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(userMessage);
      isLoading = true;
    });

    textController.clear();
    await _saveChatHistory();

    try {
      final data = await context.read<TransactionCubit>().addChatTransaction(
        input,
      );
      if (!mounted) return;

      if (data != null) {
        final extracted = data.extractedData;
        setState(() {
          isLoading = false;
          if (extracted != null && extracted.amount != null) {
            final now = DateTime.now();
            final timeStr =
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

            String dateStr = '${now.day}/${now.month}/${now.year}';
            if (extracted.date != null) {
              final parts = extracted.date!.split('-');
              if (parts.length == 3) {
                dateStr = '${parts[2]}/${parts[1]}/${parts[0]}';
              }
            }

            final parsed = {
              'amount': extracted.amount!.toStringAsFixed(0),
              'category': extracted.categoryHint ?? 'Other',
              'description': extracted.description ?? '',
              'type': extracted.type ?? 'expense',
            };

            messages.add(
              ChatMessage(
                text:
                    '✅ Tersimpan!\n💰 Rp${parsed['amount']} | ${parsed['category']}\n📝 ${parsed['description']}\n⏰ $timeStr • $dateStr',
                isUser: false,
                timestamp: now,
                isParsed: true,
              ),
            );
            // Notify parent to refresh data
            widget.onTransactionSaved?.call();
          } else {
            messages.add(
              ChatMessage(
                text:
                    'Maaf, saya tidak menemukan nominal. Coba seperti ini:\n"Saya beli kopi 25000"',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          }
          _saveChatHistory();
        });
      } else {
        setState(() {
          isLoading = false;
          messages.add(
            ChatMessage(
              text:
                  'Maaf, terjadi kesalahan pada server atau data tidak valid.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _saveChatHistory();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        messages.add(
          ChatMessage(
            text:
                'Maaf, gagal terhubung ke server.\nPastikan server sudah berjalan.\nError: ${e.toString()}',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _saveChatHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1D3448)
            : context.colors.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '💬 Ceritakan transaksimu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : context.colors.secondary,
                  ),
                ),
                const Spacer(),
                if (messages.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Riwayat Chat?'),
                          content: const Text(
                            'Semua pesan chat akan dihapus. Lanjutkan?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _clearChatHistory();
                              },
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: isDark ? Colors.white70 : context.colors.secondary,
                    ),
                    tooltip: 'Hapus riwayat chat',
                  ),
              ],
            ),
          ),
          Divider(
            color: isDark
                ? const Color(0xFF2A4A62)
                : context.colors.outlineVariant.withOpacity(0.3),
          ),
          // Chat messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👋', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'Mulai dengan menceritakan transaksimu',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : context.colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contoh: "Saya beli kopi 25000"',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : context.colors.onSurfaceVariant.withOpacity(
                                    0.6,
                                  ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isLoading && index == messages.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      (isDark
                                              ? const Color(0xFF2C5F87)
                                              : context.colors.primaryContainer)
                                          .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      isDark
                                          ? Colors.white
                                          : const Color(0xFF2c5f87),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          // Input field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1A24) : null,
              border: isDark
                  ? Border(
                      top: BorderSide(color: const Color(0xFF2A4A62), width: 1),
                    )
                  : null,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _showImageSourceDialog,
                  icon: Icon(
                    Icons.image_outlined,
                    color: isDark ? Colors.white70 : context.colors.secondary,
                  ),
                  tooltip: kIsWeb ? 'Upload File Struk' : 'Upload Receipt',
                ),
                IconButton(
                  onPressed: kIsWeb
                      ? null // Disable untuk web
                      : _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening
                        ? Colors.red
                        : (kIsWeb
                              ? Colors
                                    .grey // Grey untuk disabled
                              : (isDark
                                    ? Colors.white70
                                    : context.colors.secondary)),
                  ),
                  tooltip: kIsWeb
                      ? 'Voice input tidak tersedia di web'
                      : 'Voice Input',
                ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(color: isDark ? Colors.white : null),
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Mendengarkan...'
                          : 'Cth: "Beli kopi 25000"',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A4A62)
                          : context.colors.surfaceContainer,
                      hintStyle: TextStyle(
                        color: _isListening
                            ? Colors.red.shade300
                            : (isDark
                                  ? Colors.white38
                                  : context.colors.onSurfaceVariant.withOpacity(
                                      0.5,
                                    )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C5F87)
                        : context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(
                      Icons.send,
                      color: isDark ? Colors.white : context.colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C5F87)
                      : context.colors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F1A24)
                    : context.colors.primaryContainer.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isDark ? Colors.white : context.colors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (message.isParsed) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2e7d32).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF2e7d32).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF2e7d32),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Tersimpan otomatis',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2e7d32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isParsed;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isParsed = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'isParsed': isParsed,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] as String,
    isUser: json['isUser'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isParsed: json['isParsed'] as bool? ?? false,
  );
}
