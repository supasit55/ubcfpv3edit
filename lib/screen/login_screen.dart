import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:ubcfpv3/screen/home_screen.dart';
import 'package:ubcfpv3/screen/user.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';


GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignInAccount _currentUser;
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<Null> _facebookLogin() async {
    final FacebookLoginResult result =
    await facebookSignIn.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        await firebaseAuth.signInWithCredential(FacebookAuthProvider.getCredential(accessToken: accessToken.token));
        await getFacebookInfo(accessToken.token);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  Future<Null> _handleSignIn() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly'
        ]
      );
      _currentUser = await googleSignIn.signIn();
      GoogleSignInAuthentication authentication = await _currentUser.authentication;

      firebaseAuth.signInWithCredential(
          GoogleAuthProvider.getCredential(idToken: authentication.idToken, accessToken: authentication.accessToken));

      FirebaseUser firebaseUser = await firebaseAuth.currentUser();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(firebaseUser: firebaseUser)));
    } catch (error) {
      print("==========");
      print(error);
      print("==========");
    }
  }

  Future getFacebookInfo(token) async {
    String url =
        'https://graph.facebook.com/v2.8/me?fields=picture.type(large),email,first_name,last_name&access_token=$token';
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {

        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        User user = User();
        user.displayname =
        '${jsonResponse['first_name']} ${jsonResponse['last_name']}';
        user.email = jsonResponse['email'];
        user.photouserUrl = jsonResponse['picture']['data']['url'];
        FirebaseUser firebaseUser = await firebaseAuth.currentUser();
        print('------------ $firebaseUser ---------------');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(firebaseUser: firebaseUser)));
      } else {
        print('Connection error!!');
      }
    } catch (error) {
      print(error);
    }
  }
  @override
  Widget build(BuildContext context) {
    firebaseAuth.currentUser().then((data) {
      print(data);
    });
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/p23.jpg'))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton.icon(
                      color: Colors.red[600],
                      textColor: Colors.white,
                      onPressed: () => _handleSignIn(),
                      icon: Icon(IconData(0xea89, fontFamily: 'icomoon')),
                      label: Text(
                        'ล็อกอินด้วย Google    ',
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      )),
                  FlatButton.icon(
                      color: Colors.blue[900],
                      textColor: Colors.white,
                      onPressed: () => _facebookLogin(),
                      icon: Icon(IconData(0xea91, fontFamily: 'icomoon')),
                      label: Text(
                        'ล็อกอินด้วย Facebook',
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      )),
                  Container(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'Contact : supasit.kit59@ubru.ac.th',
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

