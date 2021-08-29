import 'package:flutter/material.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:timeline_tile/timeline_tile.dart';

Widget baseState(BuildContext context, List<TimeTransaction> timeList) {
  print('Base State was called');
  return ListView.builder(
    itemCount: timeList.length == null ? 0 : timeList.length,
    itemBuilder: (context, index) {
      List<String> weekdays = [
        'mon',
        'tues',
        'wed',
        'thurs',
        'fri',
        'sat',
        'sun'
      ];
      TimeTransaction transaction = timeList[index];
      Task task = locator<OureaBloc>().getTaskById(transaction.taskId);
      bool first = false;
      bool last = false;
      bool indicator = false;
      IndicatorStyle indicatorStyle;

      if (index == 0) {
        first = true;
        indicator = true;
      }
      if (index == timeList.length - 1) {
        last = true;
        indicator = true;
      }

      if (index != 0) {
        if (timeList[index - 1].start.day != timeList[index].start.day) {
          indicator = true;
        }
      }

      if (indicator) {
        indicatorStyle = IndicatorStyle(
          width: 40.0,
          height: 40.0,
          padding: EdgeInsets.all(5.0),
          indicator: CircleAvatar(
            child: Text('${weekdays[timeList[index].start.weekday - 1]}'),
          ),
        );
      } else {
        indicatorStyle = IndicatorStyle(width: 10.0);
      }

      return ListTileTheme(
        dense: true,
        child: TimelineTile(
          topLineStyle: LineStyle(
            color: Colors.deepPurple,
            width: 5.0,
          ),
          isFirst: first,
          isLast: last,
          hasIndicator: indicator,
          indicatorStyle: indicatorStyle,
          rightChild: ListTile(
            title: Text('${transaction.start.toString()} - ${transaction.stop
                .toString()}'),
            subtitle: Text(
                'id: ${transaction.id ?? 'None'} task: ${task.name}'),
            onTap: () {
              print(task);
            },
          ),
        ),
      );
    },
  );
}
