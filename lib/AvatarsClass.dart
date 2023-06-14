import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class Avatars extends StatefulWidget {
  final String avatar;
  Avatars({@required this.avatar});
  @override
  _AVS createState() => _AVS();
}

class _AVS extends State<Avatars> {
  @override
  void initState() {
    super.initState();
    setState(() {
      setImage = widget.avatar;
    });
  }

  final List<String> avatars = [
    //   // "avatars_images/01.png",
    //   // "avatars_images/02.png",
    //   // "avatars_images/03.png",
    //   // "avatars_images/04.png",
    //   // "avatars_images/05.png",
    //   // "avatars_images/06.png",
    //   // "avatars_images/07.png",
    //   // "avatars_images/08.png",
    //   "avatars_images/avatar-1.png",
    //   "avatars_images/avatar-2.png",
    //   "avatars_images/avatar-3.png",
    //   "avatars_images/avatar-4.png",
    //   "avatars_images/avatar-5.png",
    //   "avatars_images/avatar-6.png",
    //   "avatars_images/avatar-7.png",
    //   "avatars_images/avatar-8.png",
    //   "avatars_images/avatar-011.png",
    //   "avatars_images/avatar-021.png",
    //   "avatars_images/avatar-031.png",
    //   "avatars_images/avatar-041.png",
    //   "avatars_images/avatar-051.png",
    //   "avatars_images/avatar-061.png",
    //   "avatars_images/avatar-071.png",
    //   "avatars_images/avatar-081.png",
    //   "avatars_images/avatar-091.png",
    //   "avatars_images/avatar-101.png"
  ];

  final List<String> newAvatars = [
    // "newAvatars/001.svg",
    // "newAvatars/002.svg",
    // "newAvatars/004.svg",
    // "newAvatars/005.svg",
    // "newAvatars/006.svg",
    // "newAvatars/007.svg",
    // "newAvatars/008.svg",
    // "newAvatars/009.svg",
    // "newAvatars/010.svg",
    // "newAvatars/011.svg",
    // "newAvatars/012.svg",
    // "newAvatars/013.svg",
    // "newAvatars/014.svg",
    // "newAvatars/015.svg",
    // "newAvatars/016.svg",
    // "newAvatars/017.svg",
    // "newAvatars/018.svg",
    // "newAvatars/019.svg",
    // "newAvatars/020.svg",
    // "newAvatars/021.svg",
    // "newAvatars/022.svg",
    // "newAvatars/023.svg",
    // "newAvatars/024.svg",
    // "newAvatars/025.svg",
    // "newAvatars/026.svg",
    // "newAvatars/027.svg",
    // "newAvatars/028.svg",
    // "newAvatars/029.svg",
    // "newAvatars/030.svg",
    // "newAvatars/031.svg",
    // "newAvatars/032.svg",
    // "newAvatars/033.svg",
    // "newAvatars/034.svg",
    // "newAvatars/035.svg",
    // "newAvatars/036.svg",
    "newAvatars/037.svg",
    "newAvatars/038.svg",
    "newAvatars/039.svg",
    "newAvatars/040.svg",
    "newAvatars/041.svg",
    "newAvatars/042.svg",
    "newAvatars/043.svg",
    "newAvatars/044.svg",
    "newAvatars/045.svg",
    "newAvatars/046.svg",
    "newAvatars/047.svg",
    "newAvatars/048.svg",
    "newAvatars/049.svg",
    "newAvatars/050.svg",
    "newAvatars/051.svg",
    "newAvatars/052.svg",
    "newAvatars/053.svg",
    "newAvatars/054.svg",
    "newAvatars/055.svg",
    "newAvatars/056.svg",
    "newAvatars/057.svg",
    "newAvatars/058.svg",
    "newAvatars/059.svg",
    "newAvatars/060.svg",
    "newAvatars/061.svg",
    "newAvatars/062.svg",
    "newAvatars/063.svg",
    "newAvatars/064.svg",
    "newAvatars/065.svg",
    "newAvatars/066.svg",
    "newAvatars/067.svg",
    "newAvatars/068.svg",
    "newAvatars/069.svg",
    "newAvatars/070.svg",
    "newAvatars/071.svg",
    "newAvatars/072.svg",
    "newAvatars/073.svg",
    "newAvatars/074.svg",
    "newAvatars/075.svg",
    "newAvatars/076.svg",
    "newAvatars/077.svg",
    "newAvatars/078.svg",
    "newAvatars/079.svg",
    "newAvatars/080.svg",
    "newAvatars/081.svg",
    "newAvatars/082.svg",
    "newAvatars/083.svg",
    "newAvatars/084.svg",
    "newAvatars/085.svg",
    "newAvatars/086.svg",
    "newAvatars/087.svg",
    "newAvatars/088.svg",
    "newAvatars/089.svg",
    "newAvatars/090.svg",
    "newAvatars/091.svg",
    "newAvatars/092.svg",
    "newAvatars/093.svg",
    "newAvatars/094.svg",
    "newAvatars/095.svg",
    "newAvatars/096.svg",
    "newAvatars/097.svg",
    "newAvatars/098.svg",
    "newAvatars/099.svg",
    "newAvatars/100.svg",
    "newAvatars/101.svg",
    "newAvatars/102.svg",
    "newAvatars/103.svg",
    "newAvatars/104.svg",
    "newAvatars/105.svg",
    "newAvatars/106.svg",
    "newAvatars/107.svg",
    "newAvatars/108.svg",
    "newAvatars/109.svg",
    "newAvatars/110.svg",
    "newAvatars/111.svg",
    "newAvatars/112.svg",
    "newAvatars/113.svg",
    "newAvatars/114.svg",
    "newAvatars/115.svg",
    "newAvatars/116.svg",
    "newAvatars/117.svg",
    "newAvatars/118.svg",
    "newAvatars/119.svg",
    "newAvatars/120.svg",
    "newAvatars/121.svg",
    // "newAvatars/122.svg",
    "newAvatars/123.svg",
    "newAvatars/124.svg",
    "newAvatars/125.svg",
    "newAvatars/126.svg",
    "newAvatars/127.svg",
    "newAvatars/128.svg",
    "newAvatars/129.svg",
    "newAvatars/130.svg",
    "newAvatars/131.svg",
    "newAvatars/132.svg",
    "newAvatars/133.svg",
    "newAvatars/134.svg",
    "newAvatars/135.svg",
    "newAvatars/136.svg",
  ];

  _avatarDialog(String location) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            content: Container(
              child: SvgPicture.asset(location),
            ),
          );
        });
  }

  String setImage;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(setImage);
      },
      child: new Scaffold(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          body: Builder(builder: (BuildContext context) {
            return GridView.count(
                physics: BouncingScrollPhysics(),
                crossAxisCount: 3,
                children: List.generate(newAvatars.length, (index) {
                  return Container(
                    child: Material(
                      color: Theme.of(context).secondaryHeaderColor,
                      child: InkWell(
                        onLongPress: () {
                          _avatarDialog(newAvatars[index]);
                        },
                        highlightColor: Colors.grey.withOpacity(0.2),
                        onTap: () async {
                          setState(() {
                            setImage = newAvatars[index];
                          });
                          SharedPreferences saver =
                              await SharedPreferences.getInstance();
                          saver.setString("avatar_image", newAvatars[index]);
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content:
                                Text("The image has been set as your avatar"),
                          ));
                          FirebaseAuth auth = FirebaseAuth.instance;
                          FirebaseUser user = await auth.currentUser();
                          await Firestore.instance
                              .collection("users")
                              .document(user.uid)
                              .updateData({"avatar": newAvatars[index]});
                        },
                        child: Container(
                          child: Hero(
                              tag: newAvatars[index],
                              child: SvgPicture.asset(newAvatars[index])),
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.2))),
                  );
                }));
          })),
    );
  }
}
