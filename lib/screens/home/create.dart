import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Space/services/auth.dart';

class CreateActivity extends StatefulWidget {
  @override
  _CreateActivityState createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivity> {
  DateTime pickedDate;
  TimeOfDay time = TimeOfDay.now();
  int capacity = 5;
  String type = 'public';

  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    capacity = 5;
    time = TimeOfDay.now();
    type = 'public';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Panel"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
            child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Enter Activity Name'),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                  "Select date: ${pickedDate.year}, ${pickedDate.month}, ${pickedDate.day}"),
              onTap: _pickDate,
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text("Time: ${time.hour}:${time.minute}"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickTime,
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: false,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Capacity: $capacity',
              ),
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                capacity = int.parse(value);
                print(capacity);
                print(value);
              },
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text("Click to select location"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: null,
            ),
            SizedBox(height: 20),
            DropdownButton(
              value: type,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 20,
              style: TextStyle(fontSize: 20, color: Colors.lightBlue),
              underline: Container(
                height: 2,
                color: Colors.blue[200],
              ),
              items: <String>[
                'public',
                'private',
                'all_friends',
                'specific_friends'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  type = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            FlatButton.icon(
                onPressed: uploadActivity,
                icon: Icon(Icons.update),
                label: Text("Add"))
          ],
        )),
      ),
    );
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: pickedDate,
    );
    if (date != null)
      setState(() {
        pickedDate = date;
      });
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: time);
    if (t != null)
      setState(() {
        time = t;
      });
  }

  // _piclLocation() async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PlacePicker(
  //         apiKey: APIKeys.apiKey,   // Put YOUR OWN KEY here.
  //         onPlacePicked: (result) {
  //           print(result.address);
  //           Navigator.of(context).pop();
  //         },
  //         initialPosition: HomePage.kInitialPosition,
  //         useCurrentLocation: true,
  //       ),
  //     ),
  //   );
  // }

  void uploadActivity() async {
    Firestore firestore = Firestore.instance;
    String userId = await AuthService().userId;
    DateTime finalDate = new DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, time.hour, time.minute);
    firestore.collection("Activities").document(userId).setData({
      'title': titleController.text,
      'start_time': finalDate.toString(),
      'end_time': DateTime.now().toIso8601String(),
      'capacity': capacity,
      'authority': type,
    });
    Navigator.pop(context);
  }
}
