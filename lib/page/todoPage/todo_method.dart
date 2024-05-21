import 'dart:convert';
import 'package:http/http.dart' as http;

import 'constant.dart';

class Todo {
  final int id;
  late String title;
  bool completed;

  Todo({required this.id, required this.title, required this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] == 1,
    );
  }
}

// 接受两个 Todo 对象作为参数，根据 completed 属性和 id 进行比较
int compareTodos(Todo a, Todo b) {
  if (a.completed && !b.completed) {
    return 1;
  } else if (!a.completed && b.completed) {
    return -1;
  } else {
    return b.id.compareTo(a.id);
  }
}

// 格式化并进行排序
List<Todo> parseTodos(String jsonString) {
  List<dynamic> parsed = jsonDecode(jsonString);
  var tmp = parsed.map((json) => Todo.fromJson(json)).toList();
  tmp.sort(compareTodos);
  return tmp;
}

// 实现任务更新
Future<void> updateTodoTitle(Todo todo) async {
  final response = await http.put(
    Uri.parse('$baseURL/todos/${todo.id}/title'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'title': todo.title}),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to update todo title');
  }
}
