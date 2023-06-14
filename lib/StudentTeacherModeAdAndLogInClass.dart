import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notexactly/StudentEnterClassroom.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'quickClasses.dart';
import 'StudentTeacherModeProfileClass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';

class StudentTeacherModeAdAndLogInClass extends StatefulWidget {
  @override
  _STM createState() => _STM();
}

class _STM extends State<StudentTeacherModeAdAndLogInClass> {
  void _firebaseAccount(bool isToLogIn) async {
    setState(() {
      validatorForEmail = false;
      disabledUserValidator = false;
      validatorWrongPassword = false;
      undefinedError = false;
      emailIsInUse = false;
    });
    keyEmail.currentState.validate();
    keyPassword.currentState.validate();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    if (isToLogIn) {
      try {
        setState(() {
          isLoading = true;
        });
        AuthResult user = await firebaseAuth.signInWithEmailAndPassword(
            email: textEditingControllerEmail.text,
            password: textEditingControllerPassword.text);
        DocumentReference documentReference =
            Firestore.instance.collection("users").document(user.user.uid);
        DocumentSnapshot snapshot = await documentReference.get();
        await firebaseAnalytics.logLogin();
        AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
        String notificationToken = await FirebaseMessaging().getToken();
        String brand = deviceInfo.brand.substring(0, 1).toUpperCase() +
            deviceInfo.brand.substring(1, deviceInfo.brand.length);
        await documentReference
            .collection("devices")
            .document(notificationToken)
            .setData({"manufacturer": brand, "model": deviceInfo.model});
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context,
            FadeRoute(
                page: AnimationOffset(
              offsets: AnimationOffset.of(context).offsets,
              child: StudentTeacherModeProfileClass(
                width: MediaQuery.of(context).size.width,
                isDemo: false,
                isTeacher: snapshot.data["isTeacher"],
                userID: user.user.uid,
              ),
            ))).whenComplete(() {
          Navigator.pop(context);
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (e.code == "ERROR_USER_DISABLED") {
          setState(() {
            disabledUserValidator = true;
          });
          keyEmail.currentState.validate();
          keyPassword.currentState.validate();
        } else if (e.code == "ERROR_INVALID_EMAIL") {
          setState(() {
            validatorForEmail = true;
          });
          keyEmail.currentState.validate();
          keyPassword.currentState.validate();
        } else if (e.code == "ERROR_WRONG_PASSWORD" ||
            e.code == "ERROR_USER_NOT_FOUND") {
          setState(() {
            validatorWrongPassword = true;
          });
          keyPassword.currentState.validate();
          keyEmail.currentState.validate();
        } else {
          setState(() {
            undefinedError = true;
          });
          keyEmail.currentState.validate();
          keyPassword.currentState.validate();
        }
      }
    } else {
      bool isTeacher = false;
      try {
        AuthResult user = await firebaseAuth.createUserWithEmailAndPassword(
            email: textEditingControllerEmail.text,
            password: textEditingControllerPassword.text);
        if (isTeacher) {
          await Firestore.instance
              .collection("users")
              .document(user.user.uid)
              .setData({
            "email": user.user.email,
            "name": user.user.uid.substring(0, 5),
            "surname": "",
            "id": user.user.uid,
            "avatar": "newAvatars/087.svg",
            "isTeacher": true,
            "currentStudents": [],
            "allowedToTrack": []
          });
          await Firestore.instance
              .collection("users")
              .document(user.user.uid)
              .collection("classrooms")
              .document("createdClassrooms")
              .setData({"activeClassrooms": [], "classroomCounter": 0});
        } else {
          await Firestore.instance
              .collection("users")
              .document(user.user.uid)
              .setData({
            "email": user.user.email,
            "name": user.user.uid.substring(0, 5),
            "surname": "",
            "id": user.user.uid,
            "avatar": "avatars_images/avatar-071.png",
            "isTeacher": false
          });
          await Firestore.instance
              .collection("users")
              .document(user.user.uid)
              .collection("requests")
              .document("teacherRequests")
              .setData({"recievedRequests": {}});
          await Firestore.instance
              .collection("users")
              .document(user.user.uid)
              .collection("stats")
              .document(DateTime.now().month.toString() +
                  DateTime.now().year.toString())
              .setData({"favCounter": [], "searchCounter": []});
          await Firestore.instance
              .collection("users")
              .document(user.user.uid)
              .collection("requests")
              .document("statsRequests")
              .setData({"requests": []});
          setState(() {
            isLoading = true;
          });
          await Future.delayed(Duration(seconds: 1, milliseconds: 500));
          setState(() {
            isLoading = false;
          });
        }
        Navigator.push(
            context,
            FadeRoute(
                page: AnimationOffset(
              offsets: AnimationOffset.of(context).offsets,
              child: StudentTeacherModeProfileClass(
                width: MediaQuery.of(context).size.width,
                isDemo: false,
                userID: user.user.uid,
                isTeacher: false,
              ),
            ))).whenComplete(() {
          Navigator.pop(context);
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (e.code == "ERROR_INVALID_EMAIL") {
          setState(() {
            validatorForEmail = true;
          });
          keyEmail.currentState.validate();
          keyPassword.currentState.validate();
        } else if (e.code == "ERROR_EMAIL_ALREADY_IN_USE") {
          setState(() {
            emailIsInUse = true;
          });
          keyEmail.currentState.validate();
          keyPassword.currentState.validate();
        } else {
          setState(() {
            undefinedError = true;
          });
          keyEmail.currentState.validate();
          keyPassword.currentState.validate();
        }
      }
    }
  }

  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodePassword = FocusNode();
  bool validatorForEmail = false;
  bool disabledUserValidator = false;
  bool validatorWrongPassword = false;
  bool undefinedError = false;
  bool emailIsInUse = false;
  TextEditingController textEditingControllerEmail = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();
  final keyPassword = GlobalKey<FormState>();
  final keyEmail = GlobalKey<FormState>();
  bool value = false;
  bool isLoading = false;
  FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics();
  _loader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["textFieldWidth"],
            child: Form(
              key: keyEmail,
              child: TextFormField(
                cursorColor: Theme.of(context).primaryColor,
                validator: (email) {
                  if (validatorForEmail) {
                    return "Entered email is incorrect.";
                  } else if (disabledUserValidator) {
                    return "The user has been forbidden";
                  } else if (validatorWrongPassword) {
                    return "";
                  } else if (undefinedError) {
                    return "";
                  } else if (emailIsInUse) {
                    return "Entered email is already in use.";
                  } else {}
                },
                controller: textEditingControllerEmail,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                focusNode: focusNodeEmail,
                onFieldSubmitted: (email) {
                  setState(() {
                    validatorForEmail = false;
                  });
                  keyEmail.currentState.validate();
                  focusNodeEmail.unfocus();
                  FocusScope.of(context).requestFocus(focusNodePassword);
                },
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).bottomAppBarColor),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(28 / 3.16666666666)),
                    labelText: "Email"),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 20),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["textFieldWidth"],
              child: Form(
                key: keyPassword,
                child: TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  validator: (password) {
                    if (password.length < 8) {
                      return "Password must contain at least 8 characters.";
                    } else if (validatorWrongPassword) {
                      return "Entered email and password do not match.";
                    } else if (undefinedError) {
                      return "Email or password are incorrect.";
                    } else {}
                  },
                  controller: textEditingControllerPassword,
                  obscureText: showPassword ? false : true,
                  autocorrect: false,
                  focusNode: focusNodePassword,
                  onFieldSubmitted: (password) {
                    if (keyPassword.currentState.validate()) {
                      focusNodePassword.unfocus();
                    }
                  },
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).bottomAppBarColor),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(28 / 3.16666666666)),
                      labelText: "Password"),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Theme(
              data: ThemeData(
                  unselectedWidgetColor: Theme.of(context).primaryColor),
              child: Checkbox(
                checkColor: Theme.of(context).primaryColorDark,
                value: showPassword,
                tristate: false,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (b) {
                  setState(() {
                    showPassword = b;
                  });
                },
              ),
            ),
            AutoSizeTextWidget(
              width: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"],
              text: "Show password",
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"] /
                  5,
              bottom: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"] /
                  5),
          child: AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: isLoading
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: LoadingAnimation(
              height: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"] /
                  2,
            ),
            secondChild: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Material(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        // _firebaseAccount(false);
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
                          text: "Sign up",
                          width: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"] /
                              2.1,
                          fontWeight: FontWeight.w400,
                          textColor: Theme.of(context).primaryColorDark,
                        )),
                      ),
                    )),
                Material(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        _firebaseAccount(true);
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
                          text: "Log in",
                          width: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"] *
                              0.4,
                          fontWeight: FontWeight.w400,
                          textColor: Theme.of(context).primaryColorDark,
                        )),
                      ),
                    )),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"] /
                  5),
          child: Center(
              child: GestureDetector(
            onTap: () => Navigator.of(context).push(FadeRoute(
                page: PasswordRecovery(
              email: textEditingControllerEmail.text,
            ))),
            child: AutoSizeTextWidget(
              text: "Forgot password?",
              width: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"] *
                  1.2,
              fontWeight: FontWeight.w500,
            ),
          )),
        )
      ],
    );
  }

  @override
  void dispose() {
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    super.dispose();
  }

  GlobalKey<ScaffoldState> gk = GlobalKey<ScaffoldState>();
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: gk,
        backgroundColor: Theme.of(context).primaryColorDark,
        body: SafeArea(
            child: PageView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Hero(
                      tag: "supervised_user_icon",
                      child: Icon(
                        Icons.supervised_user_circle,
                        size: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"],
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["textFieldWidth"],
                  child: Text(
                    "StudentTeacherMode is a new way of getting educated and teaching." +
                        " Using StudentTeacherMode you can: create classrooms for your students," +
                        " use advanced statistics tracking and more.",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).bottomAppBarColor,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onTapUp: (j) => Navigator.of(context).push(FadeRoute(
                          page: StudentTeacherModeProfileClass(
                        avatar: "newAvatars/042.svg",
                        width: MediaQuery.of(context).size.width,
                        isDemo: true,
                        isTeacher: true,
                        userID: "0",
                      ))),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.height / 3,
                        child: StudentTeacherModeProfileClass(
                          avatar: "newAvatars/042.svg",
                          width: MediaQuery.of(context).size.width / 3,
                          isDemo: true,
                          isTeacher: true,
                          userID: "0",
                          isDisabled: true,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: MediaQuery.of(context).size.height / 3,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onTapUp: (j) => Navigator.of(context).push(FadeRoute(
                          page: StudentEnterClassRoomClass(
                        width: MediaQuery.of(context).size.width,
                        isDemo: true,
                        userID: "0",
                      ))),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.height / 3,
                        child: StudentEnterClassRoomClass(
                          width: MediaQuery.of(context).size.width / 3,
                          isDemo: true,
                          userID: "0",
                          isDisabled: true,
                        ),
                      ),
                    )
                    //3rd demo?
                  ],
                ),
              ],
            ),
            _loader()
          ],
        )));
  }
}

class PasswordRecovery extends StatefulWidget {
  final String email;
  PasswordRecovery({@required this.email});

  @override
  _PR createState() => _PR();
}

class _PR extends State<PasswordRecovery> {
  _recover(String email) async {
    setState(() {
      userNotFound = false;
      invalidEmail = false;
    });
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (e.code == "ERROR_USER_NOT_FOUND") {
        setState(() {
          userNotFound = true;
        });
        keyEmail.currentState.validate();
      } else if (e.code == "ERROR_INVALID_EMAIL") {
        setState(() {
          invalidEmail = true;
        });
        keyEmail.currentState.validate();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      controller.text = widget.email;
    });
  }

  GlobalKey gk = GlobalKey();
  bool invalidEmail = false;
  bool userNotFound = false;
  final keyEmail = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

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
                text:
                    "There will be a message with instruction send to the given email address.", //"We will send a message with instructions to the given email adress."
                maxLines: 2,
                width: MediaQuery.of(context).size.width * 0.85,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40, bottom: 40),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["textFieldWidth"],
                  child: Form(
                    key: keyEmail,
                    child: TextFormField(
                      cursorColor: Theme.of(context).primaryColor,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.send,
                      controller: controller,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).bottomAppBarColor),
                      onFieldSubmitted: (e) {
                        _recover(e);
                      },
                      validator: (email) {
                        if (invalidEmail) {
                          return "The email address is incorrect";
                        } else if (userNotFound) {
                          return "There is no user with this email address";
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Your email",
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(28 / 3.16666666666))),
                    ),
                  ),
                ),
              ),
            ),
            Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(28)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  splashColor: Colors.grey.withOpacity(0.1),
                  onTap: () {
                    _recover(controller.text);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(28))),
                    width: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"],
                    height: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"] /
                        2,
                    child: Center(
                      child: AutoSizeTextWidget(
                        textColor: Theme.of(context).primaryColorDark,
                        text: "Send",
                        fontWeight: FontWeight.w400,
                        width: MediaQuery.of(context).size.width *
                            Provider.of<Map>(context)["width"] *
                            Provider.of<Map>(context)["iconSize"] /
                            3,
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
