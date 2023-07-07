import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lab8/camera/form.dart';
import 'package:lab8/image/uploadimage.dart';

class ImagePickerApp extends StatefulWidget {
  const ImagePickerApp({Key? key}) : super(key: key);

  @override
  State<ImagePickerApp> createState() => _ImagePickerAppState();
}

class _ImagePickerAppState extends State<ImagePickerApp> {
  List<XFile> images = [];

  FirebaseStorage storage = FirebaseStorage.instance;
  Controller control = Controller();

  List<String> imagePath = [];
  List<String> imageUrls = [];
  Map<String, dynamic> data = {};

  String filename = '';

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  void reloadState() {
    setState(() {
      fetchImageUrls();
    });
  }


  Future getMultiImages() async {
    final imageSelected = await ImagePicker().pickMultiImage();

    setState(() {
      if (imageSelected.isNotEmpty) {
        images.addAll(imageSelected);
        for (int i = 0; i < imageSelected.length; i++) {
          imagePath.add(imageSelected[i].path);
        }
      }
      uploadImages();
    });

    Navigator.pop(context);
  }

  Future getImages() async {
    final pickImage = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickImage != null) {
        images.add(pickImage);
        imagePath.add(pickImage.path);
      }
      uploadImages();
    });
    Navigator.pop(context);
  }

  fetchImageUrls() async {
    final ListResult result =
        await FirebaseStorage.instance.ref().child('photos').listAll();

    final List<Reference> allFiles = result.items;

    for (final Reference reference in allFiles) {
      final String downloadUrl = await reference.getDownloadURL();
      setState(() {
        imageUrls.add(downloadUrl);
      });
    }
  }

  uploadImages() async {
    for (int i = 0; i < imagePath.length; i++) {
      filename = imagePath[i].split('/').last;
      final ref =
          FirebaseStorage.instance.ref().child('photos').child(filename);
      var file = File(imagePath[i]);
      await ref.putFile(file);
      control.uploadImage(filename);
    }
    setState(() {
      imagePath.clear();
    });
  }

  final textInputDecoration = const InputDecoration(
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink, width: 2.0)));

  @override
  Widget build(BuildContext context) {
    void popUp() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 200,
              width: 200,
              child: Center(
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: getImages, child: const Text("From camera")),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: getMultiImages,
                        child: const Text("From gallery")),
                  ],
                ),
              ),
            );
          });
    }


    void formPopUp(id, name, desc, location) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: SettingsForm(id: id, name: name, description: desc, location: location,)),
            );
          });
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Pick an image"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: reloadState,
            ),
          ],
        ),
        body: Center(
            child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('image').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("No images");
                  } else {
                    final List<DocumentSnapshot> document = snapshot.data!.docs;
                    return Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 4.0,
                                        mainAxisSpacing: 4.0),
                                itemCount: document.length,
                                itemBuilder: (context, index) {
                                  final DocumentSnapshot doc = document[index];
                                  if (index < imageUrls.length) {
                                    return GestureDetector(
                                      onTap: () {
                                        formPopUp(doc['id'], doc['name'],
                                            doc['description'], doc['location']);
                                      },
                                      child: Image.network(imageUrls[index]),
                                    );
                                  }
                                })));
                  }
                }),
            ElevatedButton(onPressed: popUp, child: const Text("Choose Image")),
            const SizedBox(height: 10),
          ],
        )));
  }
}
