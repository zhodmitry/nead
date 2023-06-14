import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'quickClasses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class TeacherFindStudents extends StatefulWidget {
  final String userID;
  TeacherFindStudents({Key key, @required this.userID});
  @override
  _TCS createState() => _TCS();
}

class _TCS extends State<TeacherFindStudents> {
  _qrCodeScanner() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    String path = image.path;
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFilePath(path);
    final barcodeDetector = FirebaseVision.instance.barcodeDetector();
    var barcodes = await barcodeDetector.detectInImage(visionImage);
    if (barcodes.isEmpty) {
      final snc = SnackBar(content: Text("Couldn't recognize QR code"), duration: Duration(seconds: 3),);
      scaffKey.currentState.showSnackBar(snc);
    }
    else {
      print(barcodes[0].rawValue);
      _studentFinder(barcodes[0].rawValue);
    }
  }

  _returner() {
    if (isLoading) {
      return LoadingAnimation();
    } else if (doesntExist == true) {
      return FailureAnimation();
    } else if (isDone) {
      return SuccessAnimation();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                top: (MediaQuery.of(context).size.width -
                        (MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            2)) /
                    3),
            child: Column(
              children: <Widget>[
                Center(
                    child: AutoSizeTextWidget(
                  text: studentName,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      2.5,
                )),
                Center(
                    child: AutoSizeTextWidget(
                  text: studentSurname,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      2.5,
                )),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: (MediaQuery.of(context).size.width -
                        (MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            2)) /
                    3,
                bottom: (MediaQuery.of(context).size.width -
                        (MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            2)) /
                    3),
            child: Center(child: avatar),
          ),
          buttonAdd
        ],
      );
    }
  }

  _studentFinder(String id) async {
    setState(() {
      studentID = id;
      isLoading = true;
    });
    DocumentSnapshot teacherSnapshot = await Firestore.instance
        .collection("users")
        .document(widget.userID)
        .get();
    var documentSnapshot = await Firestore.instance
        .collection("users")
        .where("id", isEqualTo: id)
        .getDocuments();
    print(documentSnapshot.documents);
    if (documentSnapshot.documents.isNotEmpty) {
      DocumentSnapshot snapshotStudents =
          await Firestore.instance.collection("users").document(id).get();
      if (snapshotStudents.data["isTeacher"] == false) {
        setState(() {
          studentAvatar = snapshotStudents.data["avatar"];
          studentName = snapshotStudents.data["name"];
          studentSurname = snapshotStudents.data["surname"];
          avatar = SvgPicture.asset(
            studentAvatar,
            width: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"] *
                2,
            height: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"] *
                2,
          );
          if (teacherSnapshot.data["currentStudents"].contains(id)) {
            buttonAdd = Center(
              child: Container(
                height: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"] /
                    2,
                width: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] *
                          0.24,
                      height: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] *
                          0.24,
                      child: SvgPicture.asset(
                        "assets/done_icon.svg",
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    AutoSizeTextWidget(
                      text: "Added",
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          2 *
                          0.8,
                      height: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          2,
                      textColor: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Theme.of(context).primaryColor)),
              ),
            );
          } else {
            buttonAdd = Center(
              child: Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    highlightColor: Colors.grey.withOpacity(0.2),
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      DocumentSnapshot snapshot = await Firestore.instance
                          .collection("users")
                          .document(widget.userID)
                          .get();
                      var existedStudents =
                          snapshot.data["currentStudents"].toList();
                      existedStudents.add(studentID);
                      await Firestore.instance
                          .collection("users")
                          .document(widget.userID)
                          .updateData({"currentStudents": existedStudents});
                      setState(() {
                        isLoading = false;
                        buttonAdd = Center(
                          child: Container(
                            height: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["iconSize"] /
                                2,
                            width: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["iconSize"],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"] *
                                      0.24,
                                  height: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"] *
                                      0.24,
                                  child: SvgPicture.asset(
                                    "assets/done_icon.svg",
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                AutoSizeTextWidget(
                                  text: "Added",
                                  width: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"] /
                                      2 *
                                      0.8,
                                  height: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"] /
                                      2,
                                  textColor: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor)),
                          ),
                        );
                        isDone = true;
                      });
                      await Future.delayed(Duration(seconds: 2));
                      setState(() {
                        isDone = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28)),
                      height: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          2,
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"],
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] *
                                  0.24,
                              height: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] *
                                  0.24,
                              child: SvgPicture.asset(
                                "assets/round-add-24px.svg",
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            AutoSizeTextWidget(
                              text: "Add",
                              width: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] /
                                  2 *
                                  0.6,
                              height: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] /
                                  2,
                              textColor: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w400,
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            );
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          doesntExist = true;
        });
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          doesntExist = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
        doesntExist = true;
      });
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        doesntExist = false;
      });
    }
  }

  bool isLoading = false;
  bool doesntExist = false;
  bool isDone = false;
  String studentID = "";
  String studentAvatar = "";
  String studentName = "";
  String studentSurname = "";
  Widget avatar = Container();
  Widget buttonAdd = Container();
  GlobalKey<ScaffoldState> scaffKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffKey,
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: (MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              2)) /
                      3),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["textFieldWidth"],
                child: TextField(
                  cursorColor: Theme.of(context).primaryColor,
                  autofocus: true,
                  style: TextStyle(color: Theme.of(context).bottomAppBarColor),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      iconSize: 20,
                      onPressed: () => _qrCodeScanner(),
                      icon: QrImage(
                        size: 20,
                        padding: EdgeInsets.zero,
                        data: widget.userID,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(28 / 3.16666666666)),
                    labelText: "Student's ID",
                  ),
                  onSubmitted: (id) {
                    _studentFinder(id);
                  },
                ),
              ),
            ),
            _returner()
          ],
        ),
      ),
    );
  }
}
