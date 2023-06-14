import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart' as pr;
import "MLkitRecognitionClass.dart";
import 'dataLoaderNoField.dart';
import 'main.dart';
import 'quickClasses.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //show PlatformException;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:video_player/video_player.dart';

// String rndstring = randomAlphaNumeric(10);

class Classroom extends StatefulWidget {
  final String classroomId;
  final bool isTeacher;
  final String userID;
  final String teacherID;
  final bool isLiveEnabled;
  Classroom(
      {Key key,
      @required this.classroomId,
      @required this.isTeacher,
      @required this.userID,
      this.teacherID,
      this.isLiveEnabled});
  @override
  _Cssm createState() => _Cssm();
}

class ClicksPerYear {
  // final String year;
  final int clicks;
  final charts.Color color;
  final int time;
  ClicksPerYear(this.time, this.clicks, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class ClassroomDataChanger extends StatefulWidget {
  final String userID;
  final String classroomId;
  ClassroomDataChanger({@required this.classroomId, @required this.userID});

  @override
  ClassroomChangeData createState() => ClassroomChangeData();
}

class ClassroomChangeData extends State<ClassroomDataChanger> {
  @override
  void initState() {
    super.initState();
    _dataReciever();
  }

  _dateReturner() {
    return AutoSizeTextWidget(
      text: _dateComposer(),
      width: MediaQuery.of(context).size.width *
          pr.Provider.of<Map>(context)["width"] *
          pr.Provider.of<Map>(context)["iconSize"] /
          1.3,
      height: MediaQuery.of(context).size.width *
          pr.Provider.of<Map>(context)["width"] *
          pr.Provider.of<Map>(context)["iconSize"] /
          5,
    );
  }

  _timeReturner() {
    return AutoSizeTextWidget(
      text: _timeComposer(),
      width: MediaQuery.of(context).size.width *
          pr.Provider.of<Map>(context)["width"] *
          pr.Provider.of<Map>(context)["iconSize"] /
          2,
      height: MediaQuery.of(context).size.width *
          pr.Provider.of<Map>(context)["width"] *
          pr.Provider.of<Map>(context)["iconSize"] /
          5,
    );
  }

  _timeComposer() {
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
    return "$dateTimeHour:$dateTimeMinute";
  }

  _dateComposer() {
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
    return "$dateDay.$dateMonth.$dateYear";
  }

  _dataReciever() async {
    DocumentReference documentReference = Firestore.instance
        .collection("users")
        .document(widget.userID)
        .collection("classrooms")
        .document("createdClassrooms")
        .collection(widget.classroomId)
        .document("classroomData");
    DocumentSnapshot classroomData = await documentReference.get();
    setState(() {
      controller.text = classroomData.data["title"];
      initialTitle = classroomData.data["title"];
      currentTitle = classroomData.data["title"];
      dateDay = classroomData.data["day"];
      dateMonth = classroomData.data["month"];
      dateYear = classroomData.data["year"];
      dateTimeHour = classroomData.data["hour"];
      dateTimeMinute = classroomData.data["minute"];
      initialDate = _dateComposer();
      intialTime = _timeComposer();
      currentDate = _dateComposer();
      currentTime = _timeComposer();
      isLoading = true;
    });
  }

  bool isLoading = true;
  String dateDay;
  String dateMonth;
  String dateYear;
  String dateTimeHour;
  String dateTimeMinute;
  TextEditingController controller = TextEditingController();
  GlobalKey<FormState> state = GlobalKey<FormState>();
  String initialDate;
  String intialTime;
  String currentDate;
  String currentTime;
  String initialTitle;
  String currentTitle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: intialTime != currentTime ||
              initialDate != currentDate ||
              initialTitle != currentTitle
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Firestore.instance
                    .collection("users")
                    .document(widget.userID)
                    .collection("classrooms")
                    .document("createdClassrooms")
                    .collection(widget.classroomId)
                    .document("classroomData")
                    .updateData({
                  "title": currentTitle,
                  "day": dateDay,
                  "month": dateMonth,
                  "year": dateYear,
                  "minute": dateTimeMinute,
                  "hour": dateTimeHour
                });
                Navigator.of(context).pop();
              },
              label: Text(
                "Save",
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              icon: Icon(
                Icons.done,
                color: Theme.of(context).primaryColorDark,
              ),
            )
          : null,
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      pr.Provider.of<Map>(context)["textFieldWidth"],
                  child: Form(
                    key: state,
                    child: TextFormField(
                      onChanged: (data) {
                        setState(() {
                          currentTitle = data;
                        });
                      },
                      maxLength: 25,
                      textCapitalization: TextCapitalization.words,
                      cursorColor: Theme.of(context).primaryColor,
                      controller: controller,
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
                      style: TextStyle(
                          color: Theme.of(context).bottomAppBarColor,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
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
                                lastDate:
                                    DateTime.now().add(Duration(days: 30)),
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
                            print(chosenDate);
                            if (chosenDate != null) {
                              setState(() {
                                dateDay = chosenDate.day.toString();
                                dateMonth = chosenDate.month.toString();
                                dateYear = chosenDate.year.toString();
                                currentDate = _dateComposer();
                              });
                            }
                          },
                          highlightColor: Colors.grey.withOpacity(0.2),
                          child: Container(
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"],
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  2,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Theme.of(context).hintColor)),
                              child: Center(child: _dateReturner())),
                        ),
                      ),
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
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: true),
                                      child: picker,
                                    ),
                                  );
                                });
                            if (chosenTime != null) {
                              setState(() {
                                dateTimeHour = chosenTime.hour.toString();
                                dateTimeMinute = chosenTime.minute.toString();
                                currentTime = _timeComposer();
                              });
                            }
                          },
                          highlightColor: Colors.grey.withOpacity(0.2),
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"],
                            height: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] /
                                2,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Theme.of(context).hintColor)),
                            child: Center(child: _timeReturner()),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cssm extends State<Classroom> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (widget.isTeacher == false) {
      WidgetsBinding.instance.addObserver(this);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _streamCreator());
  }

  Map currentStudentsData;
  Stream currentStudentsStream;
  Stream finishedStudentsStream;
  Map finishedStudentsData;

  _streamCreator() {
    setState(() {
      taskStream = Firestore.instance
          .collection("users")
          .document(widget.isTeacher ? widget.userID : widget.teacherID)
          .collection("classrooms")
          .document("createdClassrooms")
          .collection(widget.classroomId)
          .document("tasks")
          .snapshots();
    });
    taskStream.listen(_streamReciever(2));
    setState(() {
      dashboardStream = Firestore.instance
          .collection("users")
          .document(widget.isTeacher ? widget.userID : widget.teacherID)
          .collection("classrooms")
          .document("createdClassrooms")
          .collection(widget.classroomId)
          .document("Dashboard")
          .snapshots();
    });
    dashboardStream.listen(_streamReciever(1));
  }

  _streamReciever(int streamID) {
    if (streamID == 1) {
      dashboardStream.forEach((c) {
        setState(() {
          dashboardStreamData = c.data;
        });
        if (widget.isTeacher == false &&
            dashboardStreamData["isTaskExecutionPaused"] &&
            pausedExec != dashboardStreamData["isTaskExecutionPaused"] &&
            pausedExec != null) {
          mainScaffState.currentState.showSnackBar(SnackBar(
            content: Text("Task execution has been paused by the teacher"),
          ));
        }
        setState(() {
          pausedExec = dashboardStreamData["isTaskExecutionPaused"];
        });
      });
    } else if (streamID == 2) {
      taskStream.forEach((c) {
        setState(() {
          taskStreamData = c.data;
        });
        if (taskStreamData["currentTask"] == null) {
        } else {
          if (widget.isTeacher == false) {
            if (oldTaksNumber != taskStreamData["currentTask"]) {
              setState(() {
                studentAnswers = [];
                oldTaksNumber = taskStreamData["currentTask"];
                List tasksToProcess = taskStreamData["tasks"]
                        [taskStreamData["currentTask"]]["answerFields"]
                    .toList();
                int listsToCreate = tasksToProcess.length;
                while (listsToCreate != 0) {
                  studentAnswers.add("");
                  listsToCreate--;
                }
                int cnt = 0;
                for (Map task in tasksToProcess) {
                  print(studentAnswers[cnt]);
                  if (task["unrestricted"] == false) {
                    int cnt2 = task["fieldData"].length;
                    studentAnswers[cnt] = {"data": []};
                    while (cnt2 != 0) {
                      studentAnswers[cnt]["data"].add(false);
                      cnt2--;
                    }
                  }
                  print(studentAnswers[cnt]);
                  cnt++;
                }
                print(studentAnswers);
              });
            }
          }
          setState(() {
            currentStudentsStream = Firestore.instance
                .collection("users")
                .document(widget.userID)
                .collection("classrooms")
                .document("createdClassrooms")
                .collection(widget.classroomId)
                .document("classroomData")
                .snapshots();
            finishedStudentsStream = Firestore.instance
                .collection("users")
                .document(widget.userID)
                .collection("classrooms")
                .document("createdClassrooms")
                .collection(widget.classroomId)
                .document("taskExecution")
                .snapshots();
          });
          currentStudentsStream.listen(_streamReciever(3));
          finishedStudentsStream.listen(_streamReciever(4));
        }
      });
    } else if (streamID == 3) {
      currentStudentsStream.forEach((c) {
        setState(() {
          currentStudentsData = c.data;
        });
      });
    } else if (streamID == 4) {
      finishedStudentsStream.forEach((c) {
        setState(() {
          finishedStudentsData = c.data;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isTeacher == false) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (widget.isTeacher == false) {
      DocumentSnapshot snp = await Firestore.instance
          .collection("users")
          .document(widget.teacherID)
          .collection("classrooms")
          .document("createdClassrooms")
          .collection(widget.classroomId)
          .document("Dashboard")
          .get();
      if (snp.data["isStudentListenerOn"] &&
          state == AppLifecycleState.resumed) {
        Firestore.instance.runTransaction((tn) async {
          DocumentReference reference = Firestore.instance
              .collection("users")
              .document(widget.teacherID)
              .collection("classrooms")
              .document("createdClassrooms")
              .collection(widget.classroomId)
              .document("studentListener");
          DocumentSnapshot snapshot = await tn.get(reference);
          await tn.update(reference, {
            widget.userID: snapshot.data[widget.userID] == null
                ? 1
                : snapshot.data[widget.userID] + 1
          });
        });
      }
    }
  }

  _finishedStudentsChart() {
    var data = [
      new ClicksPerYear(0, 0, Theme.of(context).primaryColor),
      new ClicksPerYear(200, 10, Theme.of(context).primaryColor),
      new ClicksPerYear(444, 29, Theme.of(context).primaryColor),
      new ClicksPerYear(450, 50, Theme.of(context).primaryColor),
      new ClicksPerYear(500, 70, Theme.of(context).primaryColor),
    ];
    var series = [
      new charts.Series(
        domainFn: (ClicksPerYear clickData, _) => clickData.time,
        measureFn: (ClicksPerYear clickData, _) => clickData.clicks,
        colorFn: (ClicksPerYear clickData, _) => clickData.color,
        id: 'Clicks',
        data: data,
      ),
    ];

    return charts.LineChart(
      series,
      animate: true,
      defaultInteractions: false,
      domainAxis: charts.NumericAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
              labelStyle: charts.TextStyleSpec(
                  color: Theme.of(context).bottomAppBarColor == Colors.white
                      ? charts.MaterialPalette.white
                      : charts.MaterialPalette.black))),
      primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
              labelStyle: charts.TextStyleSpec(
                  color: Theme.of(context).bottomAppBarColor == Colors.white
                      ? charts.MaterialPalette.white
                      : charts.MaterialPalette.black))),
    );
  }

  _teacherDashboard() {
    return dashboardStreamData == null
        ? Center(child: LoadingAnimation())
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AutoSizeTextWidget(
                text: "Teacher Dashboard",
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width *
                    pr.Provider.of<Map>(context)["width"] *
                    pr.Provider.of<Map>(context)["iconSize"] /
                    3.5,
              ),
              Column(
                children: <Widget>[
                  AutoSizeTextWidget(
                    text: "Allow entrance",
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        4,
                  ),
                  Switch(
                    inactiveTrackColor: Colors.grey,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (b) async {
                      await Firestore.instance
                          .collection("users")
                          .document(widget.userID)
                          .collection("classrooms")
                          .document("createdClassrooms")
                          .collection(widget.classroomId)
                          .document("Dashboard")
                          .updateData({"isEntranceAllowed": b});
                    },
                    value: dashboardStreamData["isEntranceAllowed"],
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  AutoSizeTextWidget(
                    text: "Classroom dictionary",
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        4,
                  ),
                  Switch(
                    inactiveTrackColor: Colors.grey,
                    activeColor: Theme.of(context).primaryColor,
                    value: dashboardStreamData["isDictionaryAllowed"],
                    onChanged: (b) async {
                      await Firestore.instance
                          .collection("users")
                          .document(widget.userID)
                          .collection("classrooms")
                          .document("createdClassrooms")
                          .collection(widget.classroomId)
                          .document("Dashboard")
                          .updateData({"isDictionaryAllowed": b});
                    },
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  AutoSizeTextWidget(
                    text: "StudentAntiCheat",
                    width: MediaQuery.of(context).size.width * 0.33,
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.info_outline),
                        color: Colors.grey,
                        onPressed: () {
                          return showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Theme.of(context).secondaryHeaderColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  title: Text("StudentAntiCheat",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .bottomAppBarColor)),
                                  content: Text(
                                    "StudentAntiCheat allows teachers to see how many times their students left the app during the lesson. The data will be being collected since the moment you toggled the switch on. Students cannot see whether the StudentAntiCheat is on or off.",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .bottomAppBarColor),
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
                                                  color: Theme.of(context)
                                                      .primaryColor,
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
                      ),
                      Switch(
                        inactiveTrackColor: Colors.grey,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (b) async {
                          await Firestore.instance
                              .collection("users")
                              .document(widget.userID)
                              .collection("classrooms")
                              .document("createdClassrooms")
                              .collection(widget.classroomId)
                              .document("Dashboard")
                              .updateData({"isStudentListenerOn": b});
                        },
                        value: dashboardStreamData["isStudentListenerOn"],
                      ),
                      AnimatedCrossFade(
                        duration: Duration(milliseconds: 300),
                        crossFadeState:
                            dashboardStreamData["isStudentListenerOn"]
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                        secondChild: IconButton(
                          icon: Icon(
                            Icons.supervised_user_circle,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: null,
                        ),
                        firstChild: IconButton(
                          icon: Icon(
                            Icons.supervised_user_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () => Navigator.of(context).push(FadeRoute(
                              page: StudentAntiCheatList(
                            classroomID: widget.classroomId,
                            userID: widget.userID,
                          ))),
                        ),
                      )
                    ],
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  AutoSizeTextWidget(
                    text: "LivePackage",
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        4.5,
                  ),
                  widget.isLiveEnabled
                      ? Switch(
                          inactiveTrackColor: Colors.grey,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (b) async {
                            await Firestore.instance
                                .collection("users")
                                .document(widget.userID)
                                .collection("classrooms")
                                .document("createdClassrooms")
                                .collection(widget.classroomId)
                                .document("Dashboard")
                                .updateData({"isLiveEnabled": b});
                            if (b) {
                              mainScaffState.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "LivePackage may increase your traffic usage"),
                              ));
                            }
                          },
                          value: dashboardStreamData["isLiveEnabled"],
                        )
                      : GestureDetector(
                          onTap: () {
                            mainScaffState.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  "LivePackage is not activated on this account"),
                              action: SnackBarAction(
                                label: "ACTIVATE",
                                onPressed: () {},
                                textColor: Theme.of(context).primaryColor ==
                                        Colors.blue
                                    ? Color.fromRGBO(110, 198, 255, 1)
                                    : Theme.of(context).primaryColor,
                              ),
                            ));
                          },
                          child: Switch(
                            inactiveTrackColor: Colors.grey,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: null,
                            value: dashboardStreamData["isLiveEnabled"],
                          )),
                ],
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
                          FadeRoute(
                              page: TecherStudentAdd(
                            teacherID: widget.userID,
                            classroomID: widget.classroomId,
                          )));
                      if (invitedStudents != null) {
                        for (String student in invitedStudents) {
                          Firestore.instance.runTransaction((tn) async {
                            DocumentReference reference = Firestore.instance
                                .collection("users")
                                .document(student)
                                .collection("requests")
                                .document("teacherRequests");
                            DocumentReference documentReferenceInvStd =
                                Firestore.instance
                                    .collection("users")
                                    .document(widget.userID)
                                    .collection("classrooms")
                                    .document("createdClassrooms")
                                    .collection(widget.classroomId)
                                    .document("classroomData");
                            DocumentSnapshot invitedStudents =
                                await tn.get(documentReferenceInvStd);
                            DocumentSnapshot studentSnap =
                                await tn.get(reference);
                            List invitedStudentsList = invitedStudents
                                .data["invitedStudents"]
                                .toList();
                            invitedStudentsList.insert(0, student);
                            var currentReqs =
                                studentSnap.data["recievedRequests"];
                            currentReqs[widget.userID + widget.classroomId] = {
                              "teacherID": widget.userID,
                              "classroomID": widget.classroomId
                            };
                            await tn.update(
                                reference, {"recievedRequests": currentReqs});

                            await tn.update(
                                Firestore.instance
                                    .collection("users")
                                    .document(widget.userID)
                                    .collection("classrooms")
                                    .document("createdClassrooms")
                                    .collection(widget.classroomId)
                                    .document("studentListener"),
                                {student: 0});
                            await tn.update(documentReferenceInvStd,
                                {"invitedStudents": invitedStudentsList});
                          });
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28)),
                      height: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] /
                          2,
                      width: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"],
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  0.24,
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  0.24,
                              child: SvgPicture.asset(
                                "assets/round-add-24px.svg",
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            AutoSizeTextWidget(
                              text: "Invite",
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  2 *
                                  0.7,
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
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
                    onTap: () => Navigator.of(context).push(FadeRoute(
                        page: ClassroomDataChanger(
                      userID: widget.userID,
                      classroomId: widget.classroomId,
                    ))),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28)),
                      height: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] /
                          2,
                      width: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] *
                          1.9,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  0.2,
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  0.2,
                              child: SvgPicture.asset(
                                "assets/edit-24px.svg",
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            AutoSizeTextWidget(
                              text: "Edit classroom data",
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  1.3,
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  3,
                              textColor: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w400,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
  }

  _classroomReturner() {
    if (widget.isTeacher) {
      return PageView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _chatReturner(),
          _teahcerTaskManager(),
          _teacherDashboard()
        ],
      );
    } else if (widget.isTeacher == false) {
      return PageView(
        controller: pgcTrue,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          AnimatedSwitcher(
              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: Curves.fastOutSlowIn,
              duration: Duration(milliseconds: 300),
              child: _dictionaryReturner()),
          _chatReturner(),
          AnimatedSwitcher(
              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: Curves.fastOutSlowIn,
              duration: Duration(milliseconds: 300),
              child: _studentTask()),
          _studentDashboard()
        ],
      );
    }
  }

  _dictionaryReturner() {
    return dashboardStreamData == null ||
            dashboardStreamData["isDictionaryAllowed"] == false
        ? Center(
            child: AutoSizeTextWidget(
                text: "Dictionary's been disabled by the teacher",
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width *
                    pr.Provider.of<Map>(context)["width"] *
                    pr.Provider.of<Map>(context)["iconSize"] /
                    2),
          )
        : Loader(
            textFieldEnabled: true,
          );
  }

  _messageSender(String message) async {
    Firestore.instance.runTransaction((tn) async {
      DocumentReference reference = Firestore.instance
          .collection("users")
          .document(widget.isTeacher ? widget.userID : widget.teacherID)
          .collection("classrooms")
          .document("createdClassrooms")
          .collection(widget.classroomId)
          .document("classroomChat");
      DocumentSnapshot snapshot = await tn.get(reference);
      var lst = snapshot.data["messages"].toList();
      lst.add({
        "type": "message",
        "id": widget.userID,
        "message": message,
        "time": DateTime.now().toUtc().toIso8601String(),
        "privateTo": false,
      });
      await tn.update(reference, {"messages": lst});
    });
// String rndstring = randomAlphaNumeric(20);
//       await Firestore.instance
//           .collection("users")
//           .document(widget.userID)
//           .collection("classrooms")
//           .document("createdClassrooms")
//           .collection(widget.classroomId)
//           .document("classroomChat").collection("docMessages").document(rndstring).setData({
//         "type": "message",
//         "id": widget.userID,
//         "message": message,
//         "time": DateTime.now().toUtc().toIso8601String(),
//         "timeOrder" :  DateTime.now().toUtc(),
//         "privateTo": false
//       });
  }

  _attachPhoto() async {
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      FirebaseStorage storageRef = FirebaseStorage.instance;
      String rndstring = randomAlphaNumeric(10);
      var reference = storageRef
          .ref()
          .child("images")
          .child(widget.userID)
          .child(rndstring);
      StorageUploadTask task = reference.putFile(file);
      await task.onComplete;
      String url = await reference.getDownloadURL();
      Firestore.instance.runTransaction((tn) async {
        DocumentReference reference = Firestore.instance
            .collection("users")
            .document(widget.isTeacher ? widget.userID : widget.teacherID)
            .collection("classrooms")
            .document("createdClassrooms")
            .collection(widget.classroomId)
            .document("classroomChat");
        DocumentSnapshot snapshot = await tn.get(reference);
        var lst = snapshot.data["messages"].toList();
        lst.add({
          "type": "image",
          "id": widget.userID,
          "message": url,
          "time": DateTime.now().toUtc().toIso8601String(),
          "privateTo": false
        });

        await tn.update(reference, {"messages": lst});
      });
    }
  }

  _messageDeleter(int i) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Delete the message?",
                style: TextStyle(color: Theme.of(context).bottomAppBarColor)),
            content: Text(
              "The message will be permanetly deleted.",
              style: TextStyle(color: Theme.of(context).bottomAppBarColor),
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
                  onTap: () async {
                    Navigator.pop(context);
                    if (widget.isTeacher) {
                      DocumentSnapshot snap = await Firestore.instance
                          .collection("users")
                          .document(widget.userID)
                          .collection("classrooms")
                          .document("createdClassrooms")
                          .collection(widget.classroomId)
                          .document("classroomChat")
                          .get();
                      var lst = snap.data["messages"].reversed.toList();
                      lst.removeAt(i);
                      await Firestore.instance
                          .collection("users")
                          .document(widget.userID)
                          .collection("classrooms")
                          .document("createdClassrooms")
                          .collection(widget.classroomId)
                          .document("classroomChat")
                          .updateData({"messages": lst.reversed.toList()});
                    } else {
                      DocumentSnapshot stsnap = await Firestore.instance
                          .collection("users")
                          .document(widget.teacherID)
                          .collection("classrooms")
                          .document("createdClassrooms")
                          .collection(widget.classroomId)
                          .document("classroomChat")
                          .get();
                      print(stsnap.data);
                      var lst = stsnap.data["messages"].reversed.toList();
                      lst.removeAt(i);
                      await Firestore.instance
                          .collection("users")
                          .document(widget.teacherID)
                          .collection("classrooms")
                          .document("createdClassrooms")
                          .collection(widget.classroomId)
                          .document("classroomChat")
                          .updateData({"messages": lst.reversed.toList()});
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

  _timeReformatter(var time) {
    String hour = DateTime.tryParse(time).toLocal().hour.toString();
    String minute = DateTime.tryParse(time).toLocal().minute.toString();
    if (hour.length == 1) {
      hour = "0" + hour;
    }
    if (minute.length == 1) {
      minute = "0" + minute;
    }
    return "$hour:$minute";
  }

  _chatReturner() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("users")
                  .document(widget.isTeacher ? widget.userID : widget.teacherID)
                  .collection("classrooms")
                  .document("createdClassrooms")
                  .collection(widget.classroomId)
                  .document("classroomChat")
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data["messages"].isNotEmpty) {
                    var lst = snapshot.data["messages"].reversed.toList();
                    return ListView.builder(
                      reverse: true,
                      itemCount: lst.length,
                      itemBuilder: (context, int i) {
                        return Align(
                          alignment: widget.userID == lst[i]["id"]
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: StreamBuilder(
                                stream: Firestore.instance
                                    .collection("users")
                                    .document(lst[i]["id"])
                                    .snapshots(),
                                builder: (context, userSnap) {
                                  if (userSnap.connectionState ==
                                      ConnectionState.active) {
                                    return Column(
                                      children: <Widget>[
                                        i + 1 != lst.length &&
                                                lst[i]["id"] == lst[i + 1]["id"]
                                            ? Container()
                                            : Row(
                                                mainAxisAlignment: widget
                                                            .userID ==
                                                        lst[i]["id"]
                                                    ? MainAxisAlignment.end
                                                    : MainAxisAlignment.start,
                                                children: <Widget>[
                                                  widget.userID == lst[i]["id"]
                                                      ? Container()
                                                      : SvgPicture.asset(
                                                          userSnap
                                                              .data["avatar"],
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] *
                                                              0.2,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] *
                                                              0.2,
                                                        ),
                                                  widget.userID == lst[i]["id"]
                                                      ? AutoSizeTextWidget(
                                                          text: "You",
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] *
                                                              0.28)
                                                      : AutoSizeTextWidget(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"],
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] *
                                                              0.2,
                                                          text: userSnap.data[
                                                                  "name"] +
                                                              " " +
                                                              userSnap.data[
                                                                  "surname"],
                                                        )
                                                ],
                                              ),
                                        Align(
                                          alignment:
                                              widget.userID == lst[i]["id"]
                                                  ? Alignment.bottomRight
                                                  : Alignment.bottomLeft,
                                          child: GestureDetector(
                                            onLongPress:
                                                widget.userID == lst[i]["id"]
                                                    ? () {
                                                        _messageDeleter(i);
                                                      }
                                                    : null,
                                            onTap: () => lst[i]["type"] ==
                                                    "image"
                                                ? Navigator.push(
                                                    context,
                                                    FadeRoute(
                                                        page: ImageViewer(
                                                      isPreview: false,
                                                      imageUrl: lst[i]
                                                          ["message"],
                                                    )))
                                                : lst[i]["type"] == "message"
                                                    ? null
                                                    : null,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          65),
                                              decoration: BoxDecoration(
                                                  color: lst[i]["privateTo"]
                                                      ? Colors.red
                                                          .withOpacity(0.5)
                                                      : Colors.grey
                                                          .withOpacity(0.7),
                                                  borderRadius: BorderRadius
                                                      .circular(lst[i][
                                                                      "type"] ==
                                                                  "image" ||
                                                              lst[i]["type"] ==
                                                                  "video"
                                                          ? 5
                                                          : 26)),
                                              child: Padding(
                                                  padding: EdgeInsets.all(lst[i]
                                                                  ["type"] ==
                                                              "image" ||
                                                          lst[i]["type"] ==
                                                              "video"
                                                      ? MediaQuery.of(context).size.width *
                                                          pr.Provider.of<Map>(context)[
                                                              "width"] *
                                                          pr.Provider.of<Map>(context)[
                                                              "iconSize"] *
                                                          0.03
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          pr.Provider.of<Map>(
                                                              context)["width"] *
                                                          pr.Provider.of<Map>(context)["iconSize"] *
                                                          0.07),
                                                  child: lst[i]["type"] == "image"
                                                      ? Hero(
                                                          tag: lst[i]
                                                              ["message"],
                                                          child: Image.network(
                                                            lst[i]["message"],
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent
                                                                        loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child:
                                                                    LoadingAnimation(),
                                                              );
                                                            },
                                                            fit: BoxFit.contain,
                                                          ),
                                                        )
                                                      : lst[i]["type"] == "message"
                                                          ? Text(
                                                              lst[i]["message"],
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: Theme.of(context)
                                                                              .primaryColorDark ==
                                                                          Colors
                                                                              .white
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              1),
                                                                  fontSize: 15),
                                                            )
                                                          : null),
                                            ),
                                          ),
                                        ),
                                        Align(
                                            alignment:
                                                widget.userID == lst[i]["id"]
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                            child: AutoSizeTextWidget(
                                              text: _timeReformatter(
                                                  lst[i]["time"]),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  pr.Provider.of<Map>(
                                                      context)["width"] *
                                                  pr.Provider.of<Map>(
                                                      context)["iconSize"] *
                                                  0.35,
                                            ))
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: AutoSizeTextWidget(
                          text: "No sent or recieved messages found",
                          width: MediaQuery.of(context).size.width * 0.9),
                    );
                  }
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Theme.of(context).primaryColorDark,
            width: MediaQuery.of(context).size.width * 0.96,
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              cursorColor: Theme.of(context).primaryColor,
              controller: ted,
              textInputAction: TextInputAction.send,
              onSubmitted: (message) {
                if (message != "") {
                  _messageSender(message);
                  ted.clear();
                }
              },
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).bottomAppBarColor),
              decoration: InputDecoration(
                  filled: Theme.of(context).bottomAppBarColor == Colors.white
                      ? true
                      : false,
                  hintText: "Your message",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28)),
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (ted.text != "") {
                          _messageSender(ted.text);
                          ted.clear();
                        }
                      },
                      icon: Center(
                        child: Container(
                          child: SvgPicture.asset("assets/send_icon.svg",
                              color: Theme.of(context).primaryColor),
                        ),
                      )),
                  prefixIcon: IconButton(
                    onPressed: _attachPhoto,
                    icon: Center(
                      child: Container(
                        child: SvgPicture.asset("assets/photo_library_icon.svg",
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )),
            ),
          ),
        )
      ],
    );
  }

  bool pausedExec;
  bool isTimerEnabled = false;
  int availableTabs = 3;
  int currentPage = 1;
  PageController chartsPageController = PageController(initialPage: 1);

  _teahcerTaskManager() {
    return DefaultTabController(
      length: 2,
      child: Container(
        child: Scaffold(
          appBar: TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(
                  text: "CURRENT TASK",
                ),
                Tab(
                  text: "AVAILABLE TASKS",
                )
              ]),
          backgroundColor: Theme.of(context).primaryColorDark,
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              taskStreamData != null
                  ? taskStreamData["currentTask"] == null ||
                          finishedStudentsData == null
                      ? Center(
                          child: AutoSizeTextWidget(
                            text: "Select task first",
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] /
                                2.5,
                          ),
                        )
                      : Column(
                          children: <Widget>[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: ((MediaQuery.of(context).size.width -
                                                2 *
                                                    (pr.Provider.of<Map>(
                                                            context)["width"] *
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width)) /
                                            3) /
                                        2),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: ((MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      pr.Provider.of<Map>(
                                                          context)["width"] *
                                                      2)) /
                                              6),
                                          right: ((MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      pr.Provider.of<Map>(
                                                          context)["width"] *
                                                      2)) /
                                              6)),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                width: 0.7),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        width: isTimerEnabled
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.43229166666
                                            : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.43229166666 *
                                                    2 +
                                                ((MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        (MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            pr.Provider.of<Map>(
                                                                    context)[
                                                                "width"] *
                                                            2)) /
                                                    6),
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.43229166666 *
                                                0.62379421221,
                                        child: Material(
                                          elevation: 5,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            onTap: () => Navigator.push(
                                                context,
                                                FadeRoute(
                                                    page: FinishedStudentList(
                                                  userID: widget.userID,
                                                  taskID: taskStreamData[
                                                          "currentTask"]
                                                      .toString(),
                                                  classroomID:
                                                      widget.classroomId,
                                                  answerFields: taskStreamData[
                                                                  "tasks"][
                                                              taskStreamData[
                                                                  "currentTask"]]
                                                          ["answerFields"]
                                                      .toList(),
                                                ))),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Center(
                                                  child: AnimatedSwitcher(
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    child: AutoSizeTextWidget(
                                                        key: ValueKey(finishedStudentsData[taskStreamData["currentTask"].toString()]
                                                                .length
                                                                .toString() +
                                                            "/" +
                                                            ((currentStudentsData["invitedStudents"]
                                                                        .length -
                                                                    1)
                                                                .toString())),
                                                        width:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.4,
                                                        height: MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            pr.Provider.of<Map>(
                                                                context)["width"] *
                                                            pr.Provider.of<Map>(context)["iconSize"] /
                                                            2.5,
                                                        text: finishedStudentsData[taskStreamData["currentTask"].toString()].length.toString() + "/" + ((currentStudentsData["invitedStudents"].length - 1).toString())),
                                                  ),
                                                ),
                                                Center(
                                                  child: AutoSizeTextWidget(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          pr.Provider.of<Map>(
                                                                  context)[
                                                              "width"] *
                                                          pr.Provider.of<Map>(
                                                                  context)[
                                                              "iconSize"] /
                                                          2,
                                                      text: "students finished"),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              width: 0.7),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      duration: Duration(milliseconds: 300),
                                      width: isTimerEnabled
                                          ? MediaQuery.of(context).size.width *
                                              0.43229166666
                                          : 0,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.43229166666 *
                                              0.62379421221,
                                      child: Material(
                                        elevation: 5,
                                        borderRadius: BorderRadius.circular(15),
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          onTap: () {
                                            setState(() {
                                              isTimerEnabled =
                                                  isTimerEnabled ? false : true;
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.width / 1.7,
                              width: MediaQuery.of(context).size.width,
                              child: PageView(
                                onPageChanged: (newPage) {
                                  setState(() {
                                    currentPage = newPage;
                                  });
                                },
                                controller: chartsPageController,
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  StudentTeacherModePageViewContainer(),
                                  StudentTeacherModePageViewContainer(
                                    child: Center(
                                      child: Container(
                                        width: (MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.43229166666 *
                                                    2 +
                                                ((MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        (MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            pr.Provider.of<Map>(
                                                                    context)[
                                                                "width"] *
                                                            2)) /
                                                    6)) /
                                            1.1,
                                        child: _finishedStudentsChart(),
                                      ),
                                    ),
                                  ),
                                  StudentTeacherModePageViewContainer()
                                ],
                              ),
                            ),
                            availableTabs > 1
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      IconButton(
                                        tooltip: "Previous page",
                                        onPressed: () {
                                          if (currentPage !=
                                              availableTabs - 1) {
                                            chartsPageController.animateToPage(
                                                currentPage - 1,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.fastOutSlowIn);
                                          }
                                        },
                                        icon: SvgPicture.asset(
                                          "assets/arrow_left_icon.svg",
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.width /
                                                40,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                40 *
                                                5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            availableTabs == 3
                                                ? SelectedPageIndidcator(
                                                    color: currentPage == 0
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.5),
                                                  )
                                                : Container(),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      40,
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      40),
                                              child: SelectedPageIndidcator(
                                                color: currentPage == 1
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                            SelectedPageIndidcator(
                                              color: currentPage == 2
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.5),
                                            )
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: "Next page",
                                        onPressed: () {
                                          if (currentPage !=
                                              availableTabs - 1) {
                                            chartsPageController.animateToPage(
                                                currentPage + 1,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.fastOutSlowIn);
                                          }
                                        },
                                        icon: SvgPicture.asset(
                                          "assets/arrow_right_icon.svg",
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                CircularButton(
                                  onTap: () => Navigator.of(context)
                                      .push(FadeRoute(page: Timer())),
                                  icon: "assets/timer_icon.svg",
                                  tooltipMessage: "Set timer",
                                ),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 220),
                                  child: CircularButton(
                                    key: ValueKey(dashboardStreamData[
                                        "isTaskExecutionPaused"]),
                                    onTap: () async {
                                      await Firestore.instance
                                          .collection("users")
                                          .document(widget.userID)
                                          .collection("classrooms")
                                          .document("createdClassrooms")
                                          .collection(widget.classroomId)
                                          .document("Dashboard")
                                          .updateData({
                                        "isTaskExecutionPaused":
                                            dashboardStreamData[
                                                    "isTaskExecutionPaused"]
                                                ? false
                                                : true
                                      });
                                    },
                                    icon: dashboardStreamData[
                                            "isTaskExecutionPaused"]
                                        ? "assets/play_icon.svg"
                                        : "assets/pause_icon.svg",
                                    tooltipMessage: dashboardStreamData[
                                            "isTaskExecutionPaused"]
                                        ? "Continue execution"
                                        : "Pause execution",
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                  : LoadingAnimation(),
              Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: FloatingActionButton(
                  tooltip: "Create new task",
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/round-add-24px.svg",
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () async {
                    var data = await Navigator.of(context).push(FadeRoute(
                        page: TaskCreate(
                      classroomID: widget.classroomId,
                      teacherID: widget.userID,
                      isDraft: false,
                    )));
                  },
                ),
                backgroundColor: Theme.of(context).primaryColorDark,
                body: taskStreamData != null
                    ? taskStreamData["tasks"].length != 0
                        ? Row(
                            children: <Widget>[
                              AnimatedContainer(
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 300),
                                width: isTaskSelected
                                    ? MediaQuery.of(context).size.width / 2 -
                                        0.05
                                    : MediaQuery.of(context).size.width,
                                child: ListView.separated(
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(),
                                  itemCount: taskStreamData["tasks"].length,
                                  itemBuilder: (context, i) {
                                    return AnimatedCrossFade(
                                      duration: Duration(milliseconds: 300),
                                      crossFadeState:
                                          taskStreamData["currentTask"] == i
                                              ? CrossFadeState.showFirst
                                              : CrossFadeState.showSecond,
                                      firstChild: Material(
                                        borderRadius: BorderRadius.circular(28),
                                        color: Colors.grey.withOpacity(0.2),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          highlightColor:
                                              Colors.grey.withOpacity(0.5),
                                          onTap: () {
                                            setState(() {
                                              taskIdentifier = i;
                                              if (taskStreamData["tasks"][i]
                                                      ["answerFields"] !=
                                                  null) {
                                                answerFields =
                                                    taskStreamData["tasks"][i]
                                                        ["answerFields"];
                                              } else {
                                                answerFields = [];
                                              }
                                              if (taskStreamData["tasks"][i]
                                                      ["imagesUrls"] !=
                                                  null) {
                                                images = taskStreamData["tasks"]
                                                    [i]["imagesUrls"];
                                              } else {
                                                images = [];
                                              }
                                              note = taskStreamData["tasks"][i]
                                                  ["note"];
                                              name = taskStreamData["tasks"][i]
                                                  ["taskName"];
                                              isTaskSelected = true;
                                            });
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Center(
                                              child: AutoSizeTextWidget(
                                                text: taskStreamData["tasks"][i]
                                                    ["taskName"],
                                                width: (MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2 -
                                                        0.05) *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    pr.Provider.of<Map>(
                                                        context)["width"] *
                                                    pr.Provider.of<Map>(
                                                        context)["iconSize"] /
                                                    4,
                                              ),
                                            ),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] /
                                                2,
                                          ),
                                        ),
                                      ),
                                      secondChild: Material(
                                        borderRadius: BorderRadius.circular(28),
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          highlightColor:
                                              Colors.grey.withOpacity(0.5),
                                          onTap: () {
                                            setState(() {
                                              taskIdentifier = i;
                                              if (taskStreamData["tasks"][i]
                                                      ["answerFields"] !=
                                                  null) {
                                                answerFields =
                                                    taskStreamData["tasks"][i]
                                                        ["answerFields"];
                                              } else {
                                                answerFields = [];
                                              }
                                              if (taskStreamData["tasks"][i]
                                                      ["imagesUrls"] !=
                                                  null) {
                                                images = taskStreamData["tasks"]
                                                    [i]["imagesUrls"];
                                              } else {
                                                images = [];
                                              }
                                              note = taskStreamData["tasks"][i]
                                                  ["note"];
                                              name = taskStreamData["tasks"][i]
                                                  ["taskName"];
                                              isTaskSelected = true;
                                            });
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Center(
                                              child: AutoSizeTextWidget(
                                                text: taskStreamData["tasks"][i]
                                                    ["taskName"],
                                                width: (MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2 -
                                                        0.05) *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    pr.Provider.of<Map>(
                                                        context)["width"] *
                                                    pr.Provider.of<Map>(
                                                        context)["iconSize"] /
                                                    4,
                                              ),
                                            ),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] /
                                                2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              AnimatedContainer(
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 300),
                                width: isTaskSelected ? 0.1 : 0,
                                color: Colors.grey,
                              ),
                              AnimatedContainer(
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 300),
                                width: isTaskSelected
                                    ? MediaQuery.of(context).size.width / 2 -
                                        0.05
                                    : 0,
                                child: _moreTaskData(),
                              )
                            ],
                          )
                        : Center(
                            child: AutoSizeTextWidget(
                              text: "No available tasks found",
                              width: MediaQuery.of(context).size.width * 0.7,
                            ),
                          )
                    : Center(
                        child: LoadingAnimation(),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Stream dashboardStream;
  Stream taskStream;
  String name;
  String note;
  List images;
  List answerFields;
  int taskIdentifier;
  Map taskStreamData;
  Map dashboardStreamData;
  bool isTaskSelected = false;

  bool displayTaskName = true;
  bool displayTaskNote = false;
  bool displayTaskImages = true;
  List studentAnswers = [];
  int oldTaksNumber;
  bool isLivePackage = false;

  _moreTaskData() {
    return isTaskSelected == false
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: AnimatedSwitcher(
                  switchInCurve: Curves.fastOutSlowIn,
                  switchOutCurve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 200),
                  child: AutoSizeTextWidget(
                    key: ValueKey(name),
                    text: name,
                    width: (MediaQuery.of(context).size.width / 2 - 0.05) * 0.8,
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        3,
                  ),
                ),
              ),
              Center(
                child: AnimatedSwitcher(
                  switchInCurve: Curves.fastOutSlowIn,
                  switchOutCurve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 200),
                  child: AutoSizeTextWidget(
                    key: ValueKey(images.length),
                    text: images.length.toString() +
                        (images.length == 1 ? "image" : " images"),
                    width: (MediaQuery.of(context).size.width / 2 - 0.05) * 0.8,
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        3,
                  ),
                ),
              ),
              Center(
                child: AnimatedSwitcher(
                  switchInCurve: Curves.fastOutSlowIn,
                  switchOutCurve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 200),
                  child: AutoSizeTextWidget(
                    key: ValueKey(answerFields.length),
                    text: answerFields.length.toString() +
                        (answerFields.length == 1 ? "field" : " fields"),
                    width: (MediaQuery.of(context).size.width / 2 - 0.05) * 0.8,
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        3,
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
                    onTap: () => Navigator.of(context).push(FadeRoute(
                        page: TaskPreview(
                      taskName: name,
                      note: note,
                      images: images,
                      answerFields: answerFields,
                      isFromCreatedDraft: true,
                    ))),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28)),
                      height: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] /
                          2,
                      width: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] *
                          1.2,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  0.24,
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  0.24,
                              child: SvgPicture.asset(
                                "assets/art_track_icon.svg",
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.01),
                              child: AutoSizeTextWidget(
                                text: "Preview",
                                width: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    2,
                                height: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    2,
                                textColor: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.w400,
                              ),
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
                    onTap: () async {
                      await Firestore.instance
                          .collection("users")
                          .document(widget.userID)
                          .collection("classrooms")
                          .document("createdClassrooms")
                          .collection(widget.classroomId)
                          .document("tasks")
                          .updateData({"currentTask": taskIdentifier});
                      setState(() {
                        currentStudentsStream = Firestore.instance
                            .collection("users")
                            .document(widget.userID)
                            .collection("classrooms")
                            .document("createdClassrooms")
                            .collection(widget.classroomId)
                            .document("classroomData")
                            .snapshots();
                      });
                      currentStudentsStream.listen(_streamReciever(3));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28)),
                      height: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] /
                          2,
                      width: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] *
                          1.2,
                      child: Center(
                        child: AutoSizeTextWidget(
                          text: "Make current",
                          fontWeight: FontWeight.w400,
                          width: MediaQuery.of(context).size.width *
                              pr.Provider.of<Map>(context)["width"] *
                              pr.Provider.of<Map>(context)["iconSize"] /
                              1.25,
                          height: MediaQuery.of(context).size.width *
                              pr.Provider.of<Map>(context)["width"] *
                              pr.Provider.of<Map>(context)["iconSize"] /
                              2,
                          textColor: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
  }

  _studentDashboard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        AutoSizeTextWidget(
          text: "Student Dashboard",
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width *
              pr.Provider.of<Map>(context)["width"] *
              pr.Provider.of<Map>(context)["iconSize"] /
              3.5,
        ),
        Column(
          children: <Widget>[
            AutoSizeTextWidget(
              text: "Show task name",
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width *
                  pr.Provider.of<Map>(context)["width"] *
                  pr.Provider.of<Map>(context)["iconSize"] /
                  5,
            ),
            Switch(
              inactiveTrackColor: Colors.grey,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (b) {
                setState(() {
                  displayTaskName = b;
                });
              },
              value: displayTaskName,
            )
          ],
        ),
        Column(
          children: <Widget>[
            AutoSizeTextWidget(
              text: "Show task note",
              width: MediaQuery.of(context).size.width * 0.43,
              height: MediaQuery.of(context).size.width *
                  pr.Provider.of<Map>(context)["width"] *
                  pr.Provider.of<Map>(context)["iconSize"] /
                  5,
            ),
            Switch(
                inactiveTrackColor: Colors.grey,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (b) {
                  setState(() {
                    displayTaskNote = b;
                  });
                },
                value: displayTaskNote),
          ],
        ),
        Column(
          children: <Widget>[
            AutoSizeTextWidget(
              text: "Show task images",
              width: MediaQuery.of(context).size.width * 0.33,
              height: MediaQuery.of(context).size.width *
                  pr.Provider.of<Map>(context)["width"] *
                  pr.Provider.of<Map>(context)["iconSize"] /
                  4,
            ),
            Switch(
              inactiveTrackColor: Colors.grey,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (b) {
                setState(() {
                  displayTaskImages = b;
                });
              },
              value: displayTaskImages,
            ),
          ],
        ),
      ],
    );
  }

  _studentTask() {
    return taskStreamData == null
        ? Center(
            child: LoadingAnimation(),
          )
        : taskStreamData["currentTask"] != null
            ? Column(
                key: ValueKey(taskStreamData["currentTask"]),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                    Center(
                        child: displayTaskName
                            ? AutoSizeTextWidget(
                                text: taskStreamData["tasks"]
                                    [taskStreamData["currentTask"]]["taskName"],
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width / 13,
                              )
                            : Container()),
                    taskStreamData["tasks"][taskStreamData["currentTask"]]
                                ["note"] !=
                            null
                        ? displayTaskNote
                            ? AutoSizeTextWidget(
                                text: taskStreamData["tasks"]
                                    [taskStreamData["currentTask"]]["note"],
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width / 16,
                              )
                            : Container()
                        : Container(),
                    taskStreamData["tasks"][taskStreamData["currentTask"]]
                                ["imagesUrls"]
                            .isNotEmpty
                        ? displayTaskImages
                            ? Container(
                                height: MediaQuery.of(context).size.width * 0.6,
                                child: PageView.builder(
                                  itemCount: taskStreamData["tasks"]
                                              [taskStreamData["currentTask"]]
                                          ["imagesUrls"]
                                      .length,
                                  itemBuilder: (context, i) {
                                    return GestureDetector(
                                        onTap: () => Navigator.of(context).push(
                                            FadeRoute(
                                                page: ImageViewer(
                                                    imageUrl: taskStreamData[
                                                                "tasks"][
                                                            taskStreamData[
                                                                "currentTask"]]
                                                        ["imagesUrls"][i],
                                                    isPreview: false))),
                                        child: Hero(
                                          tag: taskStreamData["tasks"][
                                                  taskStreamData["currentTask"]]
                                              ["imagesUrls"][i],
                                          child: Image.network(
                                            taskStreamData["tasks"][
                                                    taskStreamData[
                                                        "currentTask"]]
                                                ["imagesUrls"][i],
                                            fit: BoxFit.contain,
                                          ),
                                        ));
                                  },
                                ),
                              )
                            : Container()
                        : Container(),
                    taskStreamData["tasks"][taskStreamData["currentTask"]]
                                ["answerFields"] !=
                            null
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: taskStreamData["tasks"]
                                          [taskStreamData["currentTask"]]
                                      ["answerFields"]
                                  .length,
                              itemBuilder: (context, i) {
                                if (taskStreamData["tasks"]
                                        [taskStreamData["currentTask"]]
                                    ["answerFields"][i]["unrestricted"]) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width *
                                            pr.Provider.of<Map>(
                                                context)["width"] *
                                            pr.Provider.of<Map>(
                                                context)["iconSize"] /
                                            10),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              pr.Provider.of<Map>(
                                                  context)["textFieldWidth"],
                                          child: TextField(
                                            readOnly: dashboardStreamData[
                                                "isTaskExecutionPaused"],
                                            onChanged: (data) async {
                                              setState(() {
                                                studentAnswers[i] = data;
                                              });
                                              print(studentAnswers);
                                              if (dashboardStreamData[
                                                  "isLiveEnabled"]) {
                                                await Firestore.instance
                                                    .collection("users")
                                                    .document(widget.teacherID)
                                                    .collection("classrooms")
                                                    .document(
                                                        "createdClassrooms")
                                                    .collection(
                                                        widget.classroomId)
                                                    .document("taskExecution")
                                                    .collection(widget.userID)
                                                    .document(taskStreamData[
                                                            "currentTask"]
                                                        .toString())
                                                    .updateData({
                                                  "studentAnswers":
                                                      studentAnswers,
                                                  "isFinished": false
                                                });
                                              }
                                            },
                                            cursorColor:
                                                Theme.of(context).primaryColor,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Theme.of(context)
                                                    .bottomAppBarColor),
                                            decoration: InputDecoration(
                                              fillColor: Colors.transparent,
                                              filled: true,
                                              labelText: (i + 1).toString(),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        28 / 3.16666666666),
                                              ),
                                            ),
                                          ),
                                        )),
                                  );
                                } else {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width *
                                            pr.Provider.of<Map>(
                                                context)["width"] *
                                            pr.Provider.of<Map>(
                                                context)["iconSize"] /
                                            10),
                                    child: ExpansionTile(
                                      title: Text(
                                        (i + 1).toString(),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .bottomAppBarColor),
                                      ),
                                      children: <Widget>[
                                        Container(
                                          height: (taskStreamData["tasks"][
                                                                  taskStreamData[
                                                                      "currentTask"]]
                                                              ["answerFields"]
                                                          [i]["fieldData"]
                                                      .length *
                                                  (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      pr.Provider.of<Map>(
                                                          context)["width"] *
                                                      pr.Provider.of<Map>(
                                                          context)["iconSize"] /
                                                      2))
                                              .toDouble(),
                                          child: ListView.builder(
                                            itemCount: taskStreamData["tasks"][
                                                            taskStreamData[
                                                                "currentTask"]]
                                                        ["answerFields"][i]
                                                    ["fieldData"]
                                                .length,
                                            itemBuilder: (context, b) {
                                              return Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    pr.Provider.of<Map>(
                                                        context)["width"] *
                                                    pr.Provider.of<Map>(
                                                        context)["iconSize"] /
                                                    2,
                                                child: Row(
                                                  children: <Widget>[
                                                    Theme(
                                                      data: ThemeData(
                                                          unselectedWidgetColor:
                                                              Theme.of(context)
                                                                  .primaryColor),
                                                      child: Checkbox(
                                                        checkColor: Theme.of(
                                                                context)
                                                            .primaryColorDark,
                                                        value: studentAnswers[i]
                                                            ["data"][b],
                                                        activeColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onChanged:
                                                            dashboardStreamData[
                                                                        "isTaskExecutionPaused"] ==
                                                                    false
                                                                ? (bb) async {
                                                                    print(bb);
                                                                    setState(
                                                                        () {
                                                                      //TODO: Allow mutliple selection
                                                                      bool
                                                                          mltpSelection =
                                                                          false;
                                                                      if (mltpSelection ==
                                                                          false) {
                                                                        int cr =
                                                                            studentAnswers[i]["data"].length;
                                                                        studentAnswers[
                                                                            i] = {
                                                                          "data":
                                                                              []
                                                                        };
                                                                        while (cr !=
                                                                            0) {
                                                                          studentAnswers[i]["data"]
                                                                              .add(false);
                                                                          cr--;
                                                                        }
                                                                      }
                                                                      studentAnswers[i]
                                                                              [
                                                                              "data"]
                                                                          [
                                                                          b] = bb;
                                                                    });
                                                                    if (dashboardStreamData[
                                                                        "isLiveEnabled"]) {
                                                                      await Firestore
                                                                          .instance
                                                                          .collection(
                                                                              "users")
                                                                          .document(widget
                                                                              .teacherID)
                                                                          .collection(
                                                                              "classrooms")
                                                                          .document(
                                                                              "createdClassrooms")
                                                                          .collection(widget
                                                                              .classroomId)
                                                                          .document(
                                                                              "taskExecution")
                                                                          .collection(widget
                                                                              .userID)
                                                                          .document(taskStreamData["currentTask"]
                                                                              .toString())
                                                                          .updateData({
                                                                        "studentAnswers":
                                                                            studentAnswers,
                                                                        "isFinished":
                                                                            false
                                                                      });
                                                                    }
                                                                  }
                                                                : (bb) {},
                                                      ),
                                                    ),
                                                    AutoSizeTextWidget(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      text: taskStreamData[
                                                                      "tasks"][
                                                                  taskStreamData[
                                                                      "currentTask"]]
                                                              ["answerFields"]
                                                          [i]["fieldData"][b],
                                                      height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          pr.Provider.of<Map>(
                                                                  context)[
                                                              "width"] *
                                                          pr.Provider.of<Map>(
                                                                  context)[
                                                              "iconSize"] /
                                                          4,
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        : LoadingAnimation(),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width * 0.025),
                      child: Material(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(28),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          highlightColor: Colors.grey.withOpacity(0.2),
                          onTap: () {
                            return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    backgroundColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    title: Text(
                                      "Send?",
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
                                            DocumentReference reference =
                                                Firestore.instance
                                                    .collection("users")
                                                    .document(widget.teacherID)
                                                    .collection("classrooms")
                                                    .document(
                                                        "createdClassrooms")
                                                    .collection(
                                                        widget.classroomId)
                                                    .document("taskExecution");
                                            Firestore.instance
                                                .runTransaction((tn) async {
                                              DocumentSnapshot snapshot =
                                                  await tn.get(reference);
                                              List listConversion = snapshot
                                                  .data[taskStreamData[
                                                          "currentTask"]
                                                      .toString()]
                                                  .toList();
                                              listConversion.add(widget.userID);
                                              //set or update
                                              await tn.set(
                                                  reference
                                                      .collection(widget.userID)
                                                      .document(taskStreamData[
                                                              "currentTask"]
                                                          .toString()),
                                                  {
                                                    "studentAnswers":
                                                        studentAnswers,
                                                    "isFinished": true
                                                  });
                                              await tn.update(reference, {
                                                taskStreamData["currentTask"]
                                                    .toString(): listConversion
                                              });
                                            });
                                            print(studentAnswers);
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
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28)),
                            width: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"],
                            height: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] /
                                2,
                            child: Center(
                              child: AutoSizeTextWidget(
                                width: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    2.7,
                                text: "Send",
                                fontWeight: FontWeight.w400,
                                textColor: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ])
            : Center(
                child: AutoSizeTextWidget(
                  text: "Teacher hasn't chosen a task yet",
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
              );
  }

  TextEditingController ted = TextEditingController();
  PageController pgcTrue = PageController(initialPage: 1);
  PageController pgcFalse = PageController(initialPage: 0);
  GlobalKey<ScaffoldState> mainScaffState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mainScaffState,
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: _classroomReturner(),
      ),
    );
  }
}

class FinishedStudentList extends StatefulWidget {
  final String taskID;
  final String userID;
  final String classroomID;
  final List answerFields;
  FinishedStudentList(
      {@required this.taskID,
      @required this.answerFields,
      @required this.userID,
      @required this.classroomID});

  @override
  State<StatefulWidget> createState() {
    return FSL();
  }
}

class FSL extends State<FinishedStudentList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _streamCreator());
  }

  _streamCreator() {
    setState(() {
      stream = Firestore.instance
          .collection("users")
          .document(widget.userID)
          .collection("classrooms")
          .document("createdClassrooms")
          .collection(widget.classroomID)
          .document("taskExecution")
          .snapshots();
    });
    stream.listen(_streamReciever());
  }

  _streamReciever() {
    stream.forEach((c) {
      setState(() {
        streamData = c.data;
      });
    });
  }

  Map streamData;
  Stream stream;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: streamData == null
                ? Center(
                    child: LoadingAnimation(),
                  )
                : streamData[widget.taskID].isEmpty
                    ? Center(
                        child: AutoSizeTextWidget(
                        width: MediaQuery.of(context).size.width * 0.8,
                        text: "No students finished this task",
                      ))
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: streamData[widget.taskID].length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    10,
                                bottom: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    10),
                            child: Align(
                              alignment: Alignment.center,
                              child: Material(
                                color: Theme.of(context).secondaryHeaderColor,
                                elevation: 3,
                                borderRadius: BorderRadius.circular(15),
                                child: InkWell(
                                  onTap: () =>
                                      Navigator.of(context).push(FadeRoute(
                                          page: AnsweredTaskObserver(
                                    userID: widget.userID,
                                    taskID: widget.taskID,
                                    classroomID: widget.classroomID,
                                    answerFields: widget.answerFields,
                                    studentID: streamData[widget.taskID][i],
                                  ))),
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.2))),
                                    height: MediaQuery.of(context).size.width *
                                        pr.Provider.of<Map>(context)["width"] *
                                        pr.Provider.of<Map>(
                                            context)["iconSize"] *
                                        0.65,
                                    width: MediaQuery.of(context).size.width *
                                            pr.Provider.of<Map>(
                                                context)["width"] *
                                            2 +
                                        (MediaQuery.of(context).size.width -
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    pr.Provider.of<Map>(
                                                        context)["width"] *
                                                    2) /
                                            3,
                                    child: Center(
                                      child: StreamBuilder(
                                          stream: Firestore.instance
                                              .collection("users")
                                              .document(
                                                  streamData[widget.taskID][i])
                                              .snapshots(),
                                          builder: (context, snap) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                SvgPicture.asset(
                                                  snap.data["avatar"],
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      pr.Provider.of<Map>(
                                                          context)["width"] *
                                                      pr.Provider.of<Map>(
                                                          context)["iconSize"] *
                                                      0.65,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      pr.Provider.of<Map>(
                                                          context)["width"] *
                                                      pr.Provider.of<Map>(
                                                          context)["iconSize"] *
                                                      0.65,
                                                ),
                                                AutoSizeTextWidget(
                                                  text: snap.data["name"] +
                                                      " " +
                                                      snap.data["surname"],
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      pr.Provider.of<Map>(
                                                          context)["width"] *
                                                      pr.Provider.of<Map>(
                                                          context)["iconSize"] /
                                                      3.5,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      pr.Provider.of<Map>(
                                                          context)["width"] *
                                                      pr.Provider.of<Map>(
                                                          context)["iconSize"] *
                                                      2,
                                                ),
                                              ],
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )),
      ),
    );
  }
}

class AnsweredTaskObserver extends StatefulWidget {
  final String userID;
  final String classroomID;
  final String taskID;
  final String studentID;
  final List answerFields;
  AnsweredTaskObserver(
      {@required this.userID,
      @required this.studentID,
      @required this.taskID,
      @required this.classroomID,
      @required this.answerFields});
  @override
  State<StatefulWidget> createState() {
    return _ATO();
  }
}

class _ATO extends State<AnsweredTaskObserver> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _streamCreator());
  }

  Stream answerStream;
  _streamCreator() {
    setState(() {
      int c = widget.answerFields.length;
      while (c != 0) {
        textFieldControllerList.add(TextEditingController());
        c--;
      }
      answerStream = Firestore.instance
          .collection("users")
          .document(widget.userID)
          .collection("classrooms")
          .document("createdClassrooms")
          .collection(widget.classroomID)
          .document("taskExecution")
          .collection(widget.studentID)
          .document(widget.taskID)
          .snapshots();
    });
    answerStream.listen(_streamProcessor());
  }

  _streamProcessor() {
    answerStream.forEach((c) {
      setState(() {
        studentAnswers = c.data;
      });
      int ccn = widget.answerFields.length - 1;
      while (ccn != -1) {
        if (widget.answerFields[ccn]["unrestricted"]) {
          setState(() {
            textFieldControllerList[ccn].text =
                studentAnswers["studentAnswers"][ccn];
          });
        }
        ccn--;
      }
    });
  }

  List textFieldControllerList = [];
  Map studentAnswers;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: answerStream == null
            ? LoadingAnimation()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: studentAnswers["studentAnswers"].length,
                        itemBuilder: (context, i) {
                          if (widget.answerFields[i]["unrestricted"]) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width *
                                      pr.Provider.of<Map>(context)["width"] *
                                      pr.Provider.of<Map>(context)["iconSize"] /
                                      10),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        pr.Provider.of<Map>(
                                            context)["textFieldWidth"],
                                    child: TextField(
                                      controller: textFieldControllerList[i],
                                      readOnly: true,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Theme.of(context)
                                              .bottomAppBarColor),
                                      decoration: InputDecoration(
                                        fillColor: Colors.transparent,
                                        filled: true,
                                        labelText: (i + 1).toString(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              28 / 3.16666666666),
                                        ),
                                      ),
                                    ),
                                  )),
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width *
                                      pr.Provider.of<Map>(context)["width"] *
                                      pr.Provider.of<Map>(context)["iconSize"] /
                                      10),
                              child: ExpansionTile(
                                title: Text(
                                  (i + 1).toString(),
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).bottomAppBarColor),
                                ),
                                children: <Widget>[
                                  Container(
                                    height: (widget.answerFields[i]["fieldData"]
                                                .length *
                                            (MediaQuery.of(context).size.width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] /
                                                2))
                                        .toDouble(),
                                    child: ListView.builder(
                                      itemCount: widget
                                          .answerFields[i]["fieldData"].length,
                                      itemBuilder: (context, b) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              pr.Provider.of<Map>(
                                                  context)["width"] *
                                              pr.Provider.of<Map>(
                                                  context)["iconSize"] /
                                              2,
                                          child: Row(
                                            children: <Widget>[
                                              Theme(
                                                data: ThemeData(
                                                    unselectedWidgetColor:
                                                        Theme.of(context)
                                                            .primaryColor),
                                                child: Checkbox(
                                                  checkColor: Theme.of(context)
                                                      .primaryColorDark,
                                                  value: studentAnswers[
                                                          "studentAnswers"][i]
                                                      ["data"][b],
                                                  activeColor: Theme.of(context)
                                                      .primaryColor,
                                                  onChanged: (bb) {},
                                                ),
                                              ),
                                              AutoSizeTextWidget(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                text: widget.answerFields[i]
                                                    ["fieldData"][b],
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    pr.Provider.of<Map>(
                                                        context)["width"] *
                                                    pr.Provider.of<Map>(
                                                        context)["iconSize"] /
                                                    4,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ]),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final imageUrl;
  final bool isPreview;
  ImageViewer({@required this.imageUrl, @required this.isPreview});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: PhotoView(
            heroTag: imageUrl,
            minScale: PhotoViewComputedScale.contained,
            maxScale: 1.5,
            imageProvider:
                isPreview ? FileImage(imageUrl) : NetworkImage(imageUrl),
          ),
        ),
      ),
    );
  }
}

class VideoView extends StatefulWidget {
  final String videoUrl;
  VideoView({@required this.videoUrl});

  _Vd createState() => _Vd();
}

class _Vd extends State<VideoView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
//   VideoPlayerController _controller;
//   Future<void> _initializeVideoPlayerFuture;

//   @override
//   void initState() {
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeRight]);
//     _controller = VideoPlayerController.network(
//       widget.videoUrl,
//     );

//     _initializeVideoPlayerFuture = _controller.initialize();

//     // Use the controller to loop the video.
//     _controller.setLooping(false);

//     super.initState();
//   }

//   @override
//   void dispose() {
//     // Ensure disposing of the VideoPlayerController to free up resources.
//     _controller.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: FutureBuilder(
//         future: _initializeVideoPlayerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Center(
//               child: AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               ),
//             );
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Wrap the play or pause in a call to `setState`. This ensures the
//           // correct icon is shown.
//           setState(() {
//             // If the video is playing, pause it.
//             if (_controller.value.isPlaying) {
//               _controller.pause();
//             } else {
//               // If the video is paused, play it.
//               _controller.play();
//             }
//           });
//         },
//         // Display the correct icon depending on the state of the player.
//         child: Icon(
//           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//         ),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
}

class TecherStudentAdd extends StatefulWidget {
  final String teacherID;
  final String classroomID;
  TecherStudentAdd(
      {Key key, @required this.teacherID, @required this.classroomID});
  @override
  _TSA createState() => _TSA();
}

class _TSA extends State<TecherStudentAdd> {
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
    DocumentSnapshot addedStudents = await Firestore.instance
        .collection("users")
        .document(widget.teacherID)
        .collection("classrooms")
        .document("createdClassrooms")
        .collection(widget.classroomID)
        .document("classroomData")
        .get();
    var addedStudentList = addedStudents.data["invitedStudents"].toList();
    for (String student in studentList) {
      if (student == widget.teacherID) {
      } else if (addedStudentList.contains(student)) {
      } else {
        DocumentSnapshot snap = await Firestore.instance
            .collection("users")
            .document(student)
            .get();
        dsList.add(snap);
      }
    }
    setState(() {
      counter = dsList.length;
      trueFasleList = List.filled(counter, false);
      isLoading = false;
    });
  }

  bool isLoading = true;
  List dsList = [];
  List selectedStudents = [];
  static int counter;
  List trueFasleList = [];
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
          crossFadeState:
              isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 100),
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
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] /
                          10,
                      bottom: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] /
                          10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                2 +
                            (MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width *
                                        pr.Provider.of<Map>(context)["width"] *
                                        2) /
                                3,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SvgPicture.asset(
                              dsList[i]["avatar"],
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  2,
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  2,
                            ),
                            AutoSizeTextWidget(
                              text: dsList[i]["name"] +
                                  " " +
                                  dsList[i]["surname"],
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] *
                                  1.5,
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  4.3,
                            ),
                            Theme(
                              data: ThemeData(
                                  unselectedWidgetColor:
                                      Theme.of(context).primaryColor),
                              child: Checkbox(
                                checkColor: Theme.of(context).primaryColorDark,
                                value: trueFasleList[i],
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (b) {
                                  setState(() {
                                    if (trueFasleList[i]) {
                                      trueFasleList[i] = false;
                                      selectedStudents.remove(dsList[i]["id"]);
                                    } else {
                                      trueFasleList[i] = true;
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
            ),
          ),
        )));
  }
}

class TaskCreate extends StatefulWidget {
  final bool isDraft;
  final String teacherID;
  final String classroomID;
  TaskCreate(
      {@required this.isDraft, @required this.teacherID, this.classroomID});
  @override
  _Tc createState() => _Tc();
}

class _Tc extends State<TaskCreate> {
  _imageAttach() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var data = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ImgCrop(
                image: image,
              )));
      imagesToUpload.add(data);
    } else if (image == null) {}
  }

  _draftCreator() async {
    List imageUrls = [];
    if (imagesToUpload.isNotEmpty) {
      for (var image in imagesToUpload) {
        String rndstring = randomAlphaNumeric(10);
        var reference = FirebaseStorage.instance
            .ref()
            .child("images")
            .child(widget.teacherID)
            .child(rndstring);
        StorageUploadTask task = reference.putFile(image);
        await task.onComplete;
        String url = await reference.getDownloadURL();
        imageUrls.add(url);
      }
    }
    await Firestore.instance
        .collection("users")
        .document(widget.teacherID)
        .collection("taskDrafts")
        .document(nameOfTheTask)
        .setData({
      "taskName": nameOfTheTask,
      "note": note,
      "answerFields": answerFields,
      "imagesUrls": imageUrls,
      "time": DateTime.now().toUtc().toIso8601String(),
      "timeOrder": DateTime.now()
    });
    Navigator.of(context).pop();
  }

  _liveCreator() async {
    List imageUrls = [];
    if (imagesToUpload.isNotEmpty) {
      for (var image in imagesToUpload) {
        String rndstring = randomAlphaNumeric(10);
        var reference = FirebaseStorage.instance
            .ref()
            .child("images")
            .child(widget.teacherID)
            .child(rndstring);
        StorageUploadTask task = reference.putFile(image);
        await task.onComplete;
        String url = await reference.getDownloadURL();
        imageUrls.add(url);
      }
    }
    Firestore.instance.runTransaction((tn) async {
      CollectionReference reference = Firestore.instance
          .collection("users")
          .document(widget.teacherID)
          .collection("classrooms")
          .document("createdClassrooms")
          .collection(widget.classroomID);
      DocumentSnapshot snapshot = await tn.get(reference.document("tasks"));
      var taskList = snapshot.data["tasks"].toList();
      taskList.add({
        "taskName": nameOfTheTask,
        "note": note,
        "answerFields": answerFields,
        "imagesUrls": imageUrls
      });
      await tn.update(reference.document("tasks"), {"tasks": taskList});
      await tn.update(reference.document("taskExecution"),
          {(taskList.length - 1).toString(): []});
    });
    Navigator.of(context).pop();
  }

  _validateField() {
    if (namekey.currentState.validate()) {
      setState(() {
        nameOfTheTask = controllerName.text;
      });
      return true;
    } else {
      return false;
    }
  }

  List imagesToUpload = [];
  var answerFields;
  String nameOfTheTask;
  String note;
  GlobalKey<FormState> namekey = GlobalKey<FormState>();
  TextEditingController controllerName = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    controllerName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.isDraft
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.done),
              onPressed: () {
                if (_validateField()) {
                  _draftCreator();
                }
              },
              tooltip: "Save task",
            )
          : FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: Center(
                child: Container(
                  child: SvgPicture.asset("assets/send_icon.svg",
                      color: Theme.of(context).primaryColorDark),
                ),
              ),
              tooltip: "Send task",
              onPressed: () {
                if (_validateField()) {
                  _liveCreator();
                }
              },
            ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    pr.Provider.of<Map>(context)["textFieldWidth"],
                child: Form(
                  key: namekey,
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    validator: (str) {
                      if (str.length == 0) {
                        return "Name of the task cannot be empty";
                      }
                    },
                    controller: controllerName,
                    cursorColor: Theme.of(context).primaryColor,
                    style: TextStyle(
                        color: Theme.of(context).bottomAppBarColor,
                        fontWeight: FontWeight.w300),
                    decoration: InputDecoration(
                        labelText: "Name of the task",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(28 / 3.16666666666)),
                        fillColor: Colors.transparent,
                        filled: true),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    pr.Provider.of<Map>(context)["textFieldWidth"],
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: Theme.of(context).primaryColor,
                  style: TextStyle(
                      color: Theme.of(context).bottomAppBarColor,
                      fontWeight: FontWeight.w300),
                  onChanged: (str) {
                    setState(() {
                      note = str;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: "Note",
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(28 / 3.16666666666)),
                      fillColor: Colors.transparent,
                      filled: true),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: "Add an Image",
                      child: Center(
                        child: Material(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(28),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: _imageAttach,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(28)),
                                height: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    2,
                                width: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    2,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Icon(
                                        Icons.add_photo_alternate,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] /
                                10),
                        child: AutoSizeTextWidget(
                          text: imagesToUpload.length != 0
                              ? (imagesToUpload.length.toString() +
                                  (imagesToUpload.length > 1
                                      ? " images"
                                      : " image") +
                                  " added")
                              : "",
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width *
                              pr.Provider.of<Map>(context)["width"] *
                              pr.Provider.of<Map>(context)["iconSize"] /
                              5.5,
                        ))
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: "Add answer fields",
                      child: Center(
                        child: Material(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(28),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: () async {
                                var data = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            answerFields == null
                                                ? AnswerFieldCreator()
                                                : AnswerFieldCreator(
                                                    previousData: answerFields,
                                                  )));
                                setState(() {
                                  answerFields = data;
                                });
                                print(answerFields);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(28)),
                                height: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    2,
                                width: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    2,
                                child: Center(
                                  child: Icon(
                                    Icons.format_list_bulleted,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] /
                                10),
                        child: AutoSizeTextWidget(
                          text: answerFields != null
                              ? (answerFields.length.toString() +
                                  (answerFields.length > 1
                                      ? " fields"
                                      : " field") +
                                  " added")
                              : "",
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width *
                              pr.Provider.of<Map>(context)["width"] *
                              pr.Provider.of<Map>(context)["iconSize"] /
                              5.5,
                        ))
                  ],
                ),
                // Tooltip(
                //   message: "Scan a Task",
                //   child: Center(
                //     child: Material(
                //       color: Theme.of(context).secondaryHeaderColor,
                //       borderRadius: BorderRadius.circular(28),
                //       child: InkWell(
                //           borderRadius: BorderRadius.circular(28),
                //           highlightColor: Colors.grey.withOpacity(0.2),
                //           onTap: () =>
                //               Navigator.of(context).push(MaterialPageRoute(
                //                   builder: (context) => ForkPicker(
                //                         isMlSearch: false,
                //                       ))),
                //           child: Container(
                //             decoration: BoxDecoration(
                //                 border: Border.all(
                //                     color: Theme.of(context).primaryColor),
                //                 borderRadius: BorderRadius.circular(28)),
                //             height: 50,
                //             width: 50,
                //             child: Center(
                //               child: Row(
                //                 mainAxisAlignment:
                //                     MainAxisAlignment.spaceEvenly,
                //                 children: <Widget>[
                //                   Icon(
                //                     Icons.format_size,
                //                     color: Theme.of(context).primaryColor,
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           )),
                //     ),
                //   ),
                // ),
              ],
            ),
            widget.isDraft
                ? Container()
                : Center(
                    child: Material(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          highlightColor: Colors.grey.withOpacity(0.2),
                          // onTap: () async {
                          //   var data = await Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => TaskCreate()));
                          // },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28)),
                            height: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] /
                                2,
                            width: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] *
                                1.7,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.cloud_upload,
                                    color: Theme.of(context).primaryColorDark,
                                    size: MediaQuery.of(context).size.width *
                                        pr.Provider.of<Map>(context)["width"] *
                                        pr.Provider.of<Map>(
                                            context)["iconSize"] *
                                        0.24,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.01),
                                    child: AutoSizeTextWidget(
                                      text: "Upload from draft",
                                      textColor:
                                          Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w400,
                                      width: MediaQuery.of(context).size.width *
                                          pr.Provider.of<Map>(
                                              context)["width"] *
                                          pr.Provider.of<Map>(
                                              context)["iconSize"] *
                                          1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
            Center(
              child: Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  onTap: () {
                    if (_validateField()) {
                      Navigator.of(context).push(FadeRoute(
                          page: TaskPreview(
                        isFromCreatedDraft: false,
                        taskName: nameOfTheTask,
                        note: note,
                        images: imagesToUpload,
                        answerFields: answerFields,
                      )));
                    }
                  },
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(28)),
                    height: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] /
                        2,
                    width: MediaQuery.of(context).size.width *
                        pr.Provider.of<Map>(context)["width"] *
                        pr.Provider.of<Map>(context)["iconSize"] *
                        1.2,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] *
                                0.24,
                            height: MediaQuery.of(context).size.width *
                                pr.Provider.of<Map>(context)["width"] *
                                pr.Provider.of<Map>(context)["iconSize"] *
                                0.24,
                            child: SvgPicture.asset(
                              "assets/art_track_icon.svg",
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.01),
                            child: AutoSizeTextWidget(
                              text: "Preview",
                              width: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  2,
                              height: MediaQuery.of(context).size.width *
                                  pr.Provider.of<Map>(context)["width"] *
                                  pr.Provider.of<Map>(context)["iconSize"] /
                                  2,
                              textColor: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TxtRec extends StatefulWidget {
  final imageSource;
  TxtRec({@required this.imageSource});
  _TxtRc createState() => _TxtRc();
}

class _TxtRc extends State<TxtRec> {
  //TODO: Run a recognition fucntion.
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class AnswerFieldCreator extends StatefulWidget {
  final previousData;
  AnswerFieldCreator({this.previousData});
  @override
  AFC createState() => AFC();
}

class AFC extends State<AnswerFieldCreator> {
  // @override
  // void initState() {
  //   super.initState();
  //   setState(() {
  //     counterController.text = counterField.toString();
  //   });
  // }

  // _counterChange() {
  //   int newCounter = int.parse(counterController.text);
  //   if (counterField > newCounter) {
  //     while (counterField != newCounter) {
  //       setState(() {
  //         counterField--;
  //       });
  //       animLitsKey.currentState.removeItem(
  //           counterField,
  //           (context, anim) => FadeTransition(
  //                 opacity: anim,
  //               ));
  //     }
  //     if (counterField == newCounter) {
  //       setState(() {
  //         counterField = int.parse(counterController.text);
  //       });
  //     }
  //   } else if (counterField < newCounter) {
  //     while (counterField != newCounter) {
  //       animLitsKey.currentState.insertItem(
  //         counterField,
  //       );
  //       setState(() {
  //         counterField++;
  //       });
  //     }
  //     if (counterField == newCounter) {
  //       setState(() {
  //         counterField = int.parse(counterController.text);
  //       });
  //     }
  //   }
  // }

  _dataSender() {
    Navigator.pop(context, dataList);
  }

  @override
  void dispose() {
    super.dispose();
    counterController.dispose();
  }

  _answerFieldAdd() {
    setState(() {
      animatedListList.add(GlobalKey<AnimatedListState>());
      dataList.add({
        "unrestricted": true,
        "big": false,
        "selection": false,
        "fieldData": [""]
      });
    });
  }

  List animatedListList = [];
  List dataList = [];

  // int counterField = 0;
  TextEditingController counterController = TextEditingController();
  GlobalKey<AnimatedListState> animLitsKey = GlobalKey<AnimatedListState>();
  var animationDuration = Duration(milliseconds: 300);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: dataList.length == 0
          ? null
          : FloatingActionButton(
              onPressed: _dataSender,
              child: SvgPicture.asset("assets/done_icon.svg",
                  color: Theme.of(context).primaryColorDark),
              backgroundColor: Theme.of(context).primaryColor,
              tooltip: "Save",
            ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.width *
                  pr.Provider.of<Map>(context)["width"] *
                  pr.Provider.of<Map>(context)["iconSize"] *
                  0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    tooltip: "Remove",
                    onPressed: () {
                      if (dataList.length > 0) {
                        animLitsKey.currentState.removeItem(dataList.length - 1,
                            (context, animation) => Container(),
                            duration: animationDuration);
                        setState(() {
                          dataList.removeAt(dataList.length - 1);
                        });
                      }

                      // if (counterField > 0) {
                      //   setState(() {
                      //     counterField--;
                      //   });
                      //   animLitsKey.currentState.removeItem(
                      //       counterField,
                      //       (context, anim) => FadeTransition(
                      //             opacity: anim,
                      //           ));
                      //   setState(() {
                      //     counterController.text = counterField.toString();
                      //   });
                      // } else {}
                    },
                    icon: Container(
                      width: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] *
                          0.34,
                      height: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] *
                          0.34,
                      child: SvgPicture.asset("assets/round-remove-24px.svg",
                          color: Theme.of(context).bottomAppBarColor),
                    ),
                    iconSize: 34,
                  ),
                  Container(
                    child: TextField(
                      controller: TextEditingController(
                          text: dataList.length.toString()),
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).bottomAppBarColor,
                          fontSize: 23),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      cursorColor: Theme.of(context).primaryColor,
                    ),
                    width: 100,
                  ),
                  IconButton(
                    tooltip: "Add",
                    onPressed: () {
                      _answerFieldAdd();
                      animLitsKey.currentState.insertItem(dataList.length - 1);
                    },
                    icon: Container(
                      width: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] *
                          0.34,
                      height: MediaQuery.of(context).size.width *
                          pr.Provider.of<Map>(context)["width"] *
                          pr.Provider.of<Map>(context)["iconSize"] *
                          0.34,
                      child: SvgPicture.asset("assets/round-add-24px.svg",
                          color: Theme.of(context).bottomAppBarColor),
                    ),
                    iconSize: 34,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: AnimatedList(
                  physics: BouncingScrollPhysics(),
                  key: animLitsKey,
                  itemBuilder: (context, index, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: ((MediaQuery.of(context).size.width -
                                      2 *
                                          (pr.Provider.of<Map>(
                                                  context)["width"] *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width)) /
                                  3)),
                          child: Material(
                              borderRadius: BorderRadius.circular(28),
                              elevation: 5,
                              child: AnimatedContainer(
                                  duration: animationDuration,
                                  width: ((MediaQuery.of(context).size.width -
                                              ((MediaQuery.of(context).size.width * pr.Provider.of<Map>(context)["width"]) *
                                                  2)) /
                                          3) +
                                      ((MediaQuery.of(context).size.width * pr.Provider.of<Map>(context)["width"]) *
                                          2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                  height: dataList[index]["unrestricted"]
                                      ? MediaQuery.of(context).size.width *
                                          pr.Provider.of<Map>(
                                              context)["width"] *
                                          pr.Provider.of<Map>(
                                              context)["iconSize"]
                                      : MediaQuery.of(context).size.width *
                                              pr.Provider.of<Map>(
                                                  context)["width"] *
                                              pr.Provider.of<Map>(context)["iconSize"] *
                                              1.5 +
                                          dataList[index]["fieldData"].length * 70 +
                                          15,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          AutoSizeTextWidget(
                                            text: (index + 1).toString(),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                8,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              AutoSizeTextWidget(
                                                text: "Restricted",
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    6,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    15,
                                              ),
                                              Switch(
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                inactiveTrackColor: Colors.grey,
                                                value: dataList[index]
                                                    ["unrestricted"],
                                                onChanged: (b) {
                                                  setState(() {
                                                    dataList[index]
                                                        ["unrestricted"] = b;
                                                  });
                                                },
                                              ),
                                              AutoSizeTextWidget(
                                                text: "Unrestricted",
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    5,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    15,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      dataList[index]["unrestricted"]
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Theme(
                                                  data: ThemeData(
                                                      unselectedWidgetColor:
                                                          Theme.of(context)
                                                              .primaryColor),
                                                  child: Checkbox(
                                                    checkColor:
                                                        Theme.of(context)
                                                            .primaryColorDark,
                                                    value: dataList[index]
                                                        ["big"],
                                                    activeColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    onChanged: (b) {
                                                      setState(() {
                                                        dataList[index]["big"] =
                                                            b;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                AutoSizeTextWidget(
                                                  text: "Big textfield",
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      20,
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Theme(
                                                      data: ThemeData(
                                                          unselectedWidgetColor:
                                                              Theme.of(context)
                                                                  .primaryColor),
                                                      child: Checkbox(
                                                        checkColor: Theme.of(
                                                                context)
                                                            .primaryColorDark,
                                                        value: dataList[index]
                                                            ["selection"],
                                                        activeColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onChanged: (b) {
                                                          setState(() {
                                                            dataList[index][
                                                                "selection"] = b;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    AutoSizeTextWidget(
                                                      text:
                                                          "Multiple selection",
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              15,
                                                    ),
                                                  ],
                                                ),
                                                AnimatedContainer(
                                                  duration: animationDuration,
                                                  height: dataList[index]
                                                              ["fieldData"]
                                                          .length *
                                                      70.0,
                                                  child: AnimatedList(
                                                      key: animatedListList[
                                                          index],
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      initialItemCount:
                                                          dataList[index]
                                                                  ["fieldData"]
                                                              .length,
                                                      itemBuilder: (context, i,
                                                          animation) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.0),
                                                            child: Center(
                                                                child:
                                                                    Container(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.65,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              TextField(
                                                                            onChanged:
                                                                                (data) {
                                                                              setState(() {
                                                                                dataList[index]["fieldData"][i] = data;
                                                                              });
                                                                            },
                                                                            cursorColor:
                                                                                Theme.of(context).primaryColor,
                                                                            style:
                                                                                TextStyle(color: Theme.of(context).bottomAppBarColor),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              fillColor: Colors.transparent,
                                                                              filled: true,
                                                                              labelText: (i + 1).toString(),
                                                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28 / 3.16666666666)),
                                                                            ),
                                                                          ),
                                                                        ))),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                                Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      IconButton(
                                                        icon: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] /
                                                              2,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] /
                                                              2,
                                                          child: SvgPicture.asset(
                                                              "assets/round-remove-24px.svg",
                                                              color: Theme.of(
                                                                      context)
                                                                  .bottomAppBarColor),
                                                        ),
                                                        iconSize: 50,
                                                        onPressed: () async {
                                                          if (dataList[index][
                                                                      "fieldData"]
                                                                  .length ==
                                                              1) {
                                                            setState(() {
                                                              dataList[index][
                                                                      "unrestricted"] =
                                                                  true;
                                                              dataList[index][
                                                                      "fieldData"]
                                                                  [0] = "";
                                                            });
                                                          } else {
                                                            animatedListList[index]
                                                                .currentState
                                                                .removeItem(
                                                                    dataList[index]["fieldData"]
                                                                            .length -
                                                                        1,
                                                                    (context,
                                                                            animation) =>
                                                                        FadeTransition(
                                                                          opacity:
                                                                              animation,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.only(top: 10.0),
                                                                            child: Center(
                                                                                child: Container(
                                                                                    width: MediaQuery.of(context).size.width * 0.65,
                                                                                    child: Center(
                                                                                      child: TextField(
                                                                                        controller: TextEditingController(text: dataList[index]["fieldData"][dataList[index]["fieldData"].length - 1]),
                                                                                        cursorColor: Theme.of(context).primaryColor,
                                                                                        style: TextStyle(color: Theme.of(context).bottomAppBarColor),
                                                                                        decoration: InputDecoration(
                                                                                          fillColor: Colors.transparent,
                                                                                          filled: true,
                                                                                          labelText: (dataList[index]["fieldData"].length).toString(),
                                                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28 / 3.16666666666)),
                                                                                        ),
                                                                                      ),
                                                                                    ))),
                                                                          ),
                                                                        ),
                                                                    duration:
                                                                        animationDuration);
                                                            await Future.delayed(
                                                                animationDuration);
                                                            setState(() {
                                                              dataList[index][
                                                                      "fieldData"]
                                                                  .removeAt(dataList[index]
                                                                              [
                                                                              "fieldData"]
                                                                          .length -
                                                                      1);
                                                            });
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] /
                                                              2,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "width"] *
                                                              pr.Provider.of<
                                                                          Map>(
                                                                      context)[
                                                                  "iconSize"] /
                                                              2,
                                                          child: SvgPicture.asset(
                                                              "assets/round-add-24px.svg",
                                                              color: Theme.of(
                                                                      context)
                                                                  .bottomAppBarColor),
                                                        ),
                                                        iconSize: 50,
                                                        onPressed: () {
                                                          setState(() {
                                                            dataList[index][
                                                                    "fieldData"]
                                                                .add("");
                                                          });
                                                          animatedListList[
                                                                  index]
                                                              .currentState
                                                              .insertItem(
                                                                  dataList[index]
                                                                              [
                                                                              "fieldData"]
                                                                          .length -
                                                                      1,
                                                                  duration:
                                                                      animationDuration);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                    ],
                                  ))),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TaskDrafts extends StatelessWidget {
  _dateReturner(String date) {
    String day = DateTime.tryParse(date).toLocal().day.toString();
    String month = DateTime.tryParse(date).toLocal().month.toString();
    String year = DateTime.tryParse(date).toLocal().year.toString();
    String hour = DateTime.tryParse(date).toLocal().hour.toString();
    String minute = DateTime.tryParse(date).toLocal().minute.toString();
    if (day.length == 1) {
      day = "0" + day;
    }
    if (month.length == 1) {
      month = "0" + month;
    }
    if (minute.length == 1) {
      minute = "0" + minute;
    }
    if (hour.length == 1) {
      hour = "0" + hour;
    }
    return "$day.$month.$year at $hour:$minute";
  }

  final String teacherID;
  TaskDrafts({@required this.teacherID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Create New Draft",
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                TaskCreate(teacherID: teacherID, isDraft: true))),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection("users")
                .document(teacherID)
                .collection("taskDrafts")
                .orderBy("timeOrder")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, i) {
                    return Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 80,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                            width: 0.7),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(28))),
                                    height: 190,
                                    child: Material(
                                        elevation: 5,
                                        borderRadius: BorderRadius.circular(28),
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        child: InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                FadeRoute(
                                                    page: TaskPreview(
                                                  isFromCreatedDraft: true,
                                                  taskName: snapshot.data
                                                      .documents[i]["taskName"],
                                                  note: snapshot.data
                                                      .documents[i]["note"],
                                                  answerFields:
                                                      snapshot.data.documents[i]
                                                          ["answerFields"],
                                                  images:
                                                      snapshot.data.documents[i]
                                                          ["imagesUrls"],
                                                ))),
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            highlightColor:
                                                Colors.grey.withOpacity(0.2),
                                            child: Center(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                  Center(
                                                    child: Text(
                                                      snapshot.data.documents[i]
                                                          ["taskName"],
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .bottomAppBarColor,
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            13.0),
                                                    child: Text(
                                                      "Created:",
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .bottomAppBarColor,
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Text(
                                                    _dateReturner(
                                                      snapshot.data.documents[i]
                                                          ["time"],
                                                    ),
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .bottomAppBarColor,
                                                        fontSize: 20),
                                                  )
                                                ]))))))));
                  },
                );
              } else {
                return Container();
              }
            }),
      ),
    );
  }
}

class TaskPreview extends StatefulWidget {
  final String taskName;
  final String note;
  final List images;
  final List answerFields;
  final bool isFromCreatedDraft;
  TaskPreview(
      {@required this.taskName,
      this.note,
      this.images,
      this.answerFields,
      @required this.isFromCreatedDraft});

  @override
  State<StatefulWidget> createState() {
    return _TaskPrw();
  }
}

class _TaskPrw extends State<TaskPreview> {
  @override
  void initState() {
    super.initState();
    if (widget.answerFields != null) {
      setState(() {
        checkList =
            List.filled(widget.answerFields.length, List.filled(250, false));
      });
    }
  }

  List checkList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
                child: Text(
              widget.taskName,
              style: TextStyle(
                  color: Theme.of(context).bottomAppBarColor, fontSize: 20),
            )),
            widget.note != null
                ? Text(
                    widget.note,
                    style: TextStyle(
                        color: Theme.of(context).bottomAppBarColor,
                        fontSize: 18),
                  )
                : Container(),
            widget.images.isNotEmpty
                ? Container(
                    height: 300,
                    child: PageView.builder(
                      itemCount: widget.images.length,
                      itemBuilder: (context, i) {
                        return Container(
                          height: 300,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(FadeRoute(
                                page: ImageViewer(
                              imageUrl: widget.images[i],
                              isPreview:
                                  widget.isFromCreatedDraft ? false : true,
                            ))),
                            child: Hero(
                              tag: "chat_image",
                              child: widget.isFromCreatedDraft
                                  ? Image.network(
                                      widget.images[i],
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: LoadingAnimation(),
                                        );
                                      },
                                      fit: BoxFit.contain,
                                    )
                                  : Image.file(
                                      widget.images[i],
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
            widget.answerFields != null
                ? Expanded(
                    child: ListView.builder(
                      itemCount: widget.answerFields.length,
                      itemBuilder: (context, i) {
                        if (widget.answerFields[i]["unrestricted"]) {
                          return Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 80,
                                  child: TextField(
                                    cursorColor: Theme.of(context).primaryColor,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .bottomAppBarColor),
                                    decoration: InputDecoration(
                                        fillColor: Colors.transparent,
                                        filled: true,
                                        labelText: (i + 1).toString(),
                                        border: OutlineInputBorder()),
                                  ),
                                )),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: ExpansionTile(
                              title: Text(
                                (i + 1).toString(),
                                style: TextStyle(
                                    color: Theme.of(context).bottomAppBarColor),
                              ),
                              children: <Widget>[
                                Container(
                                  height: (widget.answerFields[i]["fieldData"]
                                              .length *
                                          70)
                                      .toDouble(),
                                  child: ListView.builder(
                                    itemCount: widget
                                        .answerFields[i]["fieldData"].length,
                                    itemBuilder: (context, b) {
                                      return Container(
                                        height: 70,
                                        child: Row(
                                          children: <Widget>[
                                            Checkbox(
                                              value: checkList[i][b],
                                              onChanged: (bl) {
                                                setState(() {
                                                  checkList[i] =
                                                      List.filled(250, false);
                                                });
                                                checkList[i][b] = bl;
                                              },
                                            ),
                                            Text(
                                              widget.answerFields[i]
                                                  ["fieldData"][b],
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .bottomAppBarColor),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class StudentAntiCheatList extends StatelessWidget {
  final userID;
  final classroomID;
  StudentAntiCheatList({@required this.classroomID, @required this.userID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(userID)
              .collection("classrooms")
              .document("createdClassrooms")
              .collection(classroomID)
              .document("studentListener")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data["studentList"].length,
                itemBuilder: (BuildContext context, int i) {
                  return StreamBuilder(
                      stream: Firestore.instance
                          .collection("users")
                          .document(snapshot.data["studentList"][i])
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.active) {
                          return Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
                                    10,
                                bottom: MediaQuery.of(context).size.width *
                                    pr.Provider.of<Map>(context)["width"] *
                                    pr.Provider.of<Map>(context)["iconSize"] /
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
                                        pr.Provider.of<Map>(context)["width"] *
                                        pr.Provider.of<Map>(
                                            context)["iconSize"] *
                                        0.65,
                                    width: MediaQuery.of(context).size.width *
                                            pr.Provider.of<Map>(
                                                context)["width"] *
                                            2 +
                                        (MediaQuery.of(context).size.width -
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    pr.Provider.of<Map>(
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] *
                                                0.65,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] *
                                                0.65,
                                          ),
                                          AutoSizeTextWidget(
                                            text: snap.data["name"] +
                                                " " +
                                                snap.data["surname"],
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] /
                                                3.5,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] *
                                                2,
                                          ),
                                          AutoSizeTextWidget(
                                            text: snapshot.data[snapshot
                                                            .data["studentList"]
                                                        [i]] ==
                                                    null
                                                ? "0"
                                                : snapshot.data[snapshot
                                                        .data["studentList"][i]]
                                                    .toString(),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] /
                                                3.5,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                pr.Provider.of<Map>(
                                                    context)["width"] *
                                                pr.Provider.of<Map>(
                                                    context)["iconSize"] /
                                                1.7,
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

class Timer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Tmr();
  }
}

class Tmr extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AutoSizeTextWidget(
                  height: 100,
                  width: MediaQuery.of(context).size.width / 6,
                  text: "00",
                ),
                AutoSizeTextWidget(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 12,
                  text: "h",
                ),
                AutoSizeTextWidget(
                    height: 100,
                    text: "00",
                    width: MediaQuery.of(context).size.width / 6),
                AutoSizeTextWidget(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 12,
                  text: "m",
                ),
                AutoSizeTextWidget(
                    height: 100,
                    text: "00",
                    width: MediaQuery.of(context).size.width / 6),
                AutoSizeTextWidget(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 12,
                  text: "s",
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "1",
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "4",
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "7",
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "2",
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "5",
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "8",
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "3",
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "8",
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: AutoSizeTextWidget(
                            width: 100,
                            height: 100,
                            text: "9",
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ],
                ),
                Center(
                  child: IconButton(
                    iconSize: 60,
                    icon: AutoSizeTextWidget(
                      width: 100,
                      height: 100,
                      text: "0",
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
