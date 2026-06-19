import 'package:flutter/material.dart';

/// Debug overlay yang menampilkan informasi transaksi untuk debugging
/// Bisa di-toggle dengan menekan floating button
class DebugInfoOverlay extends StatefulWidget {
  final Widget child;

  const DebugInfoOverlay({required this.child, super.key});

  @override
  State<DebugInfoOverlay> createState() => DebugInfoOverlayState();
}

class DebugInfoOverlayState extends State<DebugInfoOverlay> {
  static final List<String> _logs = [];
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Add initialization log to confirm debug system is working
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addLog('🐛 Debug Console Initialized');
      addLog('📱 App Started - Ready to track transactions');
      debugPrint(
        '🟢 DEBUG CONSOLE INITIALIZED - Check bottom-right for bug button!',
      );
    });
  }

  static void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _logs.add('$timestamp - $message');
    if (_logs.length > 150) {
      _logs.removeAt(0); // Keep only last 150 logs
    }
  }

  static void clearLogs() {
    _logs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,

          // Debug Logs Overlay
          if (_isVisible)
            Positioned.fill(
              bottom: 80,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 400,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bug_report,
                              size: 24,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Debug Console',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${_logs.length} logs',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Clear button — no tooltip to avoid Overlay dependency
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  clearLogs();
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.delete_sweep,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            // Close button — no tooltip to avoid Overlay dependency
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isVisible = false;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Logs List
                      Expanded(
                        child: _logs.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    '🔍 No logs yet...\n\n'
                                    'Try adding a transaction to see debug info.\n\n'
                                    'Logs will show here automatically.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                reverse: true, // Show latest first
                                padding: const EdgeInsets.all(12),
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[_logs.length - 1 - index];
                                  Color textColor = Colors.white;

                                  if (log.contains('⚠️')) {
                                    textColor = Colors.orangeAccent;
                                  } else if (log.contains('✅')) {
                                    textColor = Colors.lightGreenAccent;
                                  } else if (log.contains('💾')) {
                                    textColor = Colors.cyanAccent;
                                  } else if (log.contains('💰')) {
                                    textColor = Colors.yellowAccent;
                                  } else if (log.contains('📈')) {
                                    textColor = Colors.purpleAccent;
                                  } else if (log.contains('📊')) {
                                    textColor = Colors.blueAccent;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: textColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: SelectableText(
                                      log,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12,
                                        fontFamily: 'Courier',
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Debug Toggle Button - More prominent
          Positioned(
            bottom: 20,
            right: 20,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              shadowColor: Colors.yellow,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: _isVisible
                      ? const LinearGradient(
                          colors: [Colors.yellow, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF424242), Color(0xFF212121)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isVisible ? Colors.yellow : Colors.white24,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isVisible ? Colors.yellow : Colors.grey)
                          .withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: _isVisible ? Colors.black : Colors.white,
                        size: 36,
                      ),
                      if (_logs.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_logs.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function untuk log dari mana saja
void debugLog(String message) {
  debugPrint(message); // Still print to console
  DebugInfoOverlayState.addLog(message);
}
