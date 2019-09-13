import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ubcfpv3/screen/place_location.dart';
import 'package:http/http.dart' as http;
import 'package:ubcfpv3/screen/posts.dart';
import 'dart:convert';

import 'package:ubcfpv3/screen/search_place.dart';

class AddproScreen extends StatefulWidget {
  final Posts edit;

  const AddproScreen({Key key, this.edit}) : super(key: key);

  State<StatefulWidget> createState() {
    return _AddproScreenStatr();
  }
}

class _AddproScreenStatr extends State<AddproScreen> {
  File sampleImage;
  File sampleLogo;
  String _myValue;
  String _myName;
  String prourl;
  String myLongDec;
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final List<PlaceLocation> placeLocation = [];
  PlaceLocation placeLocationSelected;

  var location = Location();

  Future getImage({bool isLogo = false}) async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (isLogo) {
        sampleLogo = tempImage;
      } else {
        sampleImage = tempImage;
      }
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void uploadStatusImage() async {
    if (validateAndSave()) {
      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("(Post Images");

      var timeKey = DateTime.now();

      final StorageUploadTask uploadTaskImage =
          postImageRef.child(timeKey.toString() + "image.jpg").putFile(sampleImage);
      final StorageUploadTask uploadTaskLogo =
          postImageRef.child(timeKey.toString() + "logo.jpg").putFile(sampleLogo);

      var imageUrl =
          await (await uploadTaskImage.onComplete).ref.getDownloadURL();
      var logoUrl =
          await (await uploadTaskLogo.onComplete).ref.getDownloadURL();

      prourl = imageUrl.toString();

      print("Image Url = " + prourl);

      goToHomeScreen();
      saveToDatabase(url: prourl, logo: logoUrl);
    }
  }

  void saveToDatabase({String url, String logo}) {
    var dbTimeKey = DateTime.now();
    var formatData = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');

    String date = formatData.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();

    /// เช็คว่าเป็นการแก้ไขข้อมูลหรือไม่
    if (widget.edit == null) {
      var data = {
        "image": url,
        "logo": logo,
        "description": _myValue,
        "loneDescription": myLongDec,
        "shopname": _myName,
        "date": date,
        "time": time,
        "lat": placeLocationSelected.lat,
        "lng": placeLocationSelected.lng,
        "locationName": placeLocationSelected.name,
      };
      ref.child("Posts").push().set(data);
    } else {
      var data = {
        "image": url,
        "logo": logo,
        "description": _myValue,
        "loneDescription": myLongDec,
        "shopname": _myName,
        "date": date,
        "time": time,
        "lat": placeLocationSelected == null
            ? widget.edit.lat
            : placeLocationSelected.lat,
        "lng": placeLocationSelected == null
            ? widget.edit.lng
            : placeLocationSelected.lng,
        "locationName": placeLocationSelected == null
            ? widget.edit.locationName
            : placeLocationSelected.name,
      };
      ref.child("Posts").child(widget.edit.key).set(data);
    }
  }

  void goToHomeScreen() async {
    Navigator.pop(context);
  }

  @override
  void initState() {

    loadPlaceLocation();
    /// เช็คว่าเป็นการแก้ไขหรือไม่
    /// ถ้าใช่ ก็โหลดรูปจาก Firebase ไปใส่ในตัวแปร
    if (widget.edit != null) {
      loadImageToFile(widget.edit.image).then((f) {
        sampleImage = f;
        setState(() {});
      });
      loadImageToFile(widget.edit.logo).then((f) {
        sampleLogo = f;
        setState(() {});
      });
    }
    super.initState();
  }

  /// ดึงสถานที่ใกล้ฉัน
  void loadPlaceLocation() async {
    try {
      LocationData locationData = await location.getLocation();

      http.Response response = await http.get(
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${locationData.latitude},${locationData.longitude}&radius=15000&keyword=cruise&language=th&key=AIzaSyCKNc4mBhMiiB-VGu8twC7GEH0iIvphRw0");
      List<dynamic> list = jsonDecode(response.body)["results"];
      list.forEach((v) {
        placeLocation.add(PlaceLocation(
          name: v["name"],
          lat: v["geometry"]['location']['lat'],
          lng: v["geometry"]['location']['lng'],
        ));
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        title: Text("ADD PROMOTION"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: enableUpload(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: Icon(Icons.add_a_photo),
        backgroundColor: Colors.brown,
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: sampleImage != null

                  /// กำหนดอัตรส่วนภาพ
                  ? AspectRatio(
                      aspectRatio: 3 / 2,
                      child: FadeInImage(
                          fit: BoxFit.cover,
                          placeholder: MemoryImage(kTransparentImage),
                          image: FileImage(sampleImage)),
                    )
                  : SizedBox(),
            ),
            SizedBox(
              height: 24.0,
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey)),

              ///  ClipRRect ใช้ตัดขอบ widget
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: sampleLogo != null
                    ? FadeInImage(
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: MemoryImage(kTransparentImage),
                        image: FileImage(sampleLogo),
                      )
                    : SizedBox(),
              ),
            ),
            SizedBox(
              height: 24.0,
            ), 
            FlatButton.icon(
                color: Colors.brown[400],
                textColor: Colors.white,
                onPressed: () => getImage(isLogo: true),
                icon: Icon(Icons.add_a_photo),
                label: Text(
                  '  เพิ่มรูปภาพโลโก้ร้านค้า',
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                )),
            SizedBox(
              height: 16,
            ),
            TextFormField(
              initialValue: widget.edit == null ? "" : widget.edit.shopname,
              maxLines: 2,
              decoration: InputDecoration(labelText: 'ชื่อร้านค้า'),
              validator: (value) {
                return value.isEmpty
                    ? 'กรุณาใส่รายละเอียดเกี่ยวกับโปรโมชั่น'
                    : null;
              },
              onSaved: (value) {
                _myName = value;
              },
            ),
            SizedBox(
              height: 8.0,
            ),
            TextFormField(
              initialValue: widget.edit == null ? "" : widget.edit.description,
              maxLines: 2,
              decoration: InputDecoration(labelText: 'หัวข้อโปรโมชั่น'),
              validator: (value) {
                return value.isEmpty
                    ? 'กรุณาใส่รายละเอียดเกี่ยวกับโปรโมชั่น'
                    : null;
              },
              onSaved: (value) {
                _myValue = value;
              },
            ),
            SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlineButton(
                borderSide: BorderSide(style: BorderStyle.none),
                child: Text(
                  "เพิ่มตำแหน่งที่ตั้ง",
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SearchPlace(
                        onSelect: (PlaceLocation placeLocation) {
                          placeLocationSelected = placeLocation;
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            if (placeLocationSelected == null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(placeLocation.length, (i) {
                    return GestureDetector(
                      onTap: () {
                        placeLocationSelected = placeLocation[i];
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text("${placeLocation[i].name}"),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.brown[400],
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "${placeLocationSelected.name}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          placeLocationSelected = null;
                          setState(() {});
                        }),
                  ],
                ),
              ),
            SizedBox(
              height: 8,
            ),
            TextFormField(
              initialValue:
                  widget.edit == null ? "" : widget.edit.loneDescription,
              maxLines: 9,
              decoration: InputDecoration(
                labelText: 'เกี่ยวกับโปรโมชั่น/ร้านค้า',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                return value.isEmpty
                    ? 'กรุณาใส่รายละเอียดเกี่ยวกับโปรโมชั่น'
                    : null;
              },
              onSaved: (value) {
                myLongDec = value;
              },
            ),
            SizedBox(
              height: 16,
            ),
            RaisedButton(
              elevation: 10.0,
              child: Text('บันทึกข้อมูล'),
              textColor: Colors.white,
              color: Colors.brown,
              onPressed: uploadStatusImage,
            )
          ],
        ),
      ),
    );
  }

  /// ดาวน์โหลดรูปจาก FIREBASE
  Future<File> loadImageToFile(String url) async {
    http.Response response = await http.get(url);
    Directory tempDir = await getTemporaryDirectory();

    String path = tempDir.path + "${DateTime.now().millisecondsSinceEpoch}.jpg";
    print(response.body);
    File f = await File(path).writeAsBytes(
      response.bodyBytes.buffer.asUint8List(
        response.bodyBytes.offsetInBytes,
        response.bodyBytes.lengthInBytes,
      ),
    );
    print(f.lengthSync());
    return f;
  }
}
