//import 'package:firebase_performance/firebase_performance.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quickClasses.dart';
// Import needed classes
import 'Classroom.dart';
import 'main.dart';

class TeacherCurrentClassrooms extends StatelessWidget {
  final bool isLiveEnabled;
  final String userID;
  TeacherCurrentClassrooms({@required this.userID, @required this.isLiveEnabled});
  final GlobalKey<ScaffoldState> scaffKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffKey,
      floatingActionButton: FloatingActionButton(
        tooltip: "Create new classroom",
        onPressed: () => Navigator.push(
            context,
            FadeRoute(
                page: TeacherCreateClassroom(
              teacherID: userID,
            ))),
        backgroundColor: Theme.of(context).primaryColor,
        child: Center(
          child: Container(
            child: SvgPicture.asset(
              "assets/round-add-24px.svg",
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
          child: StreamBuilder(
        stream: Firestore.instance
            .collection("users")
            .document(userID)
            .collection("classrooms")
            .document("createdClassrooms")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data["activeClassrooms"].length == 0) {
            return Center(
              child: AutoSizeTextWidget(
                width: MediaQuery.of(context).size.width * 0.8,
                text: "No created classrooms found",
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data["activeClassrooms"].length,
                itemBuilder: (BuildContext context, int i) {
                  Stream classroomStream = Firestore.instance
                      .collection("users")
                      .document(userID)
                      .collection("classrooms")
                      .document("createdClassrooms")
                      .collection(snapshot.data["activeClassrooms"][i])
                      .document("classroomData")
                      .snapshots();
                  return Padding(
                      padding: EdgeInsets.only(
                          top: ((MediaQuery.of(context).size.width -
                                  MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      2) /
                              3)/2, bottom: ((MediaQuery.of(context).size.width -
                                  MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      2) /
                              3)/2),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  2 +
                              (MediaQuery.of(context).size.width -
                                      MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          2) /
                                  3,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 0.7),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(28))),
                          height: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["height"],
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(28),
                            color: Theme.of(context).secondaryHeaderColor,
                            child: InkWell(
                              onLongPress: () async {
                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        title: Text("Archive classroom?",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .bottomAppBarColor)),
                                        content: Text(
                                          "The classroom will be moved to archived classrooms.",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .bottomAppBarColor),
                                        ),
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
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: GestureDetector(
                                              onTap: () async {
                                                Navigator.of(context).pop();
                                                bool isDeleteConfirmed = true;
                                                final snackBar = SnackBar(
                                                  content: Text(
                                                      "The classroom has been archived"),
                                                  duration:
                                                      Duration(seconds: 5),
                                                  action: SnackBarAction(
                                                    label: "UNDO",
                                                    textColor: Theme.of(context)
                                                        .primaryColor,
                                                    onPressed: () {
                                                      isDeleteConfirmed = false;
                                                    },
                                                  ),
                                                );
                                                scaffKey.currentState
                                                    .showSnackBar(snackBar);
                                                await Future.delayed(
                                                    Duration(seconds: 5));
                                                if (isDeleteConfirmed) {
                                                  DocumentReference reference =
                                                      Firestore.instance
                                                          .collection("users")
                                                          .document(userID)
                                                          .collection(
                                                              "classrooms")
                                                          .document(
                                                              "createdClassrooms");
                                                  DocumentSnapshot snapshotTn =
                                                      await reference
                                                          .collection(snapshot
                                                                      .data[
                                                                  "activeClassrooms"]
                                                              [i])
                                                          .document(
                                                              "classroomData")
                                                          .get();
                                                  List invitedStudents = [];
                                                  Firestore.instance
                                                      .runTransaction(
                                                          (tn) async {
                                                    var activeClassrooms = snapshot
                                                        .data[
                                                            "activeClassrooms"]
                                                        .toList();
                                                    activeClassrooms
                                                        .removeAt(i);
                                                    await tn.update(reference, {
                                                      "activeClassrooms":
                                                          activeClassrooms
                                                    });
                                                  });
                                                  invitedStudents = snapshotTn
                                                      .data["invitedStudents"]
                                                      .toList();
                                                  for (String student
                                                      in invitedStudents) {
                                                    if (student == userID) {
                                                    } else {
                                                      Firestore.instance
                                                          .runTransaction(
                                                              (stn) async {
                                                        DocumentReference
                                                            referenceS =
                                                            Firestore.instance
                                                                .collection(
                                                                    "users")
                                                                .document(
                                                                    student)
                                                                .collection(
                                                                    "requests")
                                                                .document(
                                                                    "teacherRequests");
                                                        DocumentSnapshot
                                                            documentSnapshot =
                                                            await stn.get(
                                                                referenceS);
                                                        var currentRequests =
                                                            documentSnapshot
                                                                    .data[
                                                                "recievedRequests"];
                                                        currentRequests.remove(
                                                            userID +
                                                                snapshot.data[
                                                                        "activeClassrooms"]
                                                                    [i]);
                                                        stn.update(referenceS, {
                                                          "recievedRequests":
                                                              currentRequests
                                                        });
                                                      });
                                                    }
                                                  }
                                                }
                                              },
                                              child: Container(
                                                color: Colors.transparent,
                                                width: 50,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              },
                              onTap: () => Navigator.push(
                                  context,
                                  FadeRoute(
                                      page: Classroom(
                                        isLiveEnabled: isLiveEnabled,
                                    classroomId:
                                        snapshot.data["activeClassrooms"][i],
                                    isTeacher: true,
                                    userID: userID,
                                  ))),
                              borderRadius: BorderRadius.circular(28),
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Center(
                                  child: StreamBuilder(
                                      stream: classroomStream,
                                      builder: (context, snapp) {
                                        if (snapp.connectionState ==
                                            ConnectionState.active) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Center(
                                                child: AutoSizeTextWidget(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      Provider.of<Map>(
                                                          context)["iconSize"] /
                                                      7,
                                                  text: snapp.data["title"],
                                                  width: (MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              Provider.of<Map>(
                                                                      context)[
                                                                  "width"] *
                                                              2 +
                                                          (MediaQuery.of(context)
                                                                      .size
                                                                      .width -
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      Provider.of<Map>(
                                                                              context)[
                                                                          "width"] *
                                                                      2) /
                                                              3) *
                                                      0.9,
                                                ),
                                              ),
                                              Center(
                                                child: AutoSizeTextWidget(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      Provider.of<Map>(
                                                          context)["width"] *
                                                      Provider.of<Map>(
                                                          context)["iconSize"] /
                                                      3.5,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      Provider.of<Map>(
                                                          context)["width"] *
                                                      Provider.of<Map>(
                                                          context)["iconSize"],
                                                  text: snapp.data["hour"]
                                                          .toString() +
                                                      ":" +
                                                      snapp.data["minute"],
                                                ),
                                              ),
                                              Center(
                                                child: AutoSizeTextWidget(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      Provider.of<Map>(
                                                          context)["width"] *
                                                      Provider.of<Map>(
                                                          context)["iconSize"],
                                                  text: snapp
                                                          .data["day"]
                                                          .toString() +
                                                      "." +
                                                      snapp.data["month"]
                                                          .toString() +
                                                      "." +
                                                      snapp.data["year"]
                                                          .toString(),
                                                ),
                                              )
                                            ],
                                          );
                                        } else {
                                          return LoadingAnimation();
                                        }
                                      })),
                            ),
                          ),
                        ),
                      ));
                });
          } else {
            return Container();
          }
        },
      )),
    );
  }
}

class TeacherCreateClassroom extends StatefulWidget {
  final String teacherID;
  TeacherCreateClassroom({Key key, @required this.teacherID});
  @override
  _TCCRC createState() => _TCCRC();
}

class _TCCRC extends State<TeacherCreateClassroom> {
  @override
  void initState() {
    super.initState();
    titleController.addListener(_onChange);
  }

  final keyTitle = GlobalKey<FormState>();
  String title;
  var dateDay = DateTime.now().day.toString();
  var dateMonth = DateTime.now().month.toString();
  var dateYear = DateTime.now().year.toString();
  var dateTimeHour = DateTime.now().hour.toString();
  var dateTimeMinute = DateTime.now().minute.toString();
  List studentListID = [];

  _createClassroom() async {
    if (keyTitle.currentState.validate()) {
      DocumentSnapshot snapshot1 = await Firestore.instance
          .collection("users")
          .document(widget.teacherID)
          .collection("classrooms")
          .document("createdClassrooms")
          .get();
      Firestore.instance.runTransaction((tn) async {
        CollectionReference reference = Firestore.instance
            .collection("users")
            .document(widget.teacherID)
            .collection("classrooms")
            .document("createdClassrooms")
            .collection("cm" + snapshot1.data["classroomCounter"].toString());
        DocumentReference documentReference = Firestore.instance
            .collection("users")
            .document(widget.teacherID)
            .collection("classrooms")
            .document("createdClassrooms");

        studentListID.add(widget.teacherID);

        var activeClassrooms = snapshot1.data["activeClassrooms"].toList();
        if (activeClassrooms.isEmpty) {
          activeClassrooms
              .add("cm" + snapshot1.data["classroomCounter"].toString());
        } else {
          activeClassrooms.insert(
              0, "cm" + snapshot1.data["classroomCounter"].toString());
        }

        await tn.set(reference.document("classroomData"), {
          "title": title,
          "day": dateDay,
          "month": dateMonth,
          "year": dateYear,
          "hour": dateTimeHour,
          "minute": dateTimeMinute,
          "invitedStudents": studentListID,
        });

        await tn.set(
            reference.document("tasks"), {"currentTask": null, "tasks": []});

        await tn.set(reference.document("Dashboard"), {
          "isPrivateAllowed": true,
          "isEntranceAllowed": false,
          "isStudentListenerOn": false,
          "isDictionaryAllowed": true,
          "isTaskExecutionPaused" : false,
          "isLiveEnabled" : false
        });
        studentListID.removeAt(studentListID.length - 1);
        await tn.set(reference.document("studentListener"),
            {"studentList": studentListID});
        bool c = true;
        for (String user in studentListID) {
          if (user != widget.teacherID) {
            await tn.update(reference.document("studentListener"), {user: 0});
            if (c) {
              await tn.set(reference.document("taskExecution"), {user: []});
            } else {
              await tn.update(reference.document("taskExecution"), {user: []});
            }
          }
        }

        await tn.set(reference.document("classroomChat"), {"messages": []});

        await tn
            .update(documentReference, {"activeClassrooms": activeClassrooms});

        await tn.update(documentReference,
            {"classroomCounter": snapshot1.data["classroomCounter"] + 1});
      });
      for (String user in studentListID) {
        if (user != widget.teacherID) {
          Firestore.instance.runTransaction((studentTn) async {
            DocumentReference studentRef = Firestore.instance
                .collection("users")
                .document(user)
                .collection("requests")
                .document("teacherRequests");
            DocumentSnapshot studentSnap = await studentTn.get(studentRef);
            Map existedRequests = studentSnap.data["recievedRequests"];
            existedRequests[widget.teacherID +
                "cm" +
                snapshot1.data["classroomCounter"].toString()] = {
              "teacherID": widget.teacherID,
              "classroomID":
                  "cm" + snapshot1.data["classroomCounter"].toString()
            };
            await studentTn
                .update(studentRef, {"recievedRequests": existedRequests});
          });
        }
      }
      Navigator.pop(context);
    }
  }

  TextEditingController titleController = TextEditingController();
  _onChange() {
    if (keyTitle.currentState.validate()) {
      setState(() {
        title = titleController.text;
      });
    }
  }

  _dateReturner() {
    if (dateMonth.toString().length == 1) {
      setState(() {
        dateMonth = "0" + dateMonth.toString();
      });
    }
    if (dateDay.toString().length == 1) {
      setState(() {
        dateDay = "0" + dateDay.toString();
      });
    }
    return AutoSizeTextWidget(
      text: "$dateDay.$dateMonth.$dateYear",
      width: MediaQuery.of(context).size.width *
          Provider.of<Map>(context)["width"] *
          Provider.of<Map>(context)["iconSize"] /
          1.3,
      height: MediaQuery.of(context).size.width *
          Provider.of<Map>(context)["width"] *
          Provider.of<Map>(context)["iconSize"] /
          5,
    );
  }

  _timeReturner() {
    if (dateTimeHour.toString().length == 1) {
      setState(() {
        dateTimeHour = "0" + dateTimeHour.toString();
      });
    }
    if (dateTimeMinute.toString().length == 1) {
      setState(() {
        dateTimeMinute = "0" + dateTimeMinute.toString();
      });
    }
    return AutoSizeTextWidget(
      text: "$dateTimeHour:$dateTimeMinute",
      width: MediaQuery.of(context).size.width *
          Provider.of<Map>(context)["width"] *
          Provider.of<Map>(context)["iconSize"] /
          2,
      height: MediaQuery.of(context).size.width *
          Provider.of<Map>(context)["width"] *
          Provider.of<Map>(context)["iconSize"] /
          5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["textFieldWidth"],
              child: Form(
                key: keyTitle,
                child: TextFormField(
                  maxLength: 25,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: Theme.of(context).primaryColor,
                  controller: titleController,
                  validator: (title) {
                    if (title.length == 0) {
                      return "Title of the lesson cannot be empty";
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(28 / 3.16666666666)),
                      labelText: "Title of the lesson"),
                  style: TextStyle(color: Theme.of(context).bottomAppBarColor),
                  onFieldSubmitted: (lessonTitle) {
                    if (keyTitle.currentState.validate()) {
                      setState(() {
                        title = lessonTitle;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                AutoSizeTextWidget(
                  text: "Date",
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"],
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      3,
                ),
                Tooltip(
                  message: "Choose date",
                  verticalOffset: 30,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () async {
                        var chosenDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            initialDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 30)),
                            builder: (BuildContext context, Widget picker) {
                              return Theme(
                                isMaterialAppTheme: true,
                                data: Theme.of(context).bottomAppBarColor ==
                                        Colors.white
                                    ? ThemeData.dark()
                                    : ThemeData.light(),
                                child: picker,
                              );
                            });
                        if (chosenDate != null) {
                          setState(() {
                            dateDay = chosenDate.day.toString();
                            dateMonth = chosenDate.month.toString();
                            dateYear = chosenDate.year.toString();
                          });
                        }
                      },
                      highlightColor: Colors.grey.withOpacity(0.2),
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"],
                        height: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"] /
                            2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: Theme.of(context).hintColor)),
                        child: Center(child: _dateReturner()),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                AutoSizeTextWidget(
                  text: "Time",
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"],
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      3,
                ),
                Tooltip(
                  message: "Choose time",
                  verticalOffset: 30,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () async {
                        var chosenTime = await showTimePicker(
                            initialTime: TimeOfDay.now(),
                            context: context,
                            builder: (BuildContext context, Widget picker) {
                              return Theme(
                                data: Theme.of(context).bottomAppBarColor ==
                                        Colors.white
                                    ? ThemeData.dark()
                                    : ThemeData.light(),
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: picker,
                                ),
                              );
                            });
                        if (chosenTime != null) {
                          setState(() {
                            dateTimeHour = chosenTime.hour.toString();
                            dateTimeMinute = chosenTime.minute.toString();
                          });
                        }
                      },
                      highlightColor: Colors.grey.withOpacity(0.2),
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"],
                        height: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"] /
                            2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: Theme.of(context).hintColor)),
                        child: Center(child: _timeReturner()),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Material(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                highlightColor: Colors.grey.withOpacity(0.2),
                onTap: () async {
                  var invitedStudents = await Navigator.push(
                      context,
                      FadeRoute(page: TecherStudentInviter(
                        studentListID: studentListID,
                              teacherID: widget.teacherID)));
                  setState(() {
                    studentListID = invitedStudents;
                  });
                },
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
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
                          text: "Invite",
                          width: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"] /
                              2 *
                              0.7,
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
                ),
              ),
            ),
          ),
          Center(
            child: Material(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                highlightColor: Colors.grey.withOpacity(0.2),
                onTap: _createClassroom,
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      2,
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"],
                  child: Center(
                    child: AutoSizeTextWidget(
                      text: "Create",
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          2 *
                          0.85,
                      textColor: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class TecherStudentInviter extends StatefulWidget {
  final String teacherID;
  final List studentListID;
  TecherStudentInviter({Key key, @required this.teacherID, this.studentListID});
  @override
  _TSI createState() => _TSI();
}

class _TSI extends State<TecherStudentInviter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _studentReciever());
  }

  _studentReciever() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot currentStudentsSnap = await Firestore.instance
        .collection("users")
        .document(widget.teacherID)
        .get();
    var studentList = currentStudentsSnap.data["currentStudents"].toList();
    for (String student in studentList) {
      DocumentSnapshot snap =
          await Firestore.instance.collection("users").document(student).get();
      dsList.add(snap);
    }
    setState(() {
      if (widget.studentListID == null) {}
      else {
    setState(() {
     selectedStudents = widget.studentListID; 
    });
      }
      counter = dsList.length;
      print(counter);
      isLoading = false;
    });
  }

  bool isLoading = true;
  List dsList = [];
  List selectedStudents = [];
  static int counter;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: isLoading || selectedStudents.length == 0
            ? null
            : FloatingActionButton.extended(
                backgroundColor: Theme.of(context).primaryColor,
                label: Text(
                  "Continue",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                icon: Center(
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/arrow_forward_icon.svg",
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, selectedStudents);
                }),
        backgroundColor: Theme.of(context).primaryColorDark,
        body: SafeArea(
            child: AnimatedCrossFade(
          duration: Duration(milliseconds: 100),
          crossFadeState:
              isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: LoadingAnimation(),
          secondChild: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: ListView.builder(
              itemCount: dsList.length,
              itemBuilder: (context, int i) {
                return Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          10,
                      bottom: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                2 +
                            (MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        2) /
                                3,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Image.asset(
                              dsList[i]["avatar"],
                              height: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] /
                                  2,
                              width: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] /
                                  2,
                            ),
                            AutoSizeTextWidget(
                              text: dsList[i]["name"] +
                                  " " +
                                  dsList[i]["surname"],
                              width: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] *
                                  1.5,
                              height: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] /
                                  4.3,
                            ),
                            Theme(
                              data: ThemeData(
                                  unselectedWidgetColor:
                                      Theme.of(context).primaryColor),
                              child: Checkbox(
                                checkColor: Theme.of(context).primaryColorDark,
                                value: selectedStudents.contains(dsList[i]["id"]),
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (b) {
                                  setState(() {
                                    if (selectedStudents.contains(dsList[i]["id"])) {
                                      selectedStudents.remove(dsList[i]["id"]);
                                    } else {
                                      selectedStudents.add(dsList[i]["id"]);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ),
        )));
  }
}
