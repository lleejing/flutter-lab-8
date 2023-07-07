import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lab8/image/uploadimage.dart';

class SettingsForm extends StatefulWidget {
  final String name;
  final String description;
  final String id;
  final String location;

  SettingsForm(
      {required this.id,
      required this.name,
      required this.description,
      required this.location});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  String name = '';
  String desc = '';

  late TextEditingController nameController;
  late TextEditingController descController;

  String _locationMessage = "";
  late LocationPermission permission;
  late Position position;

  void _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
    setState(() {
      _locationMessage = "${position.latitude}, ${position.longitude}";
    });
  }

  @override
  void initState() {
    super.initState();
    name = widget.name;
    desc = widget.description;
    _locationMessage = widget.location;
    nameController = TextEditingController(text: name);
    descController = TextEditingController(text: desc);
  }

  Controller control = Controller();

  final textInputDecoration = const InputDecoration(
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink, width: 2.0)));

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text("Update your photo information",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: textInputDecoration.copyWith(hintText: "Name"),
                ),
                TextFormField(
                  controller: descController,
                  decoration:
                      textInputDecoration.copyWith(hintText: "Description"),
                ),
                const SizedBox(height: 20),
                Text("Location: $_locationMessage"),
                ElevatedButton(
                    onPressed: () {
                      _getCurrentLocation();
                    },
                    child: const Text("Add location")),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      control.updateImageInfo(widget.id, nameController.text,
                          descController.text, _locationMessage);
                      Navigator.pop(context);
                    },
                    child: const Text("Update"))
              ],
            )));
  }
}
