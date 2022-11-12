import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:scoped_model/scoped_model.dart";
import "package:intl/intl.dart";
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart";
import "package:flutter_calendar_carousel/classes/event.dart";
import "package:flutter_calendar_carousel/classes/event_list.dart";
import "AppointmentsDBWorker.dart";
import "AppointmentsModel.dart"
    show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  Widget build(BuildContext inContext) {
    EventList<Event> _markedDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      _markedDateMap.add(
          apptDate,
          Event(
              date: apptDate,
              icon: Container(decoration: BoxDecoration(color: Colors.orangeAccent.shade100))));
    }

    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
            builder: (inContext, inChild, inModel) {
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.deepOrangeAccent.shade100,
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    appointmentsModel.entityBeingEdited = Appointment();
                    DateTime now = DateTime.now();
                    appointmentsModel.entityBeingEdited.apptDate =
                        "${now.year},${now.month},${now.day}";
                    appointmentsModel.setChosenDate(
                        DateFormat.yMMMMd("en_US").format(now.toLocal()));
                    appointmentsModel.setApptTime(null);
                    appointmentsModel.setStackIndex(1);
                  }),
              body: Column(children: [
                Expanded(
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: CalendarCarousel<Event>(
                          headerTextStyle: TextStyle(color: Colors.deepOrangeAccent.shade100),
                          iconColor: Colors.deepOrangeAccent.shade100,
                            thisMonthDayBorderColor: Colors.grey,
                            daysHaveCircularBorder: false,
                            markedDatesMap: _markedDateMap,
                            onDayPressed:
                                (DateTime inDate, List<Event> inEvents) {
                              _showAppointments(inDate, inContext);
                            })))
              ]));
        }));
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    showModalBottomSheet(
        context: inContext,
        builder: (BuildContext inContext) {
          return ScopedModel<AppointmentsModel>(
              model: appointmentsModel,
              child: ScopedModelDescendant<AppointmentsModel>(builder:
                  (BuildContext inContext, Widget inChild,
                      AppointmentsModel inModel) {
                return Scaffold(
                    body: Container(
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: GestureDetector(
                                child: Column(children: [
                              Text(
                                  DateFormat.yMMMMd("en_US")
                                      .format(inDate.toLocal()),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(inContext).accentColor,
                                      fontSize: 24)),
                              Divider(),
                              Expanded(
                                  child: ListView.builder(
                                      itemCount:
                                          appointmentsModel.entityList.length,
                                      itemBuilder: (BuildContext inBuildContext,
                                          int inIndex) {
                                        Appointment appointment =
                                            appointmentsModel
                                                .entityList[inIndex];

                                        if (appointment.apptDate !=
                                            "${inDate.year},${inDate.month},${inDate.day}") {
                                          return Container(height: 0);
                                        }

                                        String apptTime = "";
                                        if (appointment.apptTime != null) {
                                          List timeParts =
                                              appointment.apptTime.split(",");
                                          TimeOfDay at = TimeOfDay(
                                              hour: int.parse(timeParts[0]),
                                              minute: int.parse(timeParts[1]));
                                          apptTime =
                                              " (${at.format(inContext)})";
                                        }

                                        return Slidable(
                                          endActionPane: ActionPane(
                                              motion: const DrawerMotion(),
                                              children: [
                                                SlidableAction(
                                                    label: "Delete",
                                                    backgroundColor: Colors.red,
                                                    icon: Icons.delete,
                                                    onPressed: (context) =>
                                                        _deleteAppointment(
                                                            inBuildContext,
                                                            appointment))
                                              ]),
                                          child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 8),
                                              color: Colors.grey.shade300,
                                              child: ListTile(
                                                  title: Text(
                                                      "${appointment.title}$apptTime"),
                                                  subtitle: appointment
                                                              .description ==
                                                          null
                                                      ? null
                                                      : Text(
                                                          "${appointment.description}"),
                                                  onTap: () async {
                                                    _editAppointment(
                                                        inContext, appointment);
                                                  })),
                                        );
                                      }))
                            ])))));
              }));
        });
  }

  void _editAppointment(
      BuildContext inContext, Appointment inAppointment) async {
    appointmentsModel.entityBeingEdited =
        await AppointmentsDBWorker.db.get(inAppointment.id);

    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate(null);
    } else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      appointmentsModel
          .setChosenDate(DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));
    }
    if (appointmentsModel.entityBeingEdited.apptTime == null) {
      appointmentsModel.setApptTime(null);
    } else {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      TimeOfDay apptTime = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      appointmentsModel.setApptTime(apptTime.format(inContext));
    }
    appointmentsModel.setStackIndex(1);
    Navigator.pop(inContext);
  }

  Future _deleteAppointment(
      BuildContext inContext, Appointment inAppointment) async {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
              title: Text("Delete Appointment"),
              content: Text(
                  "Are you sure you want to delete ${inAppointment.title}?"),
              actions: [
                ElevatedButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(inAlertContext).pop();
                    }),
                ElevatedButton(
                    child: Text("Delete"),
                    onPressed: () async {
                      await AppointmentsDBWorker.db.delete(inAppointment.id);
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Appointment deleted")));

                      appointmentsModel.loadData(
                          "appointments", AppointmentsDBWorker.db);
                    })
              ]);
        });
  }
}
