import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notexactly/quickClasses.dart';
import 'package:provider/provider.dart';
// Import needed classes
import 'TeacherFindStudents.dart';
import 'main.dart';

class TeacherCurrentStudents extends StatelessWidget {
  final String userID;
  TeacherCurrentStudents({Key key, @required this.userID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Add new students",
        backgroundColor: Theme.of(context).primaryColor,
        child: Center(
          child: Container(
            child: SvgPicture.asset("assets/group_add_icon.svg",
                color: Theme.of(context).primaryColorDark),
          ),
        ),
        onPressed: () => Navigator.push(
            context,
            FadeRoute(
                page: TeacherFindStudents(
              userID: userID,
            ))),
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.data["currentStudents"].length == 0) {
              return Center(
                  child: AutoSizeTextWidget(
                text: "No added students found",
                width: MediaQuery.of(context).size.width * 0.8,
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
                                color: Theme.of(context).secondaryHeaderColor,
                                elevation: 3,
                                borderRadius: BorderRadius.circular(15),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.2))),
                                    height: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] *
                                        0.65,
                                    width: MediaQuery.of(context).size.width *
                                            Provider.of<Map>(context)["width"] *
                                            2 +
                                        (MediaQuery.of(context).size.width -
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    Provider.of<Map>(
                                                        context)["width"] *
                                                    2) /
                                            3,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          SvgPicture.asset(
                                            snap.data["avatar"],
                                            width: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] *
                                        0.65,
                                            height: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] *
                                        0.65,
                                          ),
                                          AutoSizeTextWidget(
                                            text: snap.data["name"] +
                                                " " +
                                                snap.data["surname"],
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                Provider.of<Map>(
                                                    context)["iconSize"] /
                                                3.5,
                                            width: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] * 2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return LoadingAnimation();
                        }
                      });
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
