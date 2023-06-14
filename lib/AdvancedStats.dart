import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'ParticularStudentStats.dart';
import 'main.dart';

class AdvancedStats extends StatefulWidget {
  final String teacherID;
  AdvancedStats({@required this.teacherID});

  @override
  State<StatefulWidget> createState() {
    return _AdvStats();
  }
}

class _AdvStats extends State<AdvancedStats> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    setState(() {
      animationControllerPage = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
    });
  }

  AnimationController animationControllerPage;
  double animOffStStatsX = 0;
  double animOffStStatsY = 0;
  double animOffPersonalStatsX = 0;
  double animOffPersonalStatsY = 0;
  double animOffClassroomStatsX = 0;
  double animOffClassroomStatsY = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  bottom: (MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"]) *
                              2) /
                      3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(0, 0),
                            end: Offset(animOffStStatsX, animOffStStatsY))
                        .animate(CurvedAnimation(
                            parent: animationControllerPage,
                            curve: Curves.fastOutSlowIn)),
                    child: Tooltip(
                      verticalOffset: 110,
                      message: "Student's statistics",
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 0.7),
                            borderRadius:
                                BorderRadius.all(Radius.circular(28))),
                        height: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["height"],
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"],
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(28),
                          color: Theme.of(context).secondaryHeaderColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () async {
                              setState(() {
                                animOffStStatsX = AnimationOffset.of(context)
                                    .offsets["moveCenterRightOff"];
                                animOffStStatsY = AnimationOffset.of(context)
                                    .offsets["moveCenterDownOff"];
                                animOffPersonalStatsX =
                                    AnimationOffset.of(context)
                                        .offsets["moveRightOff"];
                                animOffPersonalStatsY = 0;
                                animOffClassroomStatsX = 0;
                                animOffClassroomStatsY =
                                    AnimationOffset.of(context)
                                        .offsets["moveDownOff"];
                              });
                              animationControllerPage.forward();
                              await Future.delayed(Duration(milliseconds: 180));
                              await Navigator.of(context).push(ScaleRoute(
                                  page: StudentsStatsList(
                                teacherID: widget.teacherID,
                              )));
                              await Future.delayed(Duration(milliseconds: 180));
                              animationControllerPage.reverse();
                            },
                            highlightColor: Colors.grey.withOpacity(0.2),
                            child: Center(
                                child: Container(
                              width: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                              height: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                              child: SvgPicture.asset(
                                "assets/round-supervisor_account-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(0, 0),
                            end: Offset(
                                animOffPersonalStatsX, animOffPersonalStatsY))
                        .animate(CurvedAnimation(
                            parent: animationControllerPage,
                            curve: Curves.fastOutSlowIn)),
                    child: Tooltip(
                      verticalOffset: 110,
                      message: "Your statistics",
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 0.7),
                            borderRadius:
                                BorderRadius.all(Radius.circular(28))),
                        height: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["height"],
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"],
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(28),
                          color: Theme.of(context).secondaryHeaderColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            // onTap: () => Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => TeacherCurrentClassrooms(
                            //               userID: widget.userID,
                            //             ))),
                            highlightColor: Colors.grey.withOpacity(0.2),
                            child: Center(
                                child: Container(
                              width: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                              height: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                              child: SvgPicture.asset(
                                "assets/round-person_outline-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                      begin: Offset(0, 0),
                      end: Offset(
                          animOffClassroomStatsX, animOffClassroomStatsY))
                  .animate(CurvedAnimation(
                      parent: animationControllerPage,
                      curve: Curves.fastOutSlowIn)),
              child: Tooltip(
                verticalOffset: 110,
                message: "Student's classrooms statistics",
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 0.7),
                      borderRadius: BorderRadius.all(Radius.circular(28))),
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["height"],
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"],
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(28),
                    color: Theme.of(context).secondaryHeaderColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      // onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => TeacherCurrentClassrooms(
                      //               userID: widget.userID,
                      //             ))),
                      highlightColor: Colors.grey.withOpacity(0.2),
                      child: Center(
                                child: Container(
                              width: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                              height: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                              child: SvgPicture.asset(
                                "assets/round-assessment-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            )),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
