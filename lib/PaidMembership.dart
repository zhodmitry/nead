import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'quickClasses.dart';
import 'TeacherCurrentStudents.dart';
import 'Classroom.dart';
import 'main.dart';

class StudentDetailedStatisticsReqs extends StatelessWidget {
  final String studentID;
  StudentDetailedStatisticsReqs({@required this.studentID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(studentID)
              .collection("requests")
              .document("statsRequests")
              .snapshots(),
          builder: (context, requestSnap) {
            if (requestSnap.connectionState == ConnectionState.active &&
                requestSnap.data["requests"].isNotEmpty) {
              var keysList = requestSnap.data["requests"].toList();
              return ListView.builder(
                itemCount: keysList.length,
                itemBuilder: (context, i) {
                  return StreamBuilder(
                    stream: Firestore.instance
                        .collection("users")
                        .document(keysList[i])
                        .snapshots(),
                    builder: (context, userSnap) {
                      if (userSnap.connectionState == ConnectionState.active) {
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
                                                Provider.of<Map>(
                                                    context)["width"] *
                                                2) /
                                        3,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Image.asset(
                                      userSnap.data["avatar"],
                                      height: MediaQuery.of(context)
                                              .size
                                              .width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"] /
                                          2,
                                      width: MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"] /
                                          2,
                                    ),
                                    AutoSizeTextWidget(
                                      text: userSnap.data["name"] +
                                          " " +
                                          userSnap.data["surname"],
                                      width: MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"] *
                                          1.5,
                                      height: MediaQuery.of(context)
                                              .size
                                              .width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"] /
                                          4.3,
                                    ),
                                    Switch(
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      inactiveTrackColor: Colors.grey,
                                      value: userSnap.data["allowedToTrack"]
                                          .contains(studentID),
                                      onChanged: (b) async {
                                        if (b == false) {
                                          DocumentSnapshot snapp =
                                              await Firestore.instance
                                                  .collection("users")
                                                  .document(keysList[i])
                                                  .get();
                                          List allowedToTrackStudents = snapp
                                              .data["allowedToTrack"]
                                              .toList();
                                          allowedToTrackStudents
                                              .remove(studentID);
                                          await Firestore.instance
                                              .collection("users")
                                              .document(keysList[i])
                                              .updateData({
                                            "allowedToTrack":
                                                allowedToTrackStudents
                                          });
                                        } else if (b == true) {
                                          DocumentSnapshot snapp =
                                              await Firestore.instance
                                                  .collection("users")
                                                  .document(keysList[i])
                                                  .get();
                                          List allowedToTrackStudents = snapp
                                              .data["allowedToTrack"]
                                              .toList();
                                          allowedToTrackStudents.add(studentID);
                                          await Firestore.instance
                                              .collection("users")
                                              .document(keysList[i])
                                              .updateData({
                                            "allowedToTrack":
                                                allowedToTrackStudents
                                          });
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return LoadingAnimation();
                      }
                    },
                  );
                },
              );
            } else if (requestSnap.connectionState == ConnectionState.active &&
                requestSnap.data["requests"].isEmpty) {
              return Center(
                child: Text(
                  "No requests from teachers found",
                  style: TextStyle(
                      color: Theme.of(context).bottomAppBarColor, fontSize: 22),
                ),
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

class StudentMembership extends StatefulWidget {
  final String userID;
  StudentMembership({Key key, @required this.userID});

  @override
  State<StatefulWidget> createState() {
    return SMm();
  }
}

class SMm extends State<StudentMembership> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    setState(() {
      animationControllerPage = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
    });
  }

  AnimationController animationControllerPage;
  double animOffCredentialsX = 0;
  double animOffCredentialsY = 0;
  double animOffRequestsX = 0;
  double animOffRequestsY = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SlideTransition(
                  position: Tween<Offset>(
                          begin: Offset(0, 0),
                          end: Offset(animOffCredentialsX, animOffCredentialsY))
                      .animate(CurvedAnimation(
                          parent: animationControllerPage,
                          curve: Curves.fastOutSlowIn)),
                  child: MainDesignButton(
                    tooltipMessage: "Credentials",
                    onTap: () async {
                      setState(() {
                        animOffCredentialsX = AnimationOffset.of(context)
                            .offsets["moveCenterRightOff"];
                        animOffRequestsX =
                            AnimationOffset.of(context).offsets["moveRightOff"];
                      });
                      animationControllerPage.forward();
                      await Future.delayed(Duration(milliseconds: 180));
                      // await Navigator.push(
                      //     context,
                      //     ScaleRoute(
                      //         page: Credentials(
                      //       userID: widget.userID,
                      //     )));
                      await Navigator.push(
                          context, ScaleRoute(page: ConfirmUser()));
                      await Future.delayed(Duration(milliseconds: 180));
                      animationControllerPage.reverse();
                    },
                    child: Center(
                        child: Container(
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"],
                      height: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"],
                      child: SvgPicture.asset(
                        "assets/round-contact_mail-24px.svg",
                        color: Theme.of(context).primaryColor,
                      ),
                    )),
                  )),
              SlideTransition(
                  position: Tween<Offset>(
                          begin: Offset(0, 0),
                          end: Offset(animOffRequestsX, animOffRequestsY))
                      .animate(CurvedAnimation(
                          parent: animationControllerPage,
                          curve: Curves.fastOutSlowIn)),
                  child: MainDesignButton(
                    tooltipMessage: "Your teachers",
                    onTap: () async {
                      setState(() {
                        animOffCredentialsX = AnimationOffset.of(context)
                                .offsets["moveRightOff"] *
                            -1;
                        animOffRequestsX = AnimationOffset.of(context)
                                .offsets["moveCenterRightOff"] *
                            -1;
                      });
                      animationControllerPage.forward();
                      await Future.delayed(Duration(milliseconds: 180));
                      await Navigator.of(context).push(ScaleRoute(
                          page: StudentDetailedStatisticsReqs(
                        studentID: widget.userID,
                      )));
                      await Future.delayed(Duration(milliseconds: 180));
                      animationControllerPage.reverse();
                    },
                    child: Center(
                        child: Container(
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"],
                      height: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"],
                      child: SvgPicture.asset(
                        "assets/round-chat_bubble_outline-24px.svg",
                        color: Theme.of(context).primaryColor,
                      ),
                    )),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherMembership extends StatefulWidget {
  final String userID;
  TeacherMembership({Key key, @required this.userID});

  @override
  State<StatefulWidget> createState() {
    return TMm();
  }
}

class TMm extends State<TeacherMembership> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    setState(() {
      animationControllerPage = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
    });
  }

  AnimationController animationControllerPage;
  double animOffCredentialsX = 0;
  double animOffCredentialsY = 0;
  double animOffStudentsX = 0;
  double animOffStudentsY = 0;
  double animOffDraftsX = 0;
  double animOffDraftsY = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0),
                              end: Offset(
                                  animOffCredentialsX, animOffCredentialsY))
                          .animate(CurvedAnimation(
                              parent: animationControllerPage,
                              curve: Curves.fastOutSlowIn)),
                      child: MainDesignButton(
                        tooltipMessage: "Credentials",
                        onTap: () async {
                          setState(() {
                            animOffCredentialsX = AnimationOffset.of(context)
                                .offsets["moveCenterRightOff"];
                            animOffCredentialsY = AnimationOffset.of(context)
                                .offsets["moveCenterDownOff"];
                            animOffStudentsX = AnimationOffset.of(context)
                                .offsets["moveRightOff"];
                            animOffStudentsY = 0;
                            animOffDraftsY = AnimationOffset.of(context)
                                .offsets["moveDownOff"];
                            animOffDraftsX = 0;
                          });
                          animationControllerPage.forward();
                          await Future.delayed(Duration(milliseconds: 180));
                          // await Navigator.of(context).push(ScaleRoute(
                          //     page: Credentials(
                          //   userID: widget.userID,
                          // )));
                          await Navigator.of(context).push(ScaleRoute(
                              page: ConfirmUser(
                          )));
                          await Future.delayed(Duration(milliseconds: 180));
                          animationControllerPage.reverse();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"],
                          height: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"],
                          child: SvgPicture.asset(
                            "assets/round-contact_mail-24px.svg",
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )),
                  SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(0, 0),
                            end: Offset(animOffStudentsX, animOffStudentsY))
                        .animate(CurvedAnimation(
                            parent: animationControllerPage,
                            curve: Curves.fastOutSlowIn)),
                    child: MainDesignButton(
                        tooltipMessage: "Your students",
                        onTap: () async {
                          setState(() {
                            animOffCredentialsX = AnimationOffset.of(context)
                                    .offsets["moveRightOff"] *
                                -1;
                            animOffCredentialsY = 0;
                            animOffStudentsX = AnimationOffset.of(context)
                                    .offsets["moveCenterRightOff"] *
                                -1;
                            animOffStudentsY = AnimationOffset.of(context)
                                .offsets["moveCenterDownOff"];
                            animOffDraftsY = AnimationOffset.of(context)
                                .offsets["moveDownOff"];
                            animOffDraftsX = 0;
                          });
                          animationControllerPage.forward();
                          await Future.delayed(Duration(milliseconds: 180));
                          await Navigator.of(context).push(ScaleRoute(
                              page: TeacherCurrentStudents(
                            userID: widget.userID,
                          )));
                          await Future.delayed(Duration(milliseconds: 180));
                          animationControllerPage.reverse();
                        },
                        child: Center(
                            child: Container(
                          width: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"],
                          height: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"],
                          child: SvgPicture.asset(
                            "assets/round-group-24px.svg",
                            color: Theme.of(context).primaryColor,
                          ),
                        ))),
                  )
                ],
              ),
              SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(0, 0),
                        end: Offset(animOffDraftsX, animOffDraftsY))
                    .animate(CurvedAnimation(
                        parent: animationControllerPage,
                        curve: Curves.fastOutSlowIn)),
                child: Padding(
                    padding: EdgeInsets.only(
                        top: (MediaQuery.of(context).size.width -
                                (MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"]) *
                                    2) /
                            3),
                    child: MainDesignButton(
                      tooltipMessage: "Task drafts",
                      onTap: () async {
                        setState(() {
                          animOffCredentialsX = AnimationOffset.of(context)
                                  .offsets["moveRightOff"] *
                              -1;
                          animOffCredentialsY = 0;
                          animOffStudentsX = AnimationOffset.of(context)
                              .offsets["moveRightOff"];
                          animOffStudentsY = 0;
                          animOffDraftsY = AnimationOffset.of(context)
                                  .offsets["moveCenterDownOff"] *
                              -1;
                          animOffDraftsX = 0;
                        });
                        animationControllerPage.forward();
                        await Future.delayed(Duration(milliseconds: 180));
                        await Navigator.of(context).push(ScaleRoute(
                            page: TaskDrafts(
                          teacherID: widget.userID,
                        )));
                        await Future.delayed(Duration(milliseconds: 180));
                        animationControllerPage.reverse();
                      },
                      child: Icon(
                        Icons.cloud_queue,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Credentials extends StatefulWidget {
  final String userID;
  Credentials({@required this.userID});
  @override
  _Cds createState() => _Cds();
}

class _Cds extends State<Credentials> {
  GlobalKey<FormState> emailKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scafState = GlobalKey<ScaffoldState>();
  TextEditingController controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emailReciever());
  }

  _emailReciever() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    // DocumentSnapshot snapshot = await Firestore.instance
    //     .collection("users")
    //     .document(widget.userID)
    //     .get();
    setState(() {
      // controllerEmail.text = snapshot.data["email"];
      controllerEmail.text = user.email;
      oldEmail = user.email;
      newEmail = user.email;
    });
  }

  _emailUpdate(String newEmail) async {
    setState(() {
      invalidCredential = false;
      emailAlreadyInUse = false;
      userDisabled = false;
      userNotFound = false;
      notAllowedToChange = false;
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();
    try {
      await firebaseUser.updateEmail(newEmail);
      await Firestore.instance
          .collection("users")
          .document(widget.userID)
          .updateData({"email": newEmail});
      setState(() {
        oldEmail = newEmail;
      });
      final sn = SnackBar(
        content: Text(
          "Your email adress has been saved",
        ),
        duration: Duration(seconds: 2),
      );
      scafState.currentState.showSnackBar(sn);
    } catch (e) {
      if (e.code == "ERROR_INVALID_CREDENTIAL") {
        setState(() {
          invalidCredential = true;
        });
        emailKey.currentState.validate();
      } else if (e.code == "ERROR_EMAIL_ALREADY_IN_USE") {
        setState(() {
          emailAlreadyInUse = true;
        });
        emailKey.currentState.validate();
      } else if (e.code == "ERROR_USER_DISABLED") {
        setState(() {
          userDisabled = true;
        });
        emailKey.currentState.validate();
      } else if (e.code == "ERROR_USER_NOT_FOUND") {
        setState(() {
          userNotFound = true;
        });
        emailKey.currentState.validate();
      } else if (e.code == "ERROR_REQUIRES_RECENT_LOGIN") {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                title: Text("Cannot change email adress",
                    style:
                        TextStyle(color: Theme.of(context).bottomAppBarColor)),
                content: Text(
                  "Sign out of the account, sign in back and try again.",
                  style: TextStyle(color: Theme.of(context).bottomAppBarColor),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
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
        print("rlg");
      } else if (e.code == "ERROR_OPERATION_NOT_ALLOWED") {
        setState(() {
          notAllowedToChange = true;
        });
        emailKey.currentState.validate();
      }
    }
  }

  bool invalidCredential = false;
  bool emailAlreadyInUse = false;
  bool userDisabled = false;
  bool userNotFound = false;
  bool notAllowedToChange = false;
  String oldEmail;
  String newEmail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafState,
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: AutoSizeTextWidget(
                    text: "This information is not visible to other users.",
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"] /
                        4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 40),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["textFieldWidth"],
                      child: Form(
                        key: emailKey,
                        child: TextFormField(
                          onChanged: (data) {
                            setState(() {
                              newEmail = data;
                            });
                          },
                          cursorColor: Theme.of(context).primaryColor,
                          keyboardType: TextInputType.emailAddress,
                          validator: (email) {
                            if (invalidCredential) {
                              return "The email adress is incorrect";
                            } else if (emailAlreadyInUse) {
                              return "The email adress is already in use";
                            } else if (userDisabled) {
                              return "The user has been forbidden";
                            } else if (userNotFound) {
                              return "User has not been found";
                            } else if (notAllowedToChange) {
                              return "You're not allowed to change your email adress";
                            }
                          },
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).bottomAppBarColor),
                          controller: controllerEmail,
                          decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      28 / 3.16666666666)),
                              fillColor: Colors.transparent,
                              filled: true),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    switchInCurve: Curves.fastOutSlowIn,
                    switchOutCurve: Curves.fastOutSlowIn,
                    child: newEmail != oldEmail
                        ? Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              splashColor: Colors.grey.withOpacity(0.1),
                              onTap: () {
                                _emailUpdate(controllerEmail.text);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(28))),
                                width: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"],
                                height: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] /
                                    2,
                                child: Center(
                                  child: AutoSizeTextWidget(
                                    text: "Save",
                                    width: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] /
                                        2 *
                                        0.6,
                                    textColor:
                                        Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ))
                        : Container(),
                  ),
                ),
              ],
            ),
            Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(28)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  splashColor: Colors.grey.withOpacity(0.1),
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                Theme.of(context).secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            title: Text("Change passsword",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).bottomAppBarColor)),
                            content: Text(
                              "We will send a message with instructions to your email adress.",
                              style: TextStyle(
                                  color: Theme.of(context).bottomAppBarColor),
                            ),
                            actions: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    FirebaseAuth auth = FirebaseAuth.instance;
                                    await auth.sendPasswordResetEmail(
                                        email: newEmail);
                                    final sn = SnackBar(
                                      content: Text(
                                        "The message has been sent to your email adress. Follow the instructions to change your password.",
                                      ),
                                      duration: Duration(seconds: 7),
                                    );
                                    scafState.currentState.showSnackBar(sn);
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    width: 50,
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        "SEND",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
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
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(28))),
                    width: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"] *
                        1.7,
                    height: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"] /
                        2,
                    child: Center(
                      child: AutoSizeTextWidget(
                        text: "Change password",
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"] *
                            1.1,
                        fontWeight: FontWeight.w400,
                        textColor: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class ConfirmUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CU();
  }
}

class CU extends State<ConfirmUser> {
final keyPassword = GlobalKey<FormState>();
  String password = "";
  bool isPasswordWrong = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: AutoSizeTextWidget(
              text: "Confirm it's you",
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width / 13,
            )),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width / 20,
                  bottom: MediaQuery.of(context).size.width / 20),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["textFieldWidth"],
                child: Form(
                  key: keyPassword,
                  child: TextFormField(
                    validator: (data) {
                      if (isPasswordWrong) {
                        return "Password is incorrect";
                      }
                    } ,
                    onChanged: (data) {
                      setState(() {
                       password = data; 
                      });
                    },
                    style: TextStyle(
                        color: Theme.of(context).bottomAppBarColor,
                        fontWeight: FontWeight.w300),
                    decoration: InputDecoration(
                        labelText: "Password",
                        fillColor: Colors.transparent,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(28 / 3.16666666666))),
                    obscureText: true,
                  ),
                ),
              ),
            ),
            Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    switchInCurve: Curves.fastOutSlowIn,
                    switchOutCurve: Curves.fastOutSlowIn,
                    child: password != "" 
                        ? isLoading == false ? Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              splashColor: Colors.grey.withOpacity(0.1),
                              onTap: () async{
                                setState(() {
                                  isLoading = true;
                                 isPasswordWrong = false; 
                                });
                                keyPassword.currentState.validate();
                              FirebaseAuth auth = FirebaseAuth.instance;
                              FirebaseUser user = await auth.currentUser();
                              try {
                              await auth.signInWithEmailAndPassword(email: user.email, password: password);
                             await Navigator.of(context).push(FadeRoute(page: Credentials(userID: user.uid,)));
                             Navigator.of(context).pop();
                              }
                              catch (e) {
                                setState(() {
                                 isPasswordWrong = true;
                                 isLoading = false; 
                                });
                                keyPassword.currentState.validate();
                              }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(28))),
                                width: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"],
                                height: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] /
                                    2,
                                child: Center(
                                  child: AutoSizeTextWidget(
                                    text: "Next",
                                    width: MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"] *
                                        Provider.of<Map>(context)["iconSize"] /
                                        2 *
                                        0.6,
                                    textColor:
                                        Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            )) : LoadingAnimation(width:  MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"],
                                    height: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] /
                                    2,)
                        : Container(),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
