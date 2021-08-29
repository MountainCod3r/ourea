import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String footer;
  final String stat;

  StatCard(this.stat, this.footer);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Card(
        child: GridTile(
          footer: Center(child: Column(
            children: [
              Text(footer),
              SizedBox(height: 10.0,),
            ],
          )),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20.0,),
                Text(
                  stat,
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
