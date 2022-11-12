import "../BaseModel.dart";

class Contact {
  int id;
  String name;
  String phone;
  String email;
  String birthday; // YYYY,MM,DD

  String toString() {
    return "{ id=$id, name=$name, phone=$phone, email=$email, birthday=$birthday }";
  }
}

class ContactsModel extends BaseModel {
  void triggerRebuild() {
    notifyListeners();
  }
}

ContactsModel contactsModel = ContactsModel();
