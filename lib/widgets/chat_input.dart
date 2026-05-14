import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInput extends StatefulWidget {
  final void Function(String text) onSend;
  final bool enabled;

  const ChatInput({super.key, required this.onSend, this.enabled = true});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Focus(
                onKeyEvent: (_, event) {
                  if (event is! KeyDownEvent ||
                      event.logicalKey != LogicalKeyboardKey.enter) {
                    return KeyEventResult.ignored;
                  }
                  final hw = HardwareKeyboard.instance;
                  if (hw.isShiftPressed || hw.isControlPressed) {
                    final sel = _controller.selection;
                    final text = _controller.text;
                    final newText =
                        text.replaceRange(sel.start, sel.end, '\n');
                    _controller.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(
                          offset: sel.start + 1),
                    );
                    return KeyEventResult.handled;
                  }
                  _send();
                  return KeyEventResult.handled;
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  enabled: widget.enabled,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.multiline,
                  onSubmitted: (_) => _send(),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle:
                        TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilledButton(
                onPressed: (_hasText && widget.enabled) ? _send : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(38, 38),
                  maximumSize: const Size(38, 38),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: const Icon(Icons.arrow_upward_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
