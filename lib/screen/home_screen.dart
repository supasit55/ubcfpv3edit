import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ubcfpv3/screen/addpro_screen.dart';
import 'package:ubcfpv3/screen/login_screen.dart';
import 'package:ubcfpv3/screen/me_screen.dart';
import 'package:ubcfpv3/screen/pro_screen.dart';
import 'package:ubcfpv3/screen/stroe_screen.dart';
import 'package:ubcfpv3/screen/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubcfpv3/screen/registershop_screen.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
	scopes: <String>[
		'email',
	],
);

class HomeScreen extends StatefulWidget {
	final FirebaseUser firebaseUser;

	HomeScreen({this.firebaseUser});

	@override
	_HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	static final FacebookLogin facebookSignIn = new FacebookLogin();
	final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

	Future<Null> _handleSignOut() async {
		await _googleSignIn.disconnect();
		await facebookSignIn.logOut();
		Navigator.of(context).pushReplacement(
				MaterialPageRoute(builder: (context) => LoginScreen()));
	}

	int currentIndex = 0;
	static final List pages = [ProScreen(), StroeScreen(), MeScreen()];

	Widget _buildAppbar() {
		return AppBar(
			backgroundColor: Colors.brown[400],
			title: Text(
				'UBONCOFFEEPRO',
			),
			actions: <Widget>[
				IconButton(icon: Icon(Icons.search), onPressed: () {}),
				IconButton(
						icon: Icon(Icons.add),
						onPressed: () {
							Navigator.push(context, MaterialPageRoute(builder: (context) {
								return new AddproScreen();
							}));
						}),
			],
		);
	}

	Widget _buildDrawer() {
		return Drawer(
			// Add a ListView to the drawer. This ensures the user can scroll
			// through the options in the Drawer if there isn't enough vertical
			// space to fit everything.
			child: ListView(
				// Important: Remove any padding from the ListView.
				padding: EdgeInsets.zero,
				children: <Widget>[
					widget.firebaseUser != null ? DrawerHeader(
						child: ListTile(
							leading:
							CircleAvatar(
								backgroundImage: NetworkImage(
									widget.firebaseUser.photoUrl,
								),
							),

							title: Text(
								widget.firebaseUser.displayName,
								style: TextStyle(color: Colors.white, fontSize: 20.0),
							),
							subtitle: Text(
								widget.firebaseUser.email,
								style: TextStyle(color: Colors.white),
							),
						),
						decoration: BoxDecoration(
							image: DecorationImage(
									fit: BoxFit.fill, image: AssetImage('assets/images/p24.jpg')),
						),
					) : SizedBox(),
					ListTile(
						leading: Icon(
							Icons.star,
							color: Colors.yellowAccent,
						),
						title: Text(
							'สมัครสมาชิกร้านค้า',
							style: TextStyle(fontSize: 20.0),
						),
						trailing: Icon(Icons.keyboard_arrow_right),
						subtitle: Text('หากต้องการเพิ่มโปรโมชั่นจำเป็นต้องสมัครสมากชิก'),
						onTap: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (context) =>
											Registershop_Screen(),
								),
							);
						},
					),
					ListTile(
						leading: Icon(
							Icons.forum,
							color: Colors.redAccent,
						),
						title: Text(
							'ข้อมูลสมาชิก',
							style: TextStyle(fontSize: 20.0),
						),
						trailing: Icon(Icons.keyboard_arrow_right),
						subtitle: Text('แสดงข้อมูลสมาชิกร้านค้า'),
						onTap: () {},
					),
					ListTile(
						leading: Icon(
							Icons.contacts,
							color: Colors.orangeAccent,
						),
						title: Text(
							'ติดต่อ',
							style: TextStyle(fontSize: 20.0),
						),
						trailing: Icon(Icons.keyboard_arrow_right),
						subtitle: Text('หากสนใจลงโฆษณา หรือแจ้งปัญหาการใช้งานm'),
						onTap: () {},
					),
					ListTile(
						leading: Icon(
							Icons.directions_bike,
							color: Colors.deepPurple,
						),
						title: Text(
							'สั่งเดลิเวอรี่',
							style: TextStyle(fontSize: 20.0),
						),
						trailing: Icon(Icons.keyboard_arrow_right),
						subtitle: Text('สามารถสั่งไปส่งได้ ผ่านแอปพลิเคชั่น'),
						onTap: () {},
					),
					ListTile(
						leading: Icon(
							Icons.settings,
							color: Colors.green,
						),
						title: Text(
							'เกี่ยวกับแอปพลิเคชัน',
							style: TextStyle(fontSize: 20.0),
						),
						trailing: Icon(Icons.keyboard_arrow_right),
						subtitle: Text('แสดงข้อมูลเกี่ยวกับแอปพลิเคชัน'),
						onTap: () {},
					),
					Divider(),
					ListTile(
						title: Text(
							'ออกจากระบบ',
							style: TextStyle(fontSize: 20.0),
						),
						trailing: Icon(
							Icons.exit_to_app,
							color: Colors.blue,
						),
						subtitle: Text('ขอบคุณที่ใช้บริการแอปของเรา'),
						onTap: () => _handleSignOut(),
					),
				],
			),
		);
	}

	Widget _buildBottomNavBar() {
		return BottomNavigationBar(
			currentIndex: currentIndex,
			onTap: (int index) {
				setState(() {
					currentIndex = index;
				});
			},
			items: [
				BottomNavigationBarItem(
						icon: Icon(IconData(0xe91a, fontFamily: 'icomoon')), title: Text('โปรโมชั่น')),
				BottomNavigationBarItem(
						icon: Icon(Icons.home), title: Text('ร้านค้า')),
				BottomNavigationBarItem(
						icon: Icon(Icons.pin_drop), title: Text('ใกล้ๆคุณ')),
			],
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: _buildAppbar(),
			drawer: _buildDrawer(),
			body: pages[currentIndex],
			bottomNavigationBar: _buildBottomNavBar(),
			resizeToAvoidBottomPadding: true,
		);
	}
}
