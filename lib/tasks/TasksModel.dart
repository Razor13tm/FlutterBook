import "../BaseModel.dart";

class Task {
  int id;
  String description;
  String dueDate; // YYYY,MM,DD
  String completed = "false";

  String toString() {
    return "{ id=$id, description=$description, dueDate=$dueDate, completed=$completed }";
  }
}

class TasksModel extends BaseModel {}

TasksModel tasksModel = TasksModel();
