//import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notexactly/quickClasses.dart';
import 'package:provider/provider.dart';
// Import needed classes
import 'Classroom.dart';
import 'main.dart';

class StudentEnterClassRoomClass extends StatelessWidget {
  final String userID;
  final bool isDisabled;
  final bool isDemo;
  final width;
  StudentEnterClassRoomClass(
      {Key key,
      @required this.userID,
      this.width,
      this.isDemo,
      this.isDisabled});

  _dateReformat(bool isTime, DateTime date, bool isLater) {
    if (isLater) {
      date = DateTime.now().add(Duration(hours: 5));
    }
    if (isTime) {
      String hour = date.hour.toString();
      String minute = date.minute.toString();
      if (hour.length == 1) {
        hour = "0" + hour;
      }
      if (minute.length == 1) {
        minute = "0" + minute;
      }
      return "$hour:$minute";
    } else {
      String day = date.day.toString();
      String month = date.month.toString();
      String year = date.year.toString();
      if (day.length == 1) {
        day = "0" + day;
      }
      if (month.length == 1) {
        month = "0" + month;
      }
      return "$day.$month.$year";
    }
  }
GlobalKey<ScaffoldState> scaffKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return isDemo != null
        ? Scaffold(
          key: scaffKey,
            backgroundColor: Theme.of(context).primaryColorDark,
            body: SafeArea(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: ((width -
                                (width * Provider.of<Map>(context)["width"]) *
                                    2) /
                            3)),
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width:
                              (width * Provider.of<Map>(context)["width"]) * 2 +
                                  ((width -
                                          (width *
                                                  Provider.of<Map>(
                                                      context)["width"]) *
                                              2) /
                                      3),
                          height: width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["height"],
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  isDisabled == null ? 28 : 28 / 3),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 0.7)),
                          child: Material(
                            color: Theme.of(context).secondaryHeaderColor,
                            elevation: 5,
                            borderRadius: BorderRadius.circular(
                                isDisabled == null ? 28 : 28 / 3),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  isDisabled == null ? 28 : 28 / 3),
                              onTap: isDisabled == null ? () {} : null,
                              child: Center(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                          width: width *
                                              Provider.of<Map>(
                                                  context)["width"] *
                                              Provider.of<Map>(
                                                  context)["iconSize"],
                                          child: Hero(
                                            tag: "heroDemo_Ben",
                                            child: SvgPicture.asset(
                                                "newAvatars/080.svg"),
                                          )),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                2.5,
                                            text: "3rd lesson",
                                          ),
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                3.2,
                                            text: "Ben Candy",
                                          ),
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                4.5,
                                            text: "Starts at " +
                                                _dateReformat(true,
                                                    DateTime.now(), false),
                                          ),
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                4.5,
                                            text: _dateReformat(
                                                false, DateTime.now(), false),
                                          ),
                                        ],
                                      ),
                                      Center(
                                        child: Hero(
                                          tag: "heroDemo_closed_lock",
                                          child: Icon(
                                            Icons.lock_outline,
                                            color: Colors.grey,
                                            size: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                2,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: ((width -
                                (width * Provider.of<Map>(context)["width"]) *
                                    2) /
                            3)),
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width:
                              (width * Provider.of<Map>(context)["width"]) * 2 +
                                  ((width -
                                          (width *
                                                  Provider.of<Map>(
                                                      context)["width"]) *
                                              2) /
                                      3),
                          height: width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["height"],
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  isDisabled == null ? 28 : 28 / 3),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 0.7)),
                          child: Material(
                            color: Theme.of(context).secondaryHeaderColor,
                            elevation: 5,
                            borderRadius: BorderRadius.circular(
                                isDisabled == null ? 28 : 28 / 3),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  isDisabled == null ? 28 : 28 / 3),
                              onTap: isDisabled == null ? () {
                                scaffKey.currentState.showSnackBar(SnackBar(content: Text("This would open English Mnd classroom"),));
                              } : null,
                              child: Center(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                          width: width *
                                              Provider.of<Map>(
                                                  context)["width"] *
                                              Provider.of<Map>(
                                                  context)["iconSize"],
                                          child: Hero(
                                            tag: "heroDemo_James",
                                            child: SvgPicture.asset(
                                                "newAvatars/095.svg"),
                                          )),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                2.5,
                                            text: "English Mnd",
                                          ),
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                3.2,
                                            text: "Marry Carry",
                                          ),
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                4.5,
                                            text: "Starts at " +
                                                _dateReformat(
                                                    true, DateTime.now(), true),
                                          ),
                                          AutoSizeTextWidget(
                                            width: width *
                                                Provider.of<Map>(
                                                    context)["width"],
                                            height: width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                4.5,
                                            text: _dateReformat(
                                                false, DateTime.now(), true),
                                          ),
                                        ],
                                      ),
                                      Center(
                                        child: Hero(
                                          tag: "heroDemo_open_lock",
                                          child: Container(
                                            width: (width *
                                                    Provider.of<Map>(
                                                        context)["width"] *
                                                    Provider.of<Map>(
                                                        context)["iconSize"]) /
                                                2,
                                            height: (width *
                                                    Provider.of<Map>(
                                                        context)["width"] *
                                                    Provider.of<Map>(
                                                        context)["iconSize"]) /
                                                2,
                                            child: SvgPicture.asset(
                                              "assets/round-lock_open-24px.svg",
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).primaryColorDark,
            body: SafeArea(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("users")
                    .document(userID)
                    .collection("requests")
                    .document("teacherRequests")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active &&
                      snapshot.data["recievedRequests"].isEmpty) {
                    return Center(
                      child: AutoSizeTextWidget(
                        text: "No requests to enter a classroom found",
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"] /
                            2,
                      ),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    var requestKeysList =
                        snapshot.data["recievedRequests"].keys.toList();
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data["recievedRequests"].length,
                      itemBuilder: (BuildContext context, int i) {
                        Stream classroomStream = Firestore.instance
                            .collection("users")
                            .document(snapshot.data["recievedRequests"]
                                [requestKeysList[i]]["teacherID"])
                            .collection("classrooms")
                            .document("createdClassrooms")
                            .collection(snapshot.data["recievedRequests"]
                                [requestKeysList[i]]["classroomID"])
                            .document("classroomData")
                            .snapshots();
                        Stream teacherStream = Firestore.instance
                            .collection("users")
                            .document(snapshot.data["recievedRequests"]
                                [requestKeysList[i]]["teacherID"])
                            .snapshots();
                        return Padding(
                          padding: EdgeInsets.only(
                              top: ((MediaQuery.of(context).size.width -
                                      (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          2)) /
                                  3)/2, bottom: ((MediaQuery.of(context).size.width -
                                      (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          2)) /
                                  3)/2),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"]) *
                                      2 +
                                  ((MediaQuery.of(context).size.width -
                                          (MediaQuery.of(context).size.width *
                                                  Provider.of<Map>(
                                                      context)["width"]) *
                                              2) /
                                      3),
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
                                child: StreamBuilder(
                                    stream: Firestore.instance
                                        .collection("users")
                                        .document(snapshot
                                                .data["recievedRequests"]
                                            [requestKeysList[i]]["teacherID"])
                                        .collection("classrooms")
                                        .document("createdClassrooms")
                                        .collection(snapshot
                                                .data["recievedRequests"]
                                            [requestKeysList[i]]["classroomID"])
                                        .document("Dashboard")
                                        .snapshots(),
                                    builder: (context, snap1) {
                                      if (snap1.connectionState ==
                                          ConnectionState.active) {
                                        return InkWell(
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            onTap: () {
                                              if (snap1
                                                  .data["isEntranceAllowed"]) {
                                                Navigator.of(context)
                                                    .push(FadeRoute(
                                                        page: Classroom(
                                                  isTeacher: false,
                                                  classroomId: snapshot.data[
                                                          "recievedRequests"][
                                                      requestKeysList[
                                                          i]]["classroomID"],
                                                  userID: userID,
                                                  teacherID: snapshot.data[
                                                          "recievedRequests"][
                                                      requestKeysList[
                                                          i]]["teacherID"],
                                                )));
                                              }
                                            },
                                            highlightColor:
                                                Colors.grey.withOpacity(0.2),
                                            child: Center(
                                                child: StreamBuilder(
                                                    stream: teacherStream,
                                                    builder: (context,
                                                        snapshotTeacher) {
                                                      if (snapshotTeacher
                                                              .connectionState ==
                                                          ConnectionState
                                                              .active) {
                                                        return StreamBuilder(
                                                            stream:
                                                                classroomStream,
                                                            builder: (context,
                                                                snapshotClassroom) {
                                                              if (snapshotClassroom
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .active) {
                                                                return Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: <
                                                                      Widget>[
                                                                    SvgPicture.asset(
                                                                      snapshotTeacher
                                                                              .data[
                                                                          "avatar"],
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          Provider.of<Map>(context)[
                                                                              "width"] *
                                                                          Provider.of<Map>(
                                                                              context)["iconSize"],
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          Provider.of<Map>(context)[
                                                                              "width"] *
                                                                          Provider.of<Map>(
                                                                              context)["iconSize"],
                                                                    ),
                                                                    Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        AutoSizeTextWidget(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * Provider.of<Map>(context)["width"],
                                                                          height: MediaQuery.of(context).size.width *
                                                                              Provider.of<Map>(context)["width"] *
                                                                              Provider.of<Map>(context)["iconSize"] /
                                                                              2.5,
                                                                          text:
                                                                              snapshotClassroom.data["title"],
                                                                        ),
                                                                        AutoSizeTextWidget(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * Provider.of<Map>(context)["width"],
                                                                          height: MediaQuery.of(context).size.width *
                                                                              Provider.of<Map>(context)["width"] *
                                                                              Provider.of<Map>(context)["iconSize"] /
                                                                              3.2,
                                                                          text: snapshotTeacher.data["name"] +
                                                                              " " +
                                                                              snapshotTeacher.data["surname"],
                                                                        ),
                                                                        AutoSizeTextWidget(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * Provider.of<Map>(context)["width"],
                                                                          height: MediaQuery.of(context).size.width *
                                                                              Provider.of<Map>(context)["width"] *
                                                                              Provider.of<Map>(context)["iconSize"] /
                                                                              4.5,
                                                                          text: "Starts at " +
                                                                              snapshotClassroom.data["hour"].toString() +
                                                                              ":" +
                                                                              snapshotClassroom.data["minute"].toString(),
                                                                        ),
                                                                        AutoSizeTextWidget(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * Provider.of<Map>(context)["width"],
                                                                          height: MediaQuery.of(context).size.width *
                                                                              Provider.of<Map>(context)["width"] *
                                                                              Provider.of<Map>(context)["iconSize"] /
                                                                              4.5,
                                                                          text: snapshotClassroom.data["day"].toString() +
                                                                              "." +
                                                                              snapshotClassroom.data["month"].toString() +
                                                                              "." +
                                                                              snapshotClassroom.data["year"].toString(),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Center(
                                                                        child:
                                                                            AnimatedCrossFade(
                                                                      crossFadeState: snap1.data[
                                                                              "isEntranceAllowed"]
                                                                          ? CrossFadeState
                                                                              .showFirst
                                                                          : CrossFadeState
                                                                              .showSecond,
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              200),
                                                                      firstChild:
                                                                          Container(
                                                                        width: (MediaQuery.of(context).size.width *
                                                                                Provider.of<Map>(context)["width"] *
                                                                                Provider.of<Map>(context)["iconSize"]) /
                                                                            2,
                                                                        height:
                                                                            (MediaQuery.of(context).size.width * Provider.of<Map>(context)["width"] * Provider.of<Map>(context)["iconSize"]) /
                                                                                2,
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          "assets/round-lock_open-24px.svg",
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                      secondChild:
                                                                          Icon(
                                                                        Icons
                                                                            .lock_outline,
                                                                        color: Colors
                                                                            .grey,
                                                                        size: (MediaQuery.of(context).size.width *
                                                                                Provider.of<Map>(context)["width"] *
                                                                                Provider.of<Map>(context)["iconSize"]) /
                                                                            2,
                                                                      ),
                                                                    ))
                                                                  ],
                                                                );
                                                              } else {
                                                                return LoadingAnimation();
                                                              }
                                                            });
                                                      } else {
                                                        return LoadingAnimation();
                                                      }
                                                    })));
                                      } else {
                                        return LoadingAnimation();
                                      }
                                    }),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return LoadingAnimation();
                  }
                },
              ),
            ),
          );
  }
}
