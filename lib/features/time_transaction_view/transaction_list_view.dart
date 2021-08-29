import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/time_transaction_view/widgets/base_state.dart';
import 'package:ourea/features/time_transaction_view/widgets/edit_state.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:ourea/services/navigation/router.dart';

class TransactionListView extends StatefulWidget {
  @override
  _TransactionListViewState createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView>
    with WidgetsBindingObserver {
  bool _editMode;

  _TransactionListViewState() {
    _editMode = false;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.resumed) {
      //forces a refresh after resume
      locator<OureaBloc>().add(ChangeEditStateTransactionEvent(_editMode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TimeStamps'),
        actions: [
          IconButton(
            icon: Icon(Icons.description),
            onPressed: () {
              Navigator.pushReplacementNamed(context, RouterPath.home);
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.pushReplacementNamed(context, RouterPath.tasks);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _editMode = !_editMode;
                locator<OureaBloc>()
                    .add(ChangeEditStateTransactionEvent(_editMode));
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<OureaBloc, OureaState>(
        bloc: locator<OureaBloc>(),
        builder: (BuildContext context, OureaState state) {
          Widget editStateSelect(bool edit, List<TimeTransaction> timeList) {

            print('editstateselect was called from TimeTransaction');
            if (timeList == null) {
              print('Transaction List is Empty');
              timeList = [];
            }
            timeList.sort((a, b) {
              return a.start.compareTo(b.start);
            });
            if (edit) {
              return editState(context, timeList);
            } else {
              return baseState(context, timeList);
            }
          }

          if (state is InitialOureaState) {
            locator<OureaBloc>().add(InitializeOureaBloc());
          }
          if (state is ChangeEditState) {
            return editStateSelect(_editMode, state.timeList);
          }
          if (state is UpdatingOureaState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is UpdatedOureaState) {
            return editStateSelect(_editMode, state.timeList);
          }
          if (state is ErrorState) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }
          print('Failed to capture State-');
          print(state.runtimeType);
          return Center(
            child: Text('Could not determine state'),
          );
        },
      ),
    );
  }
}
