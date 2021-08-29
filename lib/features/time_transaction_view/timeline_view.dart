import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/statistics/statistics.dart';
import 'package:ourea/features/time_transaction_view/widgets/time_list_view.dart';
import 'package:ourea/services/locator/locator.dart';

class TimeLineView extends StatelessWidget {
  final String projectId;

  TimeLineView(this.projectId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Timeline'),
      ),
      body: BlocBuilder<OureaBloc, OureaState>(
        bloc: locator<OureaBloc>(),
        builder: (context, state) {
          if(state is UpdatedOureaState) {
            OureaStatistics stats = OureaStatistics(projects: state.projectList, tasks: state.taskList, time: state.timeList);
            return TimeListView(context, stats.getAllRecordsForProject(locator<OureaBloc>().getProjectById(projectId)));
          }
          return TimeListView(context, []);
        }
      ),
    );
  }
}
