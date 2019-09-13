import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:ubcfpv3/screen/addpro_screen.dart';
import 'package:ubcfpv3/screen/detail_screen.dart';

import 'posts.dart';

class MeScreen extends StatefulWidget {
  @override
  _MeScreenState createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  var location = Location();
  /// กำหนด format ของตัวเลขให้มี ',' กับ ทศนิยม สองตำแหน่ง
  static final formatterNumberDouble = NumberFormat("#,##0.00");
  DatabaseReference postsRef =
      FirebaseDatabase.instance.reference().child("Posts");

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: FutureBuilder<LocationData>(
        /// ดึงตำแหน่งปัจจุบัน
        future: location.getLocation(),
        builder: (BuildContext context,
            AsyncSnapshot<LocationData> snapshotCurrentLocation) {
          if (snapshotCurrentLocation.hasError) {
            return Text(
              "Permission Denied\nPlease allow access to your current location in your setting.",
              textAlign: TextAlign.center,
            );
          } else if (!snapshotCurrentLocation.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Looking for the current location",
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
          print(
              "${snapshotCurrentLocation.data.latitude} : ${snapshotCurrentLocation.data.longitude}");

          /// ดึงข้อมมูลจาก firebase
          return FutureBuilder(
            future: postsRef.once(),
            builder:
                (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final List<Posts> postData = [];
              var KEYS = snapshot.data.value.keys;
              var DATA = snapshot.data.value;
              for (var key in KEYS) {
                Posts posts = Posts(
                  DATA[key]['image'],
                  DATA[key]['description'],
                  DATA[key]['date'],
                  DATA[key]['time'],
                  DATA[key]['shopname'],
                  DATA[key]['logo'],
                  DATA[key]['lat'],
                  DATA[key]['lng'],
                  DATA[key]['loneDescription'],
                  key: key,
                  locationName: DATA [key]['locationName'],
                );
                postData.add(posts);
                  }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                itemCount: postData.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = postData[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(posts : postData[index]),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: item.logo == null ? "" : item.logo,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                              item.shopname,
                              style: Theme.of(context)
                                  .textTheme
                                  .title
                                  .copyWith(fontSize: 18),
                            )),
                            /// คำนวนระยะทาง
                            FutureBuilder<double>(
                              future: Geolocator().distanceBetween(
                                item.lat,
                                item.lng,
                                snapshotCurrentLocation.data.latitude,
                                snapshotCurrentLocation.data.longitude,
                              ),
                              builder: (BuildContext context,
                                  AsyncSnapshot<double> snapshotDis) {
                                if (snapshot.hasData) {
                                  try {
                                    return Text(
                                        "${formatterNumberDouble.format(snapshotDis.data / 1000)} Km.");
                                  } catch (_) {
                                    return Text("0.0 Km.");
                                  }
                                }
                                return Text("0.0 Km.");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
