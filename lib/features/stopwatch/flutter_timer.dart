import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/project_list_view/project/project_bloc.dart';
import 'package:ourea/features/stopwatch/stopwatch_model.dart';
import 'package:ourea/services/locator/locator.dart';

class FlutterTimer extends StatefulWidget {
  final String taskId;

  FlutterTimer(this.taskId, {Key key}) : super(key: key);

  @override
  _FlutterTimerState createState() => _FlutterTimerState(taskId);
}

class _FlutterTimerState extends State<FlutterTimer>
    with WidgetsBindingObserver {
  StopwatchModel _clock;
  String _taskId;

  _FlutterTimerState(String taskId) {
    _taskId = taskId;
    _clock = StopwatchModel(taskId);
  }

  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //forces a refresh after resume
      _clock.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OureaBloc, OureaState>(
      bloc: locator<OureaBloc>(),
      builder: (context, state) {
        if (state is UpdatedOureaState) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder(
                stream: _clock.hours,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 0) {
                    return Text('  ');
                  } else {
                    if (snapshot.data < 10) {
                      return Text('0${snapshot.data}:');
                    } else {
                      return Text('${snapshot.data}:');
                    }
                  }
                },
              ),
              StreamBuilder(
                stream: _clock.minutes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('00:');
                  } else {
                    if (snapshot.data < 10) {
                      return Text('0${snapshot.data}:');
                    } else {
                      return Text('${snapshot.data}:');
                    }
                  }
                },
              ),
              StreamBuilder(
                stream: _clock.seconds,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('00');
                  } else {
                    if (snapshot.data < 10) {
                      return Text('0${snapshot.data}');
                    } else {
                      return Text('${snapshot.data}');
                    }
                  }
                },
              ),
              SizedBox(
                width: 10.0,
              ),
              IconButton(
                icon:
                    _clock.isActive ? Icon(Icons.stop) : Icon(Icons.play_arrow),
                color: _clock.isActive ? Colors.red : Colors.green,
                onPressed: () {
                  if (_clock.isActive) {
                    setState(() {
                      _clock.stop();
                    });
                  } else {
                    setState(() {
                      _clock.start();
                    });
                  }
                },
              ),
              SizedBox(
                width: 10.0,
              ),
            ],
          );
        } else {
          return Text('00:00:00');
        }
      },
    );
  }
}
