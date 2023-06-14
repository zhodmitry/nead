import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class StudentsStatsList extends StatelessWidget {
  final String teacherID;
  StudentsStatsList({@required this.teacherID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(teacherID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.data["currentStudents"].length == 0) {
              return Center(
                  child: Text(
                "No added students found",
                style: TextStyle(
                    color: Theme.of(context).bottomAppBarColor, fontSize: 20),
              ));
            } else if (snapshot.connectionState == ConnectionState.active) {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data["currentStudents"].length,
                itemBuilder: (BuildContext context, int i) {
                  return StreamBuilder(
                      stream: Firestore.instance
                          .collection("users")
                          .document(snapshot.data["currentStudents"][i])
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.active) {
                          return Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 10),
                            child: Align(
                              alignment: Alignment.center,
                              child: Material(
                                elevation: 3,
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context).secondaryHeaderColor,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudentsStatNumbers(
                                                studentID: snap.data["id"],
                                                teacherID: teacherID,
                                              ))),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 80,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.2))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Image.asset(
                                          snap.data["avatar"],
                                          width: 65,
                                          height: 65,
                                        ),
                                        Text(
                                          snap.data["name"] +
                                              " " +
                                              snap.data["surname"],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .bottomAppBarColor,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      });
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

class StudentsStatNumbers extends StatelessWidget {
  final String studentID;
  final String teacherID;
  StudentsStatNumbers({@required this.studentID, @required this.teacherID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(studentID)
              .snapshots(),
          builder: (context, snp) {
            if (snp.connectionState == ConnectionState.active) {
              return StreamBuilder(
                  stream: Firestore.instance
                      .collection("users")
                      .document(studentID)
                      .collection("stats")
                      .document(DateTime.now().month.toString() +
                          DateTime.now().year.toString())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Center(
                              child: Image.asset(snp.data["avatar"],
                                  width: 150, height: 150)),
                          Center(
                            child: Text(
                              snp.data["name"] + " " + snp.data["surname"],
                              style: TextStyle(
                                  color: Theme.of(context).bottomAppBarColor,
                                  fontSize: 23),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width - 80,
                              child: Text(
                                "Searched and added to Favourites words for the last 30 days.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).bottomAppBarColor,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          StreamBuilder(
                              stream: Firestore.instance
                                  .collection("users")
                                  .document(teacherID)
                                  .snapshots(),
                              builder: (context, snaps) {
                                try {
                                  if (snaps.connectionState ==
                                      ConnectionState.active) {
                                    return Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "Searched:",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .bottomAppBarColor,
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  snapshot
                                                              .data[
                                                                  "searchedCounter"]
                                                              .length
                                                              .toString() ==
                                                          null
                                                      ? "0"
                                                      : snapshot
                                                          .data[
                                                              "searchedCounter"]
                                                          .length
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .bottomAppBarColor,
                                                      fontSize: 20),
                                                ),
                                                snaps.data["allowedToTrack"]
                                                        .contains(studentID)
                                                    ? IconButton(
                                                        icon: Icon(
                                                          Icons.short_text,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        onPressed: () => Navigator
                                                                .of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StudentStatsNumbersList(
                                                                              dataList: snapshot.data["searchedCounter"],
                                                                            ))),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                            Column(
                                              children: <Widget>[
                                                Text(
                                                  "Added to Favourites:",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .bottomAppBarColor,
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  snapshot.data["favsCounter"]
                                                              .length
                                                              .toString() ==
                                                          null
                                                      ? "0"
                                                      : snapshot
                                                          .data["favsCounter"]
                                                          .length
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .bottomAppBarColor,
                                                      fontSize: 21),
                                                ),
                                                snaps.data["allowedToTrack"]
                                                        .contains(studentID)
                                                    ? IconButton(
                                                        icon: Icon(
                                                          Icons.short_text,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        onPressed: () => Navigator
                                                                .of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StudentStatsNumbersList(
                                                                              dataList: snapshot.data["favsCounter"],
                                                                            ))),
                                                      )
                                                    : Container()
                                              ],
                                            )
                                          ],
                                        ),
                                        Center(
                                            child: snaps.data["allowedToTrack"]
                                                    .contains(studentID)
                                                ? Container()
                                                : IconButton(
                                                    icon: Icon(Icons.add),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    onPressed: () async {
                                                      DocumentSnapshot snappp =
                                                          await Firestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .document(
                                                                  studentID)
                                                              .collection(
                                                                  "requests")
                                                              .document(
                                                                  "statsRequests")
                                                              .get();
                                                      var lstReqs = snappp
                                                          .data["requests"]
                                                          .toList();
                                                      if (lstReqs.contains(
                                                          teacherID)) {
                                                        final snc = SnackBar(
                                                          content: Text(
                                                              "You've already sent the request."),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        );
                                                        Scaffold.of(context)
                                                            .showSnackBar(snc);
                                                      } else {
                                                        lstReqs.add(teacherID);
                                                        await Firestore.instance
                                                            .collection("users")
                                                            .document(studentID)
                                                            .collection(
                                                                "requests")
                                                            .document(
                                                                "statsRequests")
                                                            .updateData({
                                                          "requests": lstReqs
                                                        });
                                                        final sn = SnackBar(
                                                          content: Text(
                                                              "Request has been sent."),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        );
                                                        Scaffold.of(context)
                                                            .showSnackBar(sn);
                                                      }
                                                    },
                                                    tooltip:
                                                        "Ask for detailed statistics",
                                                  ))
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                } catch (e) {
                                  return Center(
                                      child: Text(
                                    "No data for the current month found.",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).bottomAppBarColor,
                                        fontSize: 17),
                                  ));
                                }
                              })
                        ],
                      );
                    } else {
                      return Container();
                    }
                  });
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

class StudentStatsNumbersList extends StatelessWidget {
  final List dataList;
  StudentStatsNumbersList({@required this.dataList});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: ListView.builder(
          // separatorBuilder: (BuildContext context, int index) =>
          // const Divider(),
          itemCount: dataList.length,
          itemBuilder: (context, i) {
            return Padding(
              padding: EdgeInsets.only(top:10.0, bottom: 10),
              child: Align(
                alignment: Alignment.center,
                            child: Material(
                              borderRadius: BorderRadius.circular(15),
                  elevation: 3,
                  color: Theme.of(context).secondaryHeaderColor,
                              child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.2))),
                    height: 50,
                    width: MediaQuery.of(context).size.width - 80,
                    child: Center(
                      child: Text(
                        dataList[i],
                        style: TextStyle(
                            color: Theme.of(context).bottomAppBarColor, fontSize: 17),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
