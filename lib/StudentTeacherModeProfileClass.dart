//import 'package:firebase_performance/firebase_performance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:math';
import 'TeacherCurrentAndCreateNewClassrooms.dart';
import 'StudentTeacherModeUserInformationClass.dart';
import 'StudentEnterClassroom.dart';
import 'PaidMembership.dart';
import 'AdvancedStats.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentTeacherModeProfileClass extends StatefulWidget {
  final bool isLiveEnabled;
  final bool isDemo;
  final bool isTeacher;
  final String userID;
  final String avatar;
  final width;
  final isDisabled;
  StudentTeacherModeProfileClass(
      {Key key,
      @required this.isTeacher,
      @required this.userID,
      this.avatar,
      @required this.isDemo,
      @required this.width,
      this.isDisabled,
      this.isLiveEnabled});
  @override
  _STMPC createState() => _STMPC();
}

class _STMPC extends State<StudentTeacherModeProfileClass>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _timeChecker();
    setState(() {
      animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
    });
    if (widget.avatar == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _avatarGetter());
    } else {
      setState(() {
        avt = widget.avatar;
      });
    }
  }

  _createOrEnterClassroom() {
    if (widget.isTeacher) {
      return SlideTransition(
        position: Tween<Offset>(
                begin: Offset(0, 0),
                end: Offset(animOffClassroomX, animOffClassroomY))
            .animate(CurvedAnimation(
                parent: animationController, curve: Curves.fastOutSlowIn)),
        child: Tooltip(
          verticalOffset: 110,
          message: "Created Classrooms",
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.5), width: 0.7),
                borderRadius: BorderRadius.circular(
                    widget.isDisabled == null ? 28 : 28 / 3)),
            height: widget.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["height"],
            width: widget.width * Provider.of<Map>(context)["width"],
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(
                  widget.isDisabled == null ? 28 : 28 / 3),
              color: Theme.of(context).secondaryHeaderColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                    widget.isDisabled == null ? 28 : 28 / 3),
                onTap: widget.isDisabled == null
                    ? () async {
                        if (widget.isDemo == false) {
                          if (isTimeCorrect != null) {
                            if (isTimeCorrect) {
                            setState(() {
                              animOffClassroomX = AnimationOffset.of(context)
                                  .offsets["moveCenterRightOff"];
                              animOffClassroomY = AnimationOffset.of(context)
                                      .offsets["moveCenterDownOff"] *
                                  -1;
                              animOffMembershipX = AnimationOffset.of(context)
                                  .offsets["moveRightOff"];
                              animOffMembershipY = 0;
                              animOffStatsX = 0;
                              animOffStatsY = AnimationOffset.of(context)
                                  .offsets["moveDownOff"];
                              animOffUserInfoX = 0;
                              animOffUserInfoY = AnimationOffset.of(context)
                                      .offsets["moveDownOff"] *
                                  -1;
                            });
                            animationController.forward();
                            await Future.delayed(Duration(milliseconds: 150));
                            await Navigator.push(
                                context,
                                ScaleRoute(
                                    page: TeacherCurrentClassrooms(
                                  isLiveEnabled: widget.isLiveEnabled,
                                  userID: widget.userID,
                                )));
                            await Future.delayed(Duration(milliseconds: 150));
                            animationController.reverse();
                          } else {
                            _incorrectTimeDialog();
                          }
                          }
                        } else {
                          scaffKey.currentState.showSnackBar(SnackBar(
                              content:
                                  Text("This would open Current classrooms")));
                        }
                      }
                    : null,
                highlightColor: Colors.grey.withOpacity(0.2),
                child: Center(
                    child: Hero(
                  tag: "demoHero_book",
                  child: Container(
                      width: widget.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"],
                      height: widget.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"],
                      child: SvgPicture.asset(
                        "assets/outline-book-24px.svg",
                        color: Theme.of(context).primaryColor,
                      )),
                )),
              ),
            ),
          ),
        ),
      );
    } else if (widget.isTeacher == false) {
      return SlideTransition(
        position: Tween<Offset>(
                begin: Offset(0, 0),
                end: Offset(animOffClassroomX, animOffClassroomY))
            .animate(CurvedAnimation(
                parent: animationController, curve: Curves.fastOutSlowIn)),
        child: Tooltip(
          verticalOffset: 110,
          message: "Enter a classroom",
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.5), width: 0.7),
                borderRadius: BorderRadius.circular(
                    widget.isDisabled == null ? 28 : 28 / 3)),
            height: widget.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["height"],
            width: widget.width * Provider.of<Map>(context)["width"],
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(
                  widget.isDisabled == null ? 28 : 28 / 3),
              color: Theme.of(context).secondaryHeaderColor,
              child: InkWell(
                  borderRadius: BorderRadius.circular(
                      widget.isDisabled == null ? 28 : 28 / 3),
                  onTap: widget.isDisabled == null
                      ? () async {
                          if (widget.isDemo == false) {
                            if (isTimeCorrect != null) {
                              if (isTimeCorrect) {
                              setState(() {
                                animOffClassroomX = AnimationOffset.of(context)
                                    .offsets["moveCenterRightOff"];
                                animOffClassroomY = AnimationOffset.of(context)
                                        .offsets["moveCenterDownOff"] *
                                    -1;
                                animOffMembershipX = AnimationOffset.of(context)
                                    .offsets["moveRightOff"];
                                animOffMembershipY = 0;
                                animOffStatsX = 0;
                                animOffStatsY = AnimationOffset.of(context)
                                    .offsets["moveDownOff"];
                                animOffUserInfoX = 0;
                                animOffUserInfoY = AnimationOffset.of(context)
                                        .offsets["moveDownOff"] *
                                    -1;
                              });
                              animationController.forward();
                              await Future.delayed(Duration(milliseconds: 150));
                              await Navigator.push(
                                  context,
                                  ScaleRoute(
                                      page: StudentEnterClassRoomClass(
                                    userID: widget.userID,
                                  )));
                              await Future.delayed(Duration(milliseconds: 150));
                              animationController.reverse();
                            } else {
                              _incorrectTimeDialog();
                            }
                            }
                          } else {
                            scaffKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "This would open Current classrooms")));
                          }
                        }
                      : null,
                  highlightColor: Colors.grey.withOpacity(0.2),
                  child: Center(
                      child: Hero(
                    tag: "demoHero_book",
                    child: Container(
                        width: widget.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"],
                        height: widget.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"],
                        child: SvgPicture.asset(
                          "assets/outline-book-24px.svg",
                          color: Theme.of(context).primaryColor,
                        )),
                  ))),
            ),
          ),
        ),
      );
    }
  }

  _timeChecker() async {
    DateTime before = DateTime.now().toUtc();
    var data = await http.get("http://worldtimeapi.org/api/timezone/Etc/UTC");
    Duration reqTime = before.difference(DateTime.now().toUtc());
    Duration after =
        Duration(milliseconds: ((reqTime.inMilliseconds) / 2).toInt());
    var js = json.decode(data.body);
    String deviceUTC = before.toIso8601String().substring(0, 16);
    String serverUTC =
        DateTime.tryParse(js["utc_datetime"]).subtract(after).toIso8601String();
    String serverString = (serverUTC.substring(0, 16));
    if (serverString != deviceUTC) {
      int diff = DateTime.tryParse(serverUTC).difference(before).inSeconds;
      print(diff);
      if (diff > 10 || diff < -1) {
        setState(() {
          isTimeCorrect = false;
        });
      }
      else {
        setState(() {
         isTimeCorrect = true; 
        });
      }
    }
    else {
      setState(() {
         isTimeCorrect = true; 
        });
    }
  }

  bool isTimeCorrect;

  _incorrectTimeDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Device time is incorrect",
                style: TextStyle(color: Theme.of(context).bottomAppBarColor)),
            content: Text("Use network-provided time to access classrooms", style: TextStyle(color: Theme.of(context).bottomAppBarColor, fontWeight: FontWeight.w300),),
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
                        "OK",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  _avatarGetter() async {
    if (widget.isDemo == false) {
      SharedPreferences data = await SharedPreferences.getInstance();
      String checker = data.getString("avatar_image");
      if (checker == null) {
        FirebaseAuth auth = FirebaseAuth.instance;
        FirebaseUser user = await auth.currentUser();
        DocumentSnapshot snapshot = await Firestore.instance
            .collection("users")
            .document(user.uid)
            .get();
        if (snapshot.data["avatar"] != "avatars_images/avatar-071.png") {
          if (mounted) {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setString("avatar_image", snapshot.data["avatar"]);
            setState(() {
              avt = snapshot.data["avatar"];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            avt = "avatars_images/avatar-071.png";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          avt = checker;
          isLoading = false;
        });
      }
    }
  }

  GlobalKey<ScaffoldState> scaffKey = GlobalKey<ScaffoldState>();
  AnimationController animationController;
  double animOffUserInfoX = 0;
  double animOffUserInfoY = 0;
  double animOffMembershipX = 0;
  double animOffMembershipY = 0;
  double animOffStatsX = 0;
  double animOffStatsY = 0;
  double animOffClassroomX = 0;
  double animOffClassroomY = 0;
  bool isLoading = false;
  var avt;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(avt);
      },
      child: Scaffold(
        key: scaffKey,
        backgroundColor: Theme.of(context).primaryColorDark,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                        bottom: (widget.width -
                            (widget.width *
                                Provider.of<Map>(context)["width"] *
                                2))) /
                    3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0),
                              end: Offset(animOffUserInfoX, animOffUserInfoY))
                          .animate(CurvedAnimation(
                              parent: animationController,
                              curve: Curves.fastOutSlowIn)),
                      child: Tooltip(
                        verticalOffset: 110,
                        message: "Your account",
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 0.7),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  widget.isDisabled == null ? 28 : 28 / 3))),
                          height: widget.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["height"],
                          width:
                              widget.width * Provider.of<Map>(context)["width"],
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(
                                widget.isDisabled == null ? 28 : 28 / 3),
                            color: Theme.of(context).secondaryHeaderColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  widget.isDisabled == null ? 28 : 28 / 3),
                              onTap: widget.isDisabled == null
                                  ? () async {
                                      if (widget.isDemo == false) {
                                        setState(() {
                                          animOffClassroomX = 0;
                                          animOffClassroomY =
                                              AnimationOffset.of(context)
                                                  .offsets["moveDownOff"];
                                          animOffMembershipX = 0;
                                          animOffMembershipY =
                                              AnimationOffset.of(context)
                                                      .offsets["moveDownOff"] *
                                                  -1;
                                          animOffStatsX =
                                              AnimationOffset.of(context)
                                                  .offsets["moveRightOff"];
                                          animOffStatsY = 0;
                                          animOffUserInfoX = AnimationOffset.of(
                                                  context)
                                              .offsets["moveCenterRightOff"];
                                          animOffUserInfoY =
                                              AnimationOffset.of(context)
                                                  .offsets["moveCenterDownOff"];
                                        });
                                        animationController.forward();
                                        await Future.delayed(
                                            Duration(milliseconds: 150));
                                        var data = await Navigator.push(
                                            context,
                                            ScaleRoute(
                                                page: UserInformation(
                                              isTeacher: widget.isTeacher,
                                              avatar: avt,
                                              userID: widget.userID,
                                            )));
                                        setState(() {
                                          avt = data;
                                        });
                                        await Future.delayed(
                                            Duration(milliseconds: 150));
                                        animationController.reverse();
                                      } else {
                                        scaffKey.currentState.showSnackBar(SnackBar(
                                            content: Text(
                                                "This would open Your account")));
                                      }
                                    }
                                  : null,
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Hero(
                                tag: avt,
                                child: Container(
                                    width: widget.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] *
                                        1.5,
                                    height: widget.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] *
                                        1.5,
                                    child: SvgPicture.asset(avt)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0),
                              end: Offset(
                                  animOffMembershipX, animOffMembershipY))
                          .animate(CurvedAnimation(
                              parent: animationController,
                              curve: Curves.fastOutSlowIn)),
                      child: Tooltip(
                        verticalOffset: 110,
                        message: "Paid membership",
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 0.7),
                              borderRadius: BorderRadius.circular(
                                  widget.isDisabled == null ? 28 : 28 / 3)),
                          height: widget.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["height"],
                          width:
                              widget.width * Provider.of<Map>(context)["width"],
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(
                                widget.isDisabled == null ? 28 : 28 / 3),
                            color: Theme.of(context).secondaryHeaderColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  widget.isDisabled == null ? 28 : 28 / 3),
                              onTap: widget.isDisabled == null
                                  ? () async {
                                      if (widget.isDemo == false) {
                                        setState(() {
                                          animOffClassroomX =
                                              AnimationOffset.of(context)
                                                      .offsets["moveRightOff"] *
                                                  -1;
                                          animOffClassroomY = 0;
                                          animOffMembershipX =
                                              AnimationOffset.of(context)
                                                          .offsets[
                                                      "moveCenterRightOff"] *
                                                  -1;
                                          animOffMembershipY =
                                              AnimationOffset.of(context)
                                                  .offsets["moveCenterDownOff"];
                                          animOffStatsX = 0;
                                          animOffStatsY =
                                              AnimationOffset.of(context)
                                                  .offsets["moveDownOff"];
                                          animOffUserInfoX = 0;
                                          animOffUserInfoY =
                                              AnimationOffset.of(context)
                                                      .offsets["moveDownOff"] *
                                                  -1;
                                        });
                                        animationController.forward();
                                        await Future.delayed(
                                            Duration(milliseconds: 150));
                                        widget.isTeacher
                                            ? await Navigator.push(
                                                context,
                                                ScaleRoute(
                                                    page: AnimationOffset(
                                                  offsets: AnimationOffset.of(
                                                          context)
                                                      .offsets,
                                                  child: TeacherMembership(
                                                    userID: widget.userID,
                                                  ),
                                                )))
                                            : await Navigator.push(
                                                context,
                                                ScaleRoute(
                                                    page: AnimationOffset(
                                                  offsets: AnimationOffset.of(
                                                          context)
                                                      .offsets,
                                                  child: StudentMembership(
                                                    userID: widget.userID,
                                                  ),
                                                )));
                                        await Future.delayed(
                                            Duration(milliseconds: 150));
                                        animationController.reverse();
                                      } else {
                                        scaffKey.currentState.showSnackBar(SnackBar(
                                            content: Text(
                                                "This would open Paid membership")));
                                      }
                                    }
                                  : null,
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Center(
                                child: Hero(
                                  tag: "demoHero_balance",
                                  child: Container(
                                    width: widget.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                                    height: widget.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                                    child: SvgPicture.asset(
                                      "assets/round-account_balance_wallet-24px.svg",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _createOrEnterClassroom(),
                  SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(0, 0),
                            end: Offset(animOffStatsX, animOffStatsY))
                        .animate(CurvedAnimation(
                            parent: animationController,
                            curve: Curves.fastOutSlowIn)),
                    child: Tooltip(
                      verticalOffset: 110,
                      message: "Classroom statistics",
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 0.7),
                            borderRadius: BorderRadius.circular(
                                widget.isDisabled == null ? 28 : 28 / 3)),
                        height: widget.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["height"],
                        width:
                            widget.width * Provider.of<Map>(context)["width"],
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(
                              widget.isDisabled == null ? 28 : 28 / 3),
                          color: Theme.of(context).secondaryHeaderColor,
                          child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  widget.isDisabled == null ? 28 : 28 / 3),
                              onTap: widget.isDisabled == null
                                  ? () async {
                                      if (widget.isDemo == false) {
                                        setState(() {
                                          animOffClassroomX = 0;
                                          animOffClassroomY =
                                              AnimationOffset.of(context)
                                                  .offsets["moveDownOff"];
                                          animOffMembershipX = 0;
                                          animOffMembershipY =
                                              AnimationOffset.of(context)
                                                      .offsets["moveDownOff"] *
                                                  -1;
                                          animOffStatsX =
                                              AnimationOffset.of(context)
                                                          .offsets[
                                                      "moveCenterRightOff"] *
                                                  -1;
                                          animOffStatsY =
                                              AnimationOffset.of(context)
                                                          .offsets[
                                                      "moveCenterDownOff"] *
                                                  -1;
                                          animOffUserInfoX =
                                              AnimationOffset.of(context)
                                                      .offsets["moveRightOff"] *
                                                  -1;
                                          animOffUserInfoY = 0;
                                        });
                                        animationController.forward();
                                        await Future.delayed(
                                            Duration(milliseconds: 150));
                                        await Navigator.push(
                                            context,
                                            ScaleRoute(
                                                page: AnimationOffset(
                                              offsets:
                                                  AnimationOffset.of(context)
                                                      .offsets,
                                              child: AdvancedStats(
                                                teacherID: widget.userID,
                                              ),
                                            )));
                                        await Future.delayed(
                                            Duration(milliseconds: 150));
                                        animationController.reverse();
                                      } else {
                                        scaffKey.currentState.showSnackBar(SnackBar(
                                            content: Text(
                                                "This would open Classroom statistics")));
                                      }
                                    }
                                  : null,
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Center(
                                  child: Hero(
                                tag: "demoHero_trending",
                                child: Container(
                                    width: widget.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                                    height: widget.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"],
                                    child: SvgPicture.asset(
                                      "assets/round-trending_up-24px.svg",
                                      color: Theme.of(context).primaryColor,
                                    )),
                              ))),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}