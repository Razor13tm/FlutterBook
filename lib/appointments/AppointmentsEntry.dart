import "dart:async";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "../utils.dart" as utils;
import "AppointmentsDBWorker.dart";
import "AppointmentsModel.dart" show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry() {
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
  }

  Widget build(BuildContext inContext) {
    if (appointmentsModel.entityBeingEdited != null) {
      _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
      _descriptionEditingController.text =
          appointmentsModel.entityBeingEdited.description;
    }

    return ScopedModel(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(builder:
            (BuildContext inContext, Widget inChild,
                AppointmentsModel inModel) {
          return Scaffold(
              bottomNavigationBar: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Row(children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent.shade100),
                        child: Text("Cancel"),
                        onPressed: () {
                          FocusScope.of(inContext).requestFocus(FocusNode());

                          inModel.setStackIndex(0);
                        }),
                    Spacer(),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent.shade100),
                        child: Text("Save"),
                        onPressed: () {
                          _save(inContext, appointmentsModel);
                        })
                  ])),
              body: Form(
                  key: _formKey,
                  child: ListView(children: [
                    // Title.
                    ListTile(
                        leading: Icon(Icons.subject),
                        title: TextFormField(
                            decoration: InputDecoration(hintText: "Title"),
                            controller: _titleEditingController,
                            validator: (String inValue) {
                              if (inValue.length == 0) {
                                return "Please enter a title";
                              }
                              return null;
                            })),

                    ListTile(
                        leading: Icon(Icons.description),
                        title: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration:
                                InputDecoration(hintText: "Description"),
                            controller: _descriptionEditingController)),

                    ListTile(
                        leading: Icon(Icons.today),
                        title: Text("Date"),
                        subtitle: Text(appointmentsModel.chosenDate == null
                            ? ""
                            : appointmentsModel.chosenDate),
                        trailing: IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.deepOrangeAccent.shade100,
                            onPressed: () async {
                              String chosenDate = await utils.selectDate(
                                  inContext,
                                  appointmentsModel,
                                  appointmentsModel.entityBeingEdited.apptDate);
                              if (chosenDate != null) {
                                appointmentsModel.entityBeingEdited.apptDate =
                                    chosenDate;
                              }
                            })),

                    ListTile(
                        leading: Icon(Icons.alarm),
                        title: Text("Time"),
                        subtitle: Text(appointmentsModel.apptTime == null
                            ? ""
                            : appointmentsModel.apptTime),
                        trailing: IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.deepOrangeAccent.shade100,
                            onPressed: () => _selectTime(inContext)))
                  ])));
        }));
  }

  Future _selectTime(BuildContext inContext) async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (appointmentsModel.entityBeingEdited.apptTime != null) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");

      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    TimeOfDay picked =
        await showTimePicker(context: inContext, initialTime: initialTime);

    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime =
          "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(inContext));
    }
  }

  void _save(BuildContext inContext, AppointmentsModel inModel) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (inModel.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);

    inModel.setStackIndex(0);

    ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Appointment saved")));
  }
}
