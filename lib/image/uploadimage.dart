import 'package:cloud_firestore/cloud_firestore.dart';

class Controller {
  Future uploadImage(id) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection("image");

    reference.doc(id).set({
      'id': id,
      'location': "Null",
      'name': "Empty",
      'description': "Empty",
    });
  }

  Future updateImageInfo(id, name, desc, location) async {
    var collection = FirebaseFirestore.instance.collection('image');
    collection.doc(id).update({
      'id': id,
      'name': name,
      'description': desc,
      'location': location
    });
  }

  
}
