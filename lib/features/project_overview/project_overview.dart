import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/project_overview/project_overview/project_overview_bloc.dart';
import 'package:ourea/features/project_overview/widgets/stat_card.dart';
import 'package:ourea/features/statistics/charts/chart_types.dart';
import 'package:ourea/services/locator/locator.dart';

class ProjectOverview extends StatefulWidget {
  final String projectId;

  ProjectOverview(this.projectId);

  @override
  _ProjectOverviewState createState() =>
      _ProjectOverviewState(locator<OureaBloc>().getProjectById(projectId));
}

class _ProjectOverviewState extends State<ProjectOverview> {
  final Project project;
  String _chartSelection = ChartType.daily;
  DateTime _selectedDay;
  ProjectOverviewBloc _bloc;

  _ProjectOverviewState(this.project) {
    _selectedDay = DateTime.now();
    _bloc = ProjectOverviewBloc(project);
    _bloc.add(InitializeProjectOverviewEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: BlocBuilder<ProjectOverviewBloc, ProjectOverviewState>(
          bloc: _bloc,
          builder: (context, state) {
            if (state is UpdatedProjectOverviewState) {
              StatCard _statCardSelect() {
                String stat;
                DateTime today = DateTime.now();
                if(_chartSelection == ChartType.daily) {
                  return StatCard(state.stats.getTimeSpentTodayOnProject(project).toString().split('.')[0], 'Time Spent Today');
                }
                if(_chartSelection == ChartType.weekly) {
                  return StatCard(state.stats.getTimeSpentThisWeekOnProject(project).toString().split('.')[0], 'Time Spent this Week');
                }
                if(_chartSelection == ChartType.monthly) {
                  return StatCard(state.stats.getTimeSpentAllTimeOnProject(project).toString().split('.')[0], 'Time Spent All Time');
                }
                return StatCard('nothing', 'nothing to see here');
              }
              return Column(
                children: [
                  CalendarTimeline(
                    locale: 'en_ISO',
                    initialDate: _selectedDay,
                    firstDate: DateTime(2020, 1, 15),
                    lastDate: DateTime(DateTime.now().year + 1, 1, 15),
                    onDateSelected: (date) {
                      setState(() {
                        print(_selectedDay.toString());
                        _selectedDay = date;
                        _bloc
                            .add(DateChangedProjectOverviewEvent(_selectedDay));
                      });
                    },
                    leftMargin: 20,
                    monthColor: Colors.blueGrey,
                    dayColor: Colors.teal[200],
                    activeDayColor: Colors.white,
                    activeBackgroundDayColor: Colors.redAccent[100],
                    dotsColor: Color(0xFF333A47),
                    selectableDayPredicate: (date) {
                      if (locator<OureaBloc>()
                          .dateHasDataForProject(date, project)) {
                        return true;
                      }
                      var now = DateTime.now();
                      if (date.day == now.day &&
                          date.month == now.month &&
                          date.year == now.year) {
                        return true;
                      }
                      return false;
                    },
                  ),
                  Container(
                    margin: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      border: Border.all(
                        color: Colors.blueGrey,
                        width: 3,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * .4,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RawMaterialButton(
                                elevation: 0.0,
                                child: Text('day'),
                                onPressed: () {
                                  setState(() {
                                    _chartSelection = ChartType.daily;
                                    _bloc.add(
                                        ChartTypeChangedProjectOverviewEvent(
                                            ChartType.daily));
                                  });
                                },
                                constraints: BoxConstraints.tightFor(
                                  width: 35.0,
                                  height: 35.0,
                                ),
                                shape: CircleBorder(),
                                fillColor: _chartSelection == ChartType.daily
                                    ? Colors.teal
                                    : Colors.blueGrey[700],
                              ),
                              RawMaterialButton(
                                elevation: 0.0,
                                child: Text('wk'),
                                onPressed: () {
                                  setState(() {
                                    _chartSelection = ChartType.weekly;
                                    _bloc.add(
                                        ChartTypeChangedProjectOverviewEvent(
                                            ChartType.weekly));
                                  });
                                },
                                constraints: BoxConstraints.tightFor(
                                  width: 35.0,
                                  height: 35.0,
                                ),
                                shape: CircleBorder(),
                                fillColor: _chartSelection == ChartType.weekly
                                    ? Colors.teal
                                    : Colors.blueGrey[700],
                              ),
                              RawMaterialButton(
                                elevation: 0.0,
                                child: Text('mon'),
                                onPressed: () {
                                  setState(() {
                                    _chartSelection = ChartType.monthly;
                                    _bloc.add(
                                        ChartTypeChangedProjectOverviewEvent(
                                            ChartType.monthly));
                                  });
                                },
                                constraints: BoxConstraints.tightFor(
                                  width: 35.0,
                                  height: 35.0,
                                ),
                                shape: CircleBorder(),
                                fillColor: _chartSelection == ChartType.monthly
                                    ? Colors.teal
                                    : Colors.blueGrey[700],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Flexible(
                            child: Container(
                              color: Colors.black12,
                              child: state.chart,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.all(15.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueGrey,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.6,
                        padding: EdgeInsets.all(15.0),
                        children: [
                          StatCard(state.stats.averageDailyTimePerProject(project).toString().split('.')[0], 'AverageTimeSpent'),
                          StatCard(state.stats.completedTasksForProject(project).toString(), 'Tasks Completed'),
                          StatCard(state.stats.getMostPopularTaskForProject(project).name, 'Most Time Spent on'),
                          _statCardSelect(),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, 'projectTaskList-${project.id}');
                              },
                              child: Card(
                                child: GridTile(
                                  footer: Center(child: Column(
                                    children: [
                                      Text('View List',),
                                      SizedBox(height: 10.0,),
                                    ],
                                  )),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 20.0,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              'Task List',
                                              style: TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                            Icon(Icons.list),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, 'projectTimeList-${project.id}');
                              },
                              child: Card(
                                child: GridTile(
                                  footer: Center(child: Column(
                                    children: [
                                      Text('View List',),
                                      SizedBox(height: 10.0,),
                                    ],
                                  )),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 20.0,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              'TimeList',
                                              style: TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                            Icon(Icons.list),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }
}


