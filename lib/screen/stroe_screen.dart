import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ubcfpv3/screen/addpro_screen.dart';
import 'package:ubcfpv3/screen/detail_screen.dart';

import 'posts.dart';

class StroeScreen extends StatefulWidget {
  @override
  _StroeScreenState createState() => _StroeScreenState();
}

class _StroeScreenState extends State<StroeScreen> {
  DatabaseReference postsRef =
      FirebaseDatabase.instance.reference().child("Posts");

  @override
  Widget build(BuildContext context) {
    return Container(
      /// [FutureBuilder] => เป็น widget ที่ใช้จัดการกับข้อมมูลที่เป็น Async
      child: FutureBuilder(
        future: postsRef.once(),
        builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
          /// [!snapshot.hasData] => เช็คว่ามีดาต้ารึเปล่า ถ้าไม่มีให้แสดงสถานนะกำลังโหลด แต่ถ้ามี ให้แสดงข้อมูล
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailScreen(posts: postData[index]),
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
                            borderRadius: BorderRadius.circular(5),

                            /// [CachedNetworkImage] => เป็น library ใช้ดึงรูป
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

                          /// [Theme.of(context)] => ใช้ดึง style ที่อยู่ในระบบ
                          style: Theme.of(context)
                              .textTheme
                              .title
                              .copyWith(fontSize: 18),
                        )),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
