import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'posts.dart';

class DetailScreen extends StatefulWidget {
  final Posts posts;

  const DetailScreen({Key key, @required this.posts}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static final formatterNumberDouble = NumberFormat("#,##0.00");
  LocationData locationData;

  @override
  void initState() {
    Location().getLocation().then((v) {
      locationData = v;
      setState(() {});
    });
    super.initState();
  }


  @override

  Widget build(BuildContext context,){

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        title: Text("DETAIL"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          /// CrossAxisAlignment.stretch ขยายให้เต็ม width
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            /// กำหนดอัตราส่วน เช่น 1/2 , 3/4 16/9 ...
            AspectRatio(
              aspectRatio: 1/1,
              child: CachedNetworkImage(
                imageUrl: widget.posts.image,
                fit: BoxFit.fill,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.broken_image),
              ),
            ),
            SizedBox (

            height: 10.0,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    widget.posts.description,

                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Colors.brown[300],
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      if (locationData != null)

                        /// Expanded คือการขยายให้เต็มพี่นที่ โดยจะต้องอยู่ภายใน column หรือ row เท่านั่น
                        Expanded(
                          child: FutureBuilder<double>(
                            future: Geolocator().distanceBetween(
                              widget.posts.lat,
                              widget.posts.lng,
                              locationData.latitude,
                              locationData.longitude,
                            ),
                            builder: (BuildContext context,
                                AsyncSnapshot<double> snapshot) {
                              var dis = 0.0;
                              if (snapshot.hasData) {
                                dis = snapshot.data;
                              }
                              return Text(
                                  "${formatterNumberDouble.format(dis / 1000)} Km.");
                            },
                          ),
                        )
                      else
                        Text("0.0 Km.")
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: Colors.brown[300],
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Text(
                              "${widget.posts.date} ${widget.posts.time}")),
                    ],
                  ),

                  Divider(),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: widget.posts.logo == null
                                ? ""
                                : widget.posts.logo,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      SizedBox (
                        width: 2,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              "${widget.posts.shopname}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            GestureDetector(
                              onTap: (){
                                _openMap(widget.posts);
                              },
                              child: Text(
                                widget.posts.locationName,
                                style:
                                TextStyle(color: Colors.blueAccent ),
                              ),
                            ),
                          ],
                        )
                      ),

                    ],

                  ),

                  Divider(),
                  Text(
                    "Decription",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.posts.loneDescription,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  RaisedButton.icon(
                    color: Colors.brown[400],
                    icon: Icon(IconData(0xe938, fontFamily: 'icomoon'),color: Colors.white,),
                    onPressed: () { //ใส่ปุ่มแสกน
                    },
                    label: Text("สแกน QR CODE เพื่อใช้สิทธิ์",style: TextStyle(color: Colors.white),),
                  ),

                  RaisedButton.icon(
                    color: Colors.blueAccent,
                    icon: Icon(Icons.share,color: Colors.white),
                    onPressed: () {
                      print(widget.posts.image);
                      /// FlutterShareMe library ที่ช่วยทำให้การแชร์ไปที่ facebook ง่ายขึ้น
                      FlutterShareMe().shareToFacebook(
                        url: '${widget.posts.image}',
                        msg: "${widget.posts.description}",
                      );
                    },
                    label: Text("แชร์ไปยัง FACEBOOK",style: TextStyle(color: Colors.white),),
                  ),
                  SizedBox(height: 56,)
                ],
              ),
            ),
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
