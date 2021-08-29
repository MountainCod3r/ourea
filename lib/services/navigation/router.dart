import 'package:flutter/material.dart';
import 'package:ourea/features/project_list_view/project_list_view.dart';
import 'package:ourea/features/project_overview/project_overview.dart';
import 'package:ourea/features/task_list_view/task_list_view.dart';
import 'package:ourea/features/time_transaction_view/timeline_view.dart';
import 'package:ourea/features/time_transaction_view/transaction_list_view.dart';

class RouterPath {
  static const String home = '/';
  static const String login = '/login';
  static const String tasks = '/tasks';
  static const String transactions = '/transactions';
}

// Figure out a way to use TaskID as routerpath to facilitate navigation
class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterPath.home:
        return MaterialPageRoute(
          builder: (_) => ProjectListView(),
        );
      case RouterPath.login:
        return MaterialPageRoute(
          builder: (_) => Scaffold(),
        );
      case RouterPath.transactions:
        return MaterialPageRoute(
          builder: (_) => TransactionListView(),
        );

      default:
        return MaterialPageRoute(builder: (_) {
          List<String> parseString = settings.name.split('-');
          if (parseString[0] == 'project') {
            return ProjectOverview(parseString[1]);
          } else if (parseString[0] == 'projectTaskList') {
            return TaskListView(parseString[1]);
          } else if (parseString[0] == 'projectTimeList'){
            return TimeLineView(parseString[1]);
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text('No Route'),
              ),
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            );
          }
        });
    }
  }
}
