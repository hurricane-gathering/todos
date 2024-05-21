import 'package:flutter/material.dart';

class EditableTodo extends StatefulWidget {
  final String initialText;
  final bool completed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onCheckboxChanged;

  const EditableTodo(
      {Key? key,
      required this.initialText,
      required this.completed,
      this.onChanged,
      this.onCheckboxChanged})
      : super(key: key);

  @override
  State createState() => _EditableTodoState();
}

class _EditableTodoState extends State<EditableTodo> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.completed,
          onChanged: (value) {
            widget.onCheckboxChanged!(value!);
          },
          shape: const CircleBorder(), // 将复选框的形状设置为圆形
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            decoration: const InputDecoration(
              hintText: "待办事项",
              border: InputBorder.none,
              isDense: true,
            ),
            style: TextStyle(
              color: widget.completed ? Colors.grey : Colors.black,
              decoration: widget.completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
