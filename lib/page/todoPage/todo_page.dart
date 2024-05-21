import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';

import '../bloc/state_bloc.dart';
import 'constant.dart';
import 'todo_method.dart';
import 'todo_widget.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State createState() => _TodoListScreenState();
}

GlobalKey<AnimatedListState> _listKey = GlobalKey();

class _TodoListScreenState extends State<TodoListScreen> {
  late List<Todo> todos = [];
  late TextEditingController _textEditingController;
  late TextEditingController _textEditingController1;
  late SlidableController slidableController;
  @override
  void initState() {
    super.initState();
    fetchTodos();
    _textEditingController = TextEditingController();
    _textEditingController1 = TextEditingController();
    slidableController = SlidableController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _textEditingController1.dispose();
    super.dispose();
  }

// 获取，新增，完成，恢复，删除
  Future<void> fetchTodos() async {
    var request = http.Request('GET', Uri.parse('$baseURL/todos'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonString = await response.stream.bytesToString();
      setState(() {
        todos = parseTodos(jsonString);
        // 改变 key，触发列表的重新构建
        _listKey = GlobalKey();
      });
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<void> addTodo(String title) async {
    final response = await http.post(
      Uri.parse('$baseURL/todos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'title': title}),
    );
    if (response.statusCode == 200) {
      await fetchTodos();
    } else {
      throw Exception('Failed to add todo');
    }
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("新建事项"),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: "请输入...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                String title = _textEditingController.text.trim();
                if (title.isNotEmpty) {
                  addTodo(title);
                  _textEditingController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("添加"),
            ),
          ],
        );
      },
    );
  }

  Future<void> completeTodo(Todo todo) async {
    var request =
        http.Request('PUT', Uri.parse('$baseURL/todos/${todo.id}/completed'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> restoreTodo(Todo todo) async {
    var request =
        http.Request('PUT', Uri.parse('$baseURL/todos/${todo.id}/restore'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> deleteTodo(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:3000/todos/$id'));
    if (response.statusCode == 200) {
      fetchTodos();
    } else {
      throw Exception('Failed to delete todo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // 执行操作
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Row(
            children: [
              const SizedBox(width: 6.0),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.0),
                    color: const Color.fromARGB(255, 251, 236, 236),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _textEditingController1,
                    onSubmitted: (value) {
                      addTodo(value);
                      _textEditingController1.clear();
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      // hintText: '请输入今日任务',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              SizedBox(
                height: 40,
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.blue, // 按钮背景颜色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0), // 按钮圆角
                    ),
                    elevation: 3, // 按钮阴影
                  ),
                  onPressed: () {
                    addTodo(_textEditingController1.text.trim());
                    _textEditingController1.clear();
                  },
                  child: const Text(
                    '添加',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      // color: Colors.white, // 按钮文字颜色
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
            ],
          ),
          todos.isEmpty
              ? const Center(child: Text('No todos available'))
              // ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    key: _listKey, // 添加 key
                    // shrinkWrap: true, // 添加 shrinkWrap 属性

                    // physics:
                    // const NeverScrollableScrollPhysics(), // 禁用 ListView 的滚动
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          slidableController.activeState?.close();
                        },
                        child: Slidable(
                          actionPane: const SlidableDrawerActionPane(),
                          actionExtentRatio: 0.2,
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: '删除',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                // 删除当前 todo
                                deleteTodo(todos[index].id);
                              },
                            ),
                          ],
                          child: ListTile(
                            title: EditableTodo(
                              initialText: todos[index].title,
                              completed: todos[index].completed,
                              onChanged: (newText) {
                                setState(() {
                                  todos[index].title = newText;
                                });
                                Timer(const Duration(seconds: 1), () {
                                  updateTodoTitle(todos[index]);
                                });
                              },
                              onCheckboxChanged: (value) {
                                setState(() {
                                  todos[index].completed = value;
                                  if (value) {
                                    completeTodo(todos[index]);
                                  } else {
                                    restoreTodo(todos[index]);
                                  }
                                });
                              },
                            ),
                            // leading: Checkbox(
                            //   value: todos[index].completed,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       todos[index].completed = value!;
                            //       if (value) {
                            //         completeTodo(todos[index]);
                            //       } else {
                            //         restoreTodo(todos[index]);
                            //       }
                            //     });
                            //     print(value);
                            //   },
                            // ),
                          ),
                        ),
                      );
                    },
                  ),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加新的 todo
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
