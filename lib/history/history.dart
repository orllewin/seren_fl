import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seren_fl/db/drift_database.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryData> history = [];

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) getHistory();
    return Scaffold(
        appBar: AppBar(
          title: Text("History"),
        ),
        body: ListView.builder(
            itemCount: history.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, position) {
              var item = history[position];
              return InkWell(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8,12,8, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400)
                        ),
                        Text(item.address, style: const TextStyle(fontSize: 14))],
                    )),
                onTap: () {
                  //todo
                },
              );
            }));
  }

  Future getHistory() async {
    var dbHistory = await Provider.of<SerenDatabase>(context, listen: false).getHistory;

    if (dbHistory.isNotEmpty) {
      setState(() {
        history = dbHistory;
      });
    }
  }
}
