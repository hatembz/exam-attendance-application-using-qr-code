import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../databsemanager.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  void initState() {
    super.initState();
    fetchUserCredentials();
  }
static const url="https://elearning-facsci.univ-annaba.dz/course/index.php?categoryid=6";
  static const _url =
      "https://facsci.univ-annaba.dz/2013/07/22/departement-dinformatique/";

  List userCred = [];

  void fetchUserCredentials() async {
    dynamic result = await DatabaseManager().getuserList();
    if (result == null) {
      print('unable to get data');
    } else {
      setState(() {
        userCred = result;
      });
    }
  }

  void _launchURL(url) async =>
      await canLaunch(url)
          ? await launch(
        url,
      )
          : throw 'Could not launch $url';

  Widget buildList(IconData icon, String title, Function tap) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      onTap: tap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Container(
              color:  Color(0xFF33ccff),
              height: MediaQuery.of(context).size.height*0.15,
              width: double.infinity,
              alignment: Alignment.center,),
             /* child:
                      userCred.isEmpty?CircularProgressIndicator():
                        CircleAvatar(
                           radius: 45,
                            backgroundImage: NetworkImage(
                          '${userCred[0]['image']}')
                      )


            ),*/
            SizedBox(
              height: 20,
            ),
            buildList(Icons.web, "site de departement", () {
              _launchURL(_url);
            }),
            SizedBox(
              height: 10,
            ),
            buildList(Icons.web, "site E-learning", () {
              _launchURL(url);
            }),
            SizedBox(
              height: 10,
            ),
            buildList(Icons.exit_to_app_rounded, "déconnecter", () {
              FirebaseAuth.instance.signOut();
            }),

          ],
        ),
      ),
    );
  }
}
