import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ubcfpv3/screen/detail_screen.dart';
import 'package:ubcfpv3/screen/posts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'addpro_screen.dart';

class ProScreen extends StatefulWidget {
  @override
  _ProScreenState createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  DatabaseReference postsRef =
      FirebaseDatabase.instance.reference().child("Posts");

  @override
  Widget build(BuildContext context) {
    return Container(
      /// ref  => lib/screen/stroe_screen.dart บันทัดที่ 20
      child: FutureBuilder(
        future: postsRef.once(),
        builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<Posts> postsList = [];
          var KEYS = snapshot.data.value.keys;
          var DATA = snapshot.data.value;

          postsList.clear();

          for (var individuakey in KEYS) {
            Posts posts = Posts(
                DATA[individuakey]['image'],
                DATA[individuakey]['description'],
                DATA[individuakey]['date'],
                DATA[individuakey]['time'],
                DATA[individuakey]['shopname'],
                DATA[individuakey]['logo'],
                DATA[individuakey]['lat'],
                DATA[individuakey]['lng'],
                DATA[individuakey]['loneDescription'],
                key: individuakey,
                locationName: DATA[individuakey]['locationName']);
            postsList.add(posts);
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: postsList.length,
            itemBuilder: (_, index) {
              return postsUI(
                postsList[index].image,
                postsList[index].description,
                postsList[index].date,
                postsList[index].time,
                postsList[index].shopname,
                postsList[index].logo,
                postsList[index],
              );
            },
          );
        },
      ),
    );
  }

  Widget postsUI(String imageUrl, String description, String data, String time,
      String shopName, String logoUrl, Posts posts) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),

                    /// [CachedNetworkImage] => เป็น library ใช้ดึงรูป
                    child: CachedNetworkImage(
                      imageUrl: logoUrl == null ? "" : logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.broken_image),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        shopName,
                        style:
                            TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: (){
                          _openMap(posts);
                        },
                        child: Text(
                          posts.locationName,
                          style:
                              TextStyle(color: Colors.blueAccent ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddproScreen(edit: posts),
                        ),
                      );
                    })
              ],
            ),
            Divider(),
            SizedBox(
              height: 10.0,
            ),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),

                /// [CachedNetworkImage] => เป็น library ใช้ดึงรูป
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              description,
              style: TextStyle(fontSize: 17.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              data + "  " + time,
              style: TextStyle(fontSize: 15.0, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: Text(
                "เข้าดูรายละเอียดเพิ่มเติม",
                style: TextStyle(fontSize: 17.0),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      posts: posts,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  _openMap(Posts posts) async {
    // Android // deeplink => google maps
    var url =
        'https://www.google.com/maps/search/?api=1&query=${posts.lat},${posts.lng}';
    if (Platform.isIOS) {
      // iOS // deeplink => google maps
      url = 'http://maps.apple.com/?ll=${posts.lat},${posts.lng}';
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
