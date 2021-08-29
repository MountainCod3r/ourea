import 'package:flutter/material.dart';
import 'package:ourea/core/models/time_transaction.dart';

Widget editState(BuildContext context, List<TimeTransaction> data) {
  print('Length of data is ${data.length}');

  return ListView.builder(
      itemCount: data.length == null ? 0 : data.length,
      itemBuilder: (context, index) {
        return ListTile(
          dense: true,
          title: Text(data[index].start.toString()),
          trailing: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    //TODO: implement task dialog
                  },
                ),
              ],
            ),
          ),
        );
      });
}
