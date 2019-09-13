import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:ubcfpv3/screen/place_location.dart';

class SearchPlace extends StatefulWidget {
  /// ตัว callback เพื่อใช้ในการส่งสถานที่ที่เราเลือกกลับไปยังตัวที่เรียกใช้ class นี้
  final void Function(PlaceLocation placeLocation) onSelect;

  const SearchPlace({Key key, @required this.onSelect}) : super(key: key);

  @override
  _SearchPlaceState createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  final List<PlaceLocation> placeLocation = [] ;/// เก็บ สถานที่ใกล้เคียง
  var location = Location();
  bool isLoading = false; /// ใช้ในการไว้เช็คว่าสถานะตอนนี้คืออะไร โหลดอยู่รึเปล่า อะไรประมาณนี้

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void loadPlaceLocation({String textSearch = ""}) async {
    try {
      isLoading = true;
      setState(() {});
      LocationData locationData = await location.getLocation();

      /// ดึงข้อมมูลสถานที่ใกล้เคียงจาก api ของ google
      /// ref : [https://developers.google.com/places/web-service/intro?hl=th]
      http.Response response = await http.get(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$textSearch&location=${locationData.latitude},${locationData.longitude}&radius=15000&keyword=cruise&language=th&key=AIzaSyCKNc4mBhMiiB-VGu8twC7GEH0iIvphRw0",
      );

      /// ดึงผลลัพธ์ที่ได้ออกมา
      List<dynamic> list = jsonDecode(response.body)["results"];
      print(list.length);
      placeLocation.clear();
      /// วน loop เป็นข้อมมูลไว้ใน placeLocation
      list.forEach((v) {
        placeLocation.add(PlaceLocation(
          name: v["name"],
          lat: v["geometry"]['location']['lat'],
          lng: v["geometry"]['location']['lng'],
          plusCode: v["plus_code"]['compound_code'],
        ));
        print(v["name"]);
      });
      /// load ข้อมมูลเสร็จสิ้น
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print(e);
    }
    /// อัพเดท View
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SEARCH"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: controller,
                  )),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      loadPlaceLocation(textSearch: controller.text);
                    },
                  ),
                ],
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : (placeLocation.length != 0 && !isLoading)
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: placeLocation.length,
                          itemBuilder: (BuildContext context, int index) {
///                            Material(
///                              child: InkWell(
///                                  onTap: () {
///                                  },
                            /// ใส่ animation ให้ กับ Container
                            return Material(
                              child: InkWell(
                                onTap: () {
                                  widget.onSelect(placeLocation[index]);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text("${placeLocation[index].name}"),
                                      Text(
                                        "${placeLocation[index].plusCode}",
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Text("กรุณากรอกชื่อร้านค้าเพื่อค้นหา")
          ],
        ),
      ),
    );
  }
}
