import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'page/bloc/state_bloc.dart';
import 'page/todoPage/todo_page.dart';

void main() {
  Bloc.observer = const AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ThemeCubit(),
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (_, theme) {
            return MaterialApp(
              title: 'Todos',
              theme: theme,
              // theme: ThemeData(
              //   primarySwatch: Colors.blue,
              //   visualDensity: VisualDensity.adaptivePlatformDensity,
              // ),
              debugShowCheckedModeBanner: false,
              home: const TodoListScreen(),
            );
          },
        ));
  }
}
