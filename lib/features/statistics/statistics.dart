import 'package:ourea/core/models/ourea_record.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

class OureaStatistics {
  List<OureaRecord> _data = [];
  List<Project> _projects = [];
  List<Task> _task = [];
  bool _isInitialized = false;

  OureaStatistics(
      {List<Project> projects, List<Task> tasks, List<TimeTransaction> time}) {
    if (!_isInitialized) {
      for (var transaction in time) {
        _data.add(OureaRecord(transaction));
      }
      _isInitialized = true;
    }
    _projects = projects;
    _task = tasks;
  }

  List<OureaRecord> getAllRecordsForProject(Project project) {
    return _data.where((element) => element.projectId == project.id).toList();
  }

  List<OureaRecord> getAllRecordsForTask(Task task) {
    return _data.where((element) => element.taskId == task.id).toList();
  }

  List<Task> getTaskListForProject(Project project) {
    return _task.where((element) => element.projectId == project.id).toList();
  }

  List<Project> getProjectList() => _projects;

  Duration taskDurationByDay(Task task, DateTime day) {
    List<OureaRecord> filteredList = _data
        .where((element) =>
            element.taskId == task.id &&
            element.start.day == day.day &&
            element.start.month == day.month &&
            element.start.year == day.year)
        .toList();
    Duration duration = Duration();
    for (var record in filteredList) {
      duration += record.duration;
    }
    return duration;
  }

  int completedTasksForProject(Project project) {
    List<Task> projectTaskList =
        locator<OureaBloc>().getProjectTaskList(project.id);
    return projectTaskList
        .where((element) => element.completed)
        .toList()
        .length;
  }

  Duration averageTimeForTask(Task task) {
    List<OureaRecord> filteredList = _data
        .where((element) =>
            element.taskId == task.id && element.duration.inSeconds > 5)
        .toList();
    if (filteredList.length < 1) {
      return Duration(seconds: 0);
    }
//    Duration sum = filteredList.reduce((value, element){
//      OureaRecord record = value;
//      if(element.duration.inSeconds > 1){
//        record.duration += element.duration;
//      }
//      return record;
//    }).duration;
    Duration sum = Duration();
    for (var record in filteredList) {
      sum += record.duration;
    }
    double average = sum.inSeconds / filteredList.length;
    filteredList = [];
    sum = Duration();
    return Duration(seconds: average.toInt());
  }

  Duration averageDailyTimePerProject(Project project) {
    List<OureaRecord> filteredList =
        _data.where((element) => element.projectId == project.id).toList();
    filteredList.sort((a, b) => a.start.compareTo(b.start));
    int currentDay = filteredList[0].start.day;
    Set<DateTime> days = {};
    int dayCount = 1;
    Duration total = Duration();
    for (var record in filteredList) {
      days.add(
          DateTime(record.start.year, record.start.month, record.start.day));
      total += record.duration;
    }
    double average = total.inSeconds / days.length;
    filteredList = [];
    return Duration(seconds: average.toInt());
  }

  Task getMostPopularTaskForProject(Project project) {
    List<Task> taskList = getProjectTaskList(project.id);
    Duration taskDuration = Duration();
    Task currentTask;
    for (var task in taskList) {
      Duration duration = locator<OureaBloc>().getEpochForTask(task.id);
      if (duration.compareTo(taskDuration) > 0) {
        taskDuration = duration;
        currentTask = task;
      }
    }
    return currentTask;
  }

  Duration getTimeSpentTodayOnProject(Project project) {
    DateTime today = DateTime.now();
    List<OureaRecord> filteredList = getAllRecordsForProject(project).where((element){
      return element.start.isAfter(DateTime(today.year, today.month, today.day));
    }).toList();
    Duration sum = Duration();
    for(var record in filteredList) {
      sum += record.duration;
    }
    return sum;
  }

  Duration getTimeSpentThisWeekOnProject(Project project) {
    DateTime today = DateTime.now();
    List<OureaRecord> filteredList = getAllRecordsForProject(project).where((element){
      return element.start.isAfter(DateTime(today.year, today.month, today.day).subtract(Duration(days: 7)));
    }).toList();
    Duration sum = Duration();
    for(var record in filteredList) {
      sum += record.duration;
    }
    return sum;
  }

  Duration getTimeSpentAllTimeOnProject(Project project) {
    List<OureaRecord> filteredList = getAllRecordsForProject(project);
    Duration sum = Duration();
    for(var record in filteredList) {
      sum += record.duration;
    }
    return sum;
  }

  List<Task> getProjectTaskList(String projectId) {
    List<Task> projectTaskList = [];
    for (var task in _task) {
      if (task.projectId == projectId) {
        projectTaskList.add(task);
      }
    }
    return projectTaskList;
  }
}
