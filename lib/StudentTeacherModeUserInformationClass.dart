import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; //show PlatformException;
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notexactly/main.dart';
import 'package:notexactly/quickClasses.dart';
import 'package:provider/provider.dart';
import 'AvatarsClass.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserInformation extends StatefulWidget {
  final String userID;
  final String avatar;
  final bool isTeacher;
  UserInformation(
      {@required this.userID, @required this.avatar, @required this.isTeacher});
  _UserAccount createState() => _UserAccount();
}

class _UserAccount extends State<UserInformation> {
  final keyName = GlobalKey<FormState>();
  final keySurname = GlobalKey<FormState>();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerSurname = TextEditingController();

  _firebaseAuth() async {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection("users")
        .document(widget.userID)
        .get();
    setState(() {
      controllerName.text = snapshot.data["name"];
      controllerSurname.text = snapshot.data["surname"];
      oldLNAme = snapshot.data["surname"];
      oldName = snapshot.data["name"];
      newLNAme = snapshot.data["surname"];
      newName = snapshot.data["name"];
    });
  }

  _logOutProcess() async {
    FirebaseMessaging messaging = FirebaseMessaging();
    String token = await messaging.getToken();
    await Firestore.instance
        .collection("users")
        .document(widget.userID)
        .collection("devices")
        .document(token)
        .delete();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  _signOutDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Log out?",
                style: TextStyle(color: Theme.of(context).bottomAppBarColor)),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: 90,
                    height: 40,
                    child: Center(
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: () => _logOutProcess(),
                  child: Container(
                    color: Colors.transparent,
                    width: 50,
                    height: 40,
                    child: Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  _qrCodeDisplayer() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            backgroundColor: Colors.white,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: QrImage(
                  data: widget.userID,
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _firebaseAuth());
    setState(() {
      avatar = widget.avatar;
    });
  }

  String oldName;
  String oldLNAme;
  String newName;
  String newLNAme;
  String avatar;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(avatar);
      },
      child: Scaffold(
        key: key,
        backgroundColor: Theme.of(context).primaryColorDark,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  var data = await Navigator.push(
                      context,
                      FadeRoute(
                          page: Avatars(
                        avatar: avatar,
                      )));
                  setState(() {
                    avatar = data;
                  });
                },
                child: Center(
                    child: Container(
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"],
                        height: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["height"],
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              width: 0.7,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2)),
                        ),
                        child: Hero(
                            tag: avatar,
                            child: Container(
                                width: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] *
                                    1.5,
                                height: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] *
                                    1.5,
                                child: SvgPicture.asset(avatar))))),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["textFieldWidth"],
                  child: Form(
                    key: keyName,
                    child: TextFormField(
                      onChanged: (data) {
                        setState(() {
                          newName = data;
                        });
                      },
                      cursorColor: Theme.of(context).primaryColor,
                      controller: controllerName,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).bottomAppBarColor),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(28 / 3.16666666666)),
                          labelText: "First name"),
                      validator: (name) {
                        if (name.isEmpty) {
                          return "Name field cannot be empty";
                        }
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["textFieldWidth"],
                  child: Form(
                    key: keySurname,
                    child: TextFormField(
                      onChanged: (data) {
                        setState(() {
                          newLNAme = data;
                        });
                      },
                      cursorColor: Theme.of(context).primaryColor,
                      controller: controllerSurname,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).bottomAppBarColor),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(28 / 3.16666666666)),
                          labelText: "Last name"),
                      validator: (name) {
                        if (name.isEmpty) {
                          return "Surname field cannot be empty";
                        }
                      },
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                switchInCurve: Curves.fastOutSlowIn,
                switchOutCurve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 300),
                child: oldLNAme != newLNAme || oldName != newName
                    ? Material(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(28),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          highlightColor: Colors.grey.withOpacity(0.2),
                          onTap: () async {
                            if (keySurname.currentState.validate() &&
                                oldLNAme != newLNAme) {
                              await Firestore.instance
                                  .collection("users")
                                  .document(widget.userID)
                                  .updateData(
                                      {"surname": controllerSurname.text});
                            }
                            if (keySurname.currentState.validate() &&
                                oldName != newName) {
                              await Firestore.instance
                                  .collection("users")
                                  .document(widget.userID)
                                  .updateData({"name": controllerName.text});
                            }
                            key.currentState.showSnackBar(SnackBar(
                              content: Text("Changes have been saved."),
                            ));
                            setState(() {
                              oldLNAme = newLNAme;
                              oldName = newName;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28)),
                            width: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["iconSize"],
                            height: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["iconSize"] /
                                2,
                            child: Center(
                              child: AutoSizeTextWidget(
                                width: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] /
                                    2.8,
                                text: "Save",
                                fontWeight: FontWeight.w400,
                                textColor: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ),
              widget.isTeacher == false
                  ? Center(
                      child: AutoSizeTextWidget(
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"] *
                            0.7,
                        text: "Your ID:",
                      ),
                    )
                  : Container(),
              widget.isTeacher == false
                  ? Center(
                      child: GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: widget.userID));
                          final snackBar = SnackBar(
                            content:
                                Text("Your ID has been copied to clipboard."),
                          );
                          key.currentState.showSnackBar(snackBar);
                        },
                        child: AutoSizeTextWidget(
                          text: widget.userID,
                          width: MediaQuery.of(context).size.width -
                              (MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] *
                                  0.7),
                        ),
                      ),
                    )
                  : Container(),
              widget.isTeacher == false
                  ? Center(
                      child: IconButton(
                        tooltip: "Show QR code with my ID",
                        icon: Center(
                          child: QrImage(
                            padding: EdgeInsets.zero,
                            data: widget.userID,
                            foregroundColor: Theme.of(context).primaryColor,
                            backgroundColor: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        onPressed: () => _qrCodeDisplayer(),
                      ),
                    )
                  : Container(),
              Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  onTap: _signOutDialog,
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(28)),
                    width: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"],
                    height: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"] /
                        2,
                    child: Center(
                      child: AutoSizeTextWidget(
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"] /
                            2,
                        text: "Log out",
                        fontWeight: FontWeight.w400,
                        textColor: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
