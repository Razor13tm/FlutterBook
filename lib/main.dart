import "dart:io";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "appointments/Appointments.dart";
import "contacts/Contacts.dart";
import "notes/Notes.dart";
import "tasks/Tasks.dart";
import "utils.dart" as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  init() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(FlutterBook());
  }
  init();
}

class FlutterBook extends StatelessWidget {
  Widget build(BuildContext inContext) {
    return MaterialApp(
        home: DefaultTabController(
            length: 4,
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.deepOrangeAccent.shade100,
                    title: Text("FlutterBook"),
                    bottom: TabBar(indicatorColor: Colors.black, tabs: [
                      Tab(icon: Icon(Icons.date_range), text: "Meetings"),
                      Tab(icon: Icon(Icons.contacts), text: "Contacts"),
                      Tab(icon: Icon(Icons.note), text: "Notes"),
                      Tab(icon: Icon(Icons.assignment_turned_in), text: "Tasks")
                    ])),
                body: TabBarView(children: [
                  Appointments(),
                  Contacts(),
                  Notes(),
                  Tasks()
                ]))));
  }
}
