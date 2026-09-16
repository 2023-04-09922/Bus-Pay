import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinBoxes extends StatefulWidget {
  const PinBoxes({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.autofocus = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final bool autofocus;

  @override
  State<PinBoxes> createState() => _PinBoxesState();
}

class _PinBoxesState extends State<PinBoxes> {
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openKeyboard());
    }
  }

  void _openKeyboard() {
    if (!mounted) return;
    _focus.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  void didUpdateWidget(covariant PinBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
    if (oldWidget.value.isNotEmpty && widget.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openKeyboard());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < widget.value.length;
                  final current = i == widget.value.length && _focus.hasFocus;
                  return Container(
                    width: 56,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: current ? 2.4 : 1.4,
                        color: current
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      filled ? '●' : '',
                      style: const TextStyle(fontSize: 22),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  onTap: _openKeyboard,
                  onChanged: (value) => widget.onChanged(value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
