import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //show PlatformException;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_actions/quick_actions.dart';
// Needed classes
import 'quickClasses.dart';
import 'FavouritesClass.dart';
import 'WordOfTheDayClass.dart';
import 'HistoryClass.dart';
import 'SettingsClass.dart';
import 'SearchFieldRemainderClass.dart';
import 'StatsClass.dart';
import 'MLkitRecognitionClass.dart';
import 'StudentTeacherModeAdAndLogInClass.dart';
import 'StudentTeacherModeProfileClass.dart';
import 'package:quiver/async.dart';
//TODO: Complete FavouritesClass by using database integration for susbscribers only.
// Oxford API keys
// app_id  = "46575095";
// app_key  = "af0c3986a356cac82597f8cc25ebdb28";

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool isTesla = preferences.getBool("isTeslaActivated");
  bool isSpaceX = preferences.getBool("isSpaceXActivated");
  bool isDark = preferences.getBool("theme");
  bool isShortcutEnabled = preferences.getBool("isShortcutEnabled");
  if (isShortcutEnabled == null) {
    isShortcutEnabled = false;
    preferences.setBool("isShortcutEnabled", false);
  }
  if (isDark == null) {
    isDark = false;
    preferences.setBool("theme", false);
  }
  if (isTesla == null) {
    isTesla = false;
    preferences.setBool("isTeslaActivated", false);
  }
  if (isSpaceX == null) {
    isSpaceX = false;
    preferences.setBool("isSpaceXActivated", false);
  }
  if (isTesla) {
    isDark = false;
  }
  if (isSpaceX) {
    isDark = true;
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor:
        isDark || isSpaceX ? Color.fromRGBO(18, 18, 18, 1) : Colors.white,
    statusBarIconBrightness:
        isDark || isSpaceX ? Brightness.light : Brightness.dark,
    systemNavigationBarColor:
        isDark || isSpaceX ? Color.fromRGBO(18, 18, 18, 1) : Colors.white,
    systemNavigationBarIconBrightness:
        isDark || isSpaceX ? Brightness.light : Brightness.dark,
  ));
  runApp(Provider<Map>.value(
    value: {
      "iconSize": 0.6666666666666666,
      "textFieldWidth": 0.8055555555555556,
      "width": 0.3645833333333333,
      "height": 1.2666666666666666666666666666667
    },
    child: MyApp(
      isSpaceX: isSpaceX,
      isTesla: isTesla,
      isDark: isDark,
      isShortcutEnabled: isShortcutEnabled,
    ),
  ));
}

class MyApp extends StatefulWidget {
  final bool isSpaceX;
  final bool isTesla;
  final bool isDark;
  final bool isShortcutEnabled;
  MyApp({this.isSpaceX, this.isTesla, this.isDark, this.isShortcutEnabled});
  @override
  _MPAA createState() => _MPAA();
}

class _MPAA extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _themeGetter());
  }

  Color colorFg = Colors.white;
  Color colorBg = Colors.white;
  Color colorTextAndIcons = Colors.black;
  Color hintColor = Colors.grey;
  Color primaryColor = Colors.blue;
  _themeGetter() {
    if (widget.isDark == null || widget.isDark == false) {
      setState(() {
        colorFg = Colors.white;
        colorBg = Colors.white;
        colorTextAndIcons = Colors.black;
        hintColor = Colors.grey;
      });
    } else if (widget.isDark) {
      setState(() {
        colorBg = Color.fromRGBO(18, 18, 18, 1);
        colorFg = Color.fromRGBO(50, 50, 50, 1);
        colorTextAndIcons = Colors.white;
        primaryColor = Color.fromRGBO(110, 198, 255, 1);
        hintColor = Color.fromRGBO(110, 198, 255, 1);
      });
    }
    if (widget.isTesla) {
      setState(() {
        colorFg = Colors.white;
        colorBg = Colors.white;
        colorTextAndIcons = Colors.black;
        hintColor = Colors.red;
        primaryColor = Colors.red;
      });
    } else if (widget.isSpaceX) {
      setState(() {
        colorBg = Color.fromRGBO(18, 18, 18, 1);
        colorFg = Color.fromRGBO(50, 50, 50, 1);
        colorTextAndIcons = Colors.white;
        hintColor = Color.fromRGBO(207, 207, 207, 1);
        primaryColor = Color.fromRGBO(207, 207, 207, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionHandleColor: primaryColor,
        snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
        primaryColor: primaryColor,
        primaryColorDark: colorBg,
        secondaryHeaderColor: colorFg,
        bottomAppBarColor: colorTextAndIcons,
        hintColor: hintColor,
      ),
      //Android Q only
      /*darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColorDark: Color.fromRGBO(16, 16, 16, 1),
        secondaryHeaderColor:  Color.fromRGBO(50, 50, 50, 1),
      ),*/
      home: new Scaffold(
          body: MyHomePage(
        isSpaceX: widget.isSpaceX,
        isTesla: widget.isTesla,
        isShortcutEnabled: widget.isShortcutEnabled,
      )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isSpaceX;
  final bool isTesla;
  final bool isShortcutEnabled;
  MyHomePage(
      {@required this.isSpaceX,
      @required this.isTesla,
      this.isShortcutEnabled});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _shortcutInitilizer();
    setState(() {
      animationControllerPage2 = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
      animationControllerPage1 = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFieldCounter());
  }

  FirebaseMessaging messaging = FirebaseMessaging();
  _shortcutInitilizer() async {
    messaging.configure(onLaunch: (message) {});

    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'immidiate_search') {
        pageControllerMainVertical.jumpToPage(0);
        setState(() {
          FocusScope.of(context).requestFocus(nodeForSearch);
        });
      } else if (shortcutType == "favs") {
        Navigator.of(context).push(ShortcutRoute(page: Favs()));
      } else if (shortcutType == "classrooms_teacher") {
      } else if (shortcutType == "classrooms_student") {}
    });

    List<ShortcutItem> shortcutList = [
      ShortcutItem(
          type: 'immidiate_search', localizedTitle: 'Search', icon: "search"),
      ShortcutItem(type: 'favs', localizedTitle: 'Favourites', icon: "star")
    ];
    quickActions.setShortcutItems(shortcutList);
  }

  PageController pageControllerMainVertical = PageController(
    initialPage: 1,
  );

  /*_getWordDataWebster(String word) async {
    setState(() {
      isLoading_1 = true;
    });
    final rsp_pn = await http
        .get(
            "https://www.dictionaryapi.com/api/v3/references/collegiate/json/" +
                word.toLowerCase() +
                "?key=bcc8d128-e346-4242-aaf9-999b50db756a")
        .whenComplete(() {
      isLoading_1 = false;
    });
    print(rsp_pn.statusCode);
    List data_pn = json.decode(rsp_pn.body);
    print(data_pn[0]["def"][0]["sseq"][0][2]);
    String defintiton = data_pn[0]["def"][0]["sseq"][0][0][1]["dt"][0][1];
    print(defintiton);
  }*/

  //Needed lists below for search to work
  static int counter = 1000; //100000
  List<bool> focusList = List.filled(counter, false);
  List<bool> isLoadingList = new List<bool>.filled(counter, false);
  List<bool> isFailureList = new List<bool>.filled(counter, false);
  List<bool> isWaitingList = new List<bool>.filled(counter, true);
  List<String> wordTitleList = new List<String>.filled(counter, "");
  List<String> pronunList = new List<String>.filled(counter, "");
  List<String> etymologiesList = new List<String>.filled(counter, "");
  List<String> defTitleList = new List<String>.filled(counter, "");
  List pronunAudioWord = new List.filled(counter, "");
  List playButtonColorList = new List.filled(counter, Colors.transparent);
  List favsIconList = new List.filled(counter, Icons.star_border);
  List tabsList = new List.filled(counter, Text(""));
  AudioPlayer audioPlayer = new AudioPlayer();

  final appIdOxford = "46575095";
  final appKeyOxford = "af0c3986a356cac82597f8cc25ebdb28";

  bool isLoggedIn = false;
  bool isTeacher;
  String userID;
  Widget favsIcon;
  Widget historyIcon;
  bool isSpecial = false;
  String stmAvatar = "avatars_images/avatar-071.png";
  bool firstLaunch = true;
  bool focusField = false;
  bool isChekerLoading = false;
  bool isLiveEnabled;
  FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics();
  FocusNode nodeForSearch = FocusNode();
  _dimensionsInit() {
    setState(() {
      moveRightOff = ((MediaQuery.of(context).size.width / 3 +
              MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"]) /
          (MediaQuery.of(context).size.width *
              Provider.of<Map>(context)["width"]));
      moveCenterDownOff = ((((MediaQuery.of(context).size.width -
                          ((MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"]) *
                              2)) /
                      3) /
                  2 +
              ((MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"]) /
                  2)) /
          (MediaQuery.of(context).size.width *
              Provider.of<Map>(context)["width"] *
              Provider.of<Map>(context)["height"]));
      moveCenterRightOff = ((((MediaQuery.of(context).size.width -
                          ((MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"]) *
                              2)) /
                      3) /
                  2 +
              ((MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"]) /
                  2)) /
          (MediaQuery.of(context).size.width *
              Provider.of<Map>(context)["width"]));
      moveDownOff = ((MediaQuery.of(context).size.height / 2 -
              MediaQuery.of(context).size.width / 3 +
              (MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["height"])) /
          (MediaQuery.of(context).size.width *
              Provider.of<Map>(context)["width"] *
              Provider.of<Map>(context)["height"]));
    });
  }

  _searchFieldCounter() async {
    _dimensionsInit();
    SharedPreferences getter = await SharedPreferences.getInstance();
    setState(() {
      counter = getter.getInt("searchFieldCounter");
    });
    if (counter == null) {
      setState(() {
        counter = 2;
      });
      getter.setInt("searchFieldCounter", 2);
    }
    _isLoggedInChecker();
    if (widget.isTesla) {
      setState(() {
        historyIcon = SvgPicture.asset("assets/Elon_Musk_Signature.svg",
            color: Colors.red);
        favsIcon =
            SvgPicture.asset("assets/Tesla_T_symbol.svg", color: Colors.red);
        isSpecial = true;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool("isTeslaActivated", false);
    } else if (widget.isSpaceX) {
      setState(() {
        historyIcon = SvgPicture.asset("assets/Elon_Musk_Signature.svg",
            color: Color.fromRGBO(207, 207, 207, 1));
        favsIcon = SvgPicture.asset("assets/Falcon_9_logo.svg",
            color: Color.fromRGBO(207, 207, 207, 1));
        isSpecial = true;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool("isSpaceXActivated", false);
    }
  }

  _isLoggedInChecker() async {
    bool launch = firstLaunch;
    if (launch) {
      setState(() {
        isChekerLoading = true;
      });
    }
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if (user != null) {
      try {
        if (firstLaunch) {
          await user.reload();
          setState(() {
            firstLaunch = false;
          });
        }
        SharedPreferences data = await SharedPreferences.getInstance();
        String checker = data.getString("avatar_image");
        DocumentSnapshot snapshot = await Firestore.instance
            .collection("users")
            .document(user.uid)
            .get();
        if (snapshot.data["isTeacher"]) {
          setState(() {
            isLiveEnabled = snapshot.data["isLivePackageActivated"];
          });
        }
        if (checker == null) {
          if (snapshot.data["avatar"] != "avatars_images/avatar-071.png") {
            if (mounted) {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.setString("avatar_image", snapshot.data["avatar"]);
              setState(() {
                stmAvatar = snapshot.data["avatar"];
              });
            }
          } else {
            setState(() {
              stmAvatar = "avatars_images/avatar-071.png";
            });
          }
        } else {
          setState(() {
            stmAvatar = checker;
          });
        }
        setState(() {
          isLoggedIn = true;
        });
        setState(() {
          isTeacher = snapshot.data["isTeacher"];
          userID = user.uid;
        });
      } catch (e) {}
    }
    if (launch) {
      setState(() {
        isChekerLoading = false;
      });
    }
  }

  _searchWaiter(int i) {
    return AnimatedCrossFade(
      firstChild: Remainder(),
      secondChild: Container(
        width: 70,
        height: 70,
        child: Text(""),
      ),
      duration: Duration(milliseconds: 150),
      crossFadeState: isWaitingList[i]
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }

  _playPronun(int i) async {
    final before = await http.get(
        "https://www.dictionaryapi.com/api/v3/references/collegiate/json/" +
            pronunAudioWord[i].toLowerCase() +
            "?key=bcc8d128-e346-4242-aaf9-999b50db756a");
    List middle = json.decode(before.body);
    String dataWord = middle[0]["hwi"]["prs"][0]["sound"]["audio"];
    await audioPlayer.play("https://media.merriam-webster.com/soundc11/" +
        dataWord.substring(0, 1) +
        "/" +
        dataWord +
        ".wav");
  }

  _saveToFavs(String word, int i) async {
    SharedPreferences ffs = await SharedPreferences.getInstance();
    List<String> favs = ffs.getStringList("favs_list");
    int favsWords = ffs.getInt("FavsStatsDay");
    int favsWordsMonth = ffs.getInt("FavsStatsMonth");
    if (favs == null) {
      favs = [word];
      ffs.setStringList("favs_list", favs);
      setState(() {
        favsIconList[i] = Icons.star;
      });
      ffs.setInt("FavsStatsDay", (favsWords + 1));
      ffs.setInt("FavsStatsMonth", (favsWordsMonth + 1));
    } else if (favs.contains(word)) {
      favs.removeAt(favs.indexOf(word));
      setState(() {
        favsIconList[i] = Icons.star_border;
      });
      ffs.setStringList("favs_list", favs);
      ffs.setInt("FavsStatsDay", (favsWords - 1));
      ffs.setInt("FavsStatsMonth", (favsWordsMonth - 1));
    } else {
      favs.insert(0, word);
      setState(() {
        favsIconList[i] = Icons.star;
      });
      ffs.setStringList("favs_list", favs);
      ffs.setInt("FavsStatsMonth", (favsWordsMonth + 1));
      ffs.setInt("FavsStatsDay", (favsWords + 1));
    }
    if (isLoggedIn && isTeacher == false) {
      try {
        DocumentSnapshot snapshot = await Firestore.instance
            .collection("users")
            .document(userID)
            .collection("stats")
            .document(DateTime.now().month.toString() +
                DateTime.now().year.toString())
            .get();
        var ls1 = snapshot.data["favsCounter"].toList().reversed.toList();
        ls1.add(word);
        var ls2 = ls1.reversed.toList();
        await Firestore.instance
            .collection("users")
            .document(userID)
            .collection("stats")
            .document(DateTime.now().month.toString() +
                DateTime.now().year.toString())
            .updateData({"favsCounter": ls2});
      } catch (e) {
        await Firestore.instance
            .collection("users")
            .document(userID)
            .collection("stats")
            .document(DateTime.now().month.toString() +
                DateTime.now().year.toString())
            .setData({
          "favsCounter": [word],
          "searchedCounter": []
        });
      }
    }
  }

  _saveToHistory(String word) async {
    SharedPreferences saver = await SharedPreferences.getInstance();
    List<String> historyList = saver.getStringList("history_list");
    if (historyList == null) {
      historyList = [word];
      saver.setStringList("history_list", historyList);
    } else {
      historyList.insert(0, word);
      saver.setStringList("history_list", historyList);
    }
    int counterWordDay = saver.getInt("StatsCounterDay");
    int counterWordMonth = saver.getInt("StatsCounterMonth");
    int currentDay = DateTime.now().day;
    int lastUpdateDay = saver.getInt("lastUpdateDayCounter");
    if (lastUpdateDay == null ||
        lastUpdateDay != currentDay ||
        counterWordDay == null) {
      saver.setInt("StatsCounterDay", 1);
      saver.setInt("lastUpdateDayCounter", DateTime.now().day);
      saver.setInt("FavsStatsDay", 0);
    } else {
      saver.setInt("StatsCounterDay", (counterWordDay + 1));
    }
    int currentMonth = DateTime.now().month;
    int lastUpdateMonth = saver.getInt("lastUpdateMonth");
    if (lastUpdateMonth == null ||
        lastUpdateMonth != currentMonth ||
        counterWordMonth == null) {
      saver.setInt("StatsCounterMonth", 1);
      saver.setInt("lastUpdateMonth", DateTime.now().month);
      saver.setInt("FavsStatsMonth", 0);
    } else {
      saver.setInt("StatsCounterMonth", (counterWordMonth + 1));
    }
    if (isLoggedIn && isTeacher == false) {
      try {
        DocumentSnapshot snapshot = await Firestore.instance
            .collection("users")
            .document(userID)
            .collection("stats")
            .document(DateTime.now().month.toString() +
                DateTime.now().year.toString())
            .get();
        var ls1 = snapshot.data["searchedCounter"].toList().reversed.toList();
        ls1.add(word);
        var ls2 = ls1.reversed.toList();
        await Firestore.instance
            .collection("users")
            .document(userID)
            .collection("stats")
            .document(DateTime.now().month.toString() +
                DateTime.now().year.toString())
            .updateData({"searchedCounter": ls2});
      } catch (e) {
        await Firestore.instance
            .collection("users")
            .document(userID)
            .collection("stats")
            .document(DateTime.now().month.toString() +
                DateTime.now().year.toString())
            .setData({
          "searchedCounter": [word],
          "favsCounter": []
        });
      }
    }
  }

  _httpResponseMapModifier(Map data, String sense) {
    List cnt = new List.generate(10, (i) => i);
    if (sense == "definition") {
      List def = [];
      for (int i in cnt) {
        try {
          def.add(data["entries"][0]["senses"][i]["definitions"][0]);
        } catch (e) {}
      }
      return def;
    } else if (sense == "subsense") {
      List subs = [];
      for (int i in cnt) {
        List temporaryList = [];
        try {
          List lts = List.generate(10, (i) => i);
          for (int b in lts) {
            try {
              temporaryList.add(data["entries"][0]["senses"][i]["subsenses"][b]
                  ["definitions"][0]);
            } catch (e) {}
          }
          subs.add(temporaryList);
        } catch (e) {}
      }
      return subs;
    } else if (sense == "example") {
      List emp = [];
      for (int i in cnt) {
        try {
          emp.add(data["entries"][0]["senses"][i]["examples"][0]["text"]);
        } catch (e) {
          print(e);
        }
      }
      for (int i in cnt) {
        try {
          List lts = List.generate(10, (i) => i);
          for (int b in lts) {
            try {
              for (int m in lts) {
                try {
                  for (int g in lts) {
                    emp.add(data["entries"][i]["senses"][b]["subsenses"][m]
                        ["examples"][g]["text"]);
                  }
                } catch (e) {}
              }
            } catch (e) {}
          }
        } catch (e) {}
      }
      print(emp);
      return emp;
    }
  }

  _justSentenceReturner(String string) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SelectableText(
        _capitalLetterModifier(string),
        style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 17,
            color: Theme.of(context).bottomAppBarColor),
      ),
    );
  }

  _capitalLetterModifier(String sentence) {
    String rtn = sentence.substring(0, 1).toUpperCase() +
        sentence.substring(1, sentence.length);
    return rtn;
  }

  _getWordData(String word, int i) async {
    if (word == "Tesla") {
      await firebaseAnalytics.setUserProperty(
          name: "tesla_easter_activated", value: "true");
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool("isTeslaActivated", true);
      bool spx = preferences.getBool("isSpaceXActivated");
      if (spx == null) {
        spx = false;
      }
      if (spx) {
        preferences.setBool("isSpaceXActivated", false);
      }
    } else if (word == "SpaceX") {
      await firebaseAnalytics.setUserProperty(
          name: "spacex_easter_activated", value: "true");
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool("isSpaceXActivated", true);
      bool tsl = preferences.getBool("isTeslaActivated");
      if (tsl == null) {
        tsl = false;
      }
      if (tsl) {
        preferences.setBool("isTeslaActivated", false);
      }
    }
    setState(() {
      favsIconList[i] = Icons.star_border;
      isLoadingList[i] = true;
    });
    final rsp = await http.get(
        "https://od-api.oxforddictionaries.com/api/v2/entries/en-us/" +
            word.toLowerCase(),
        headers: {"app_id": appIdOxford, "app_key": appKeyOxford});
    print(rsp.statusCode);
    if (rsp.statusCode == 200) {
      Map<String, dynamic> data = json.decode(rsp.body);
      List numberList = [0, 1, 2, 3, 4];
      Map nounMap = {};
      Map verbMap = {};
      Map adverbMap = {};
      Map adjectiveMap = {};
      Map interjMap = {};
      setState(() {
        playButtonColorList[i] = Theme.of(context).primaryColor;
        wordTitleList[i] = word;
        try {
          pronunList[i] = data["results"][0]["lexicalEntries"][0]
              ["pronunciations"][1]["phoneticSpelling"];
        } catch (e) {
          pronunList[i] = "";
        }
        try {
          etymologiesList[i] = data["results"][0]["lexicalEntries"][0]
                      ["entries"][0]["etymologies"][0]
                  .substring(0, 1)
                  .toUpperCase() +
              data["results"][0]["lexicalEntries"][0]["entries"][0]
                      ["etymologies"][0]
                  .substring(
                      1,
                      data["results"][0]["lexicalEntries"][0]["entries"][0]
                              ["etymologies"][0]
                          .length);
        } catch (e) {
          etymologiesList[i] = "";
        }
      });
      for (int number in numberList) {
        try {
          String category = data["results"][0]["lexicalEntries"][number]
              ["lexicalCategory"]["id"];
          if (category == "noun") {
            nounMap = data["results"][0]["lexicalEntries"][number];
            print("it was $category");
          } else if (category == "verb") {
            verbMap = data["results"][0]["lexicalEntries"][number];
            print("it was $category");
          } else if (category == "adverb") {
            adverbMap = data["results"][0]["lexicalEntries"][number];
            print("it was $category");
          } else if (category == "adjective") {
            adjectiveMap = data["results"][0]["lexicalEntries"][number];
            print("it was $category");
          } else if (category == "interjection") {
            interjMap = data["results"][0]["lexicalEntries"][number];
            print("it was $category");
          }
        } catch (e) {}
      }
      Widget expandWidget = Container();
      Widget exWidget = Container();
      List lstNoun = [];
      List lstVerb = [];
      List lstAdverb = [];
      List lstAdjective = [];
      List lstNounSub = [];
      List lstVerbSub = [];
      List lstAdverbSub = [];
      List lstAdjectiveSub = [];
      List lstInterj = [];
      List lstInterjSub = [];
      List lstNounEmp = [];
      List lstVerbEmp = [];
      List lstAdverbEmp = [];
      List lstInterjEmp = [];
      List lstAdjectiveEmp = [];
      if (verbMap.isNotEmpty) {
        lstVerb = _httpResponseMapModifier(verbMap, "definition");
        lstVerbSub = _httpResponseMapModifier(verbMap, "subsense");
        lstVerbEmp = _httpResponseMapModifier(verbMap, "example");
      }

      if (adverbMap.isNotEmpty) {
        lstAdverb = _httpResponseMapModifier(adverbMap, "definition");
        lstAdverbSub = _httpResponseMapModifier(adverbMap, "subsense");
        lstAdverbEmp = _httpResponseMapModifier(adverbMap, "example");
      }

      if (adjectiveMap.isNotEmpty) {
        lstAdjective = _httpResponseMapModifier(adjectiveMap, "definition");
        lstAdjectiveSub = _httpResponseMapModifier(adjectiveMap, "subsense");
        lstAdjectiveEmp = _httpResponseMapModifier(adjectiveMap, "example");
      }

      if (nounMap.isNotEmpty) {
        lstNoun = _httpResponseMapModifier(nounMap, "definition");
        lstNounSub = _httpResponseMapModifier(nounMap, "subsense");
        lstNounEmp = _httpResponseMapModifier(nounMap, "example");
      }

      if (interjMap.isNotEmpty) {
        lstInterj = _httpResponseMapModifier(interjMap, "definition");
        lstInterjSub = _httpResponseMapModifier(interjMap, "subsense");
        lstInterjEmp = _httpResponseMapModifier(interjMap, "example");
      }
      var defConstraints = MediaQuery.of(context).size.height - 450;
      var tileColor = Theme.of(context).secondaryHeaderColor;
      var def2ndTileVievPhs = NeverScrollableScrollPhysics();
      FontWeight fontWeightt = FontWeight.w300;
      expandWidget = ListView(
        physics: def2ndTileVievPhs,
        children: <Widget>[
          interjMap.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Exclamation",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                        height: defConstraints,
                        child: ListView.builder(
                          itemCount: lstInterj.length,
                          itemBuilder: (BuildContext context, int i) {
                            return lstInterjSub[i].isNotEmpty
                                ? ExpansionTile(
                                    title: SelectableText(
                                        _capitalLetterModifier(lstInterj[i]),
                                        style: TextStyle(
                                            fontWeight: fontWeightt,
                                            color: Theme.of(context)
                                                .bottomAppBarColor)),
                                    children: <Widget>[
                                      Container(
                                        height: (lstInterjSub[i].length * 70)
                                            .toDouble(),
                                        child: ListView.builder(
                                            physics: def2ndTileVievPhs,
                                            itemCount: lstInterjSub[i].length,
                                            itemBuilder:
                                                (BuildContext context1, int b) {
                                              return _justSentenceReturner(
                                                  lstInterjSub[i][b]);
                                            }),
                                      )
                                    ],
                                  )
                                : _justSentenceReturner(lstInterj[i]);
                          },
                        ),
                      ),
                    ])
              : Container(),
          adverbMap.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Adverb",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                        height: defConstraints,
                        child: ListView.builder(
                          itemCount: lstAdverb.length,
                          itemBuilder: (BuildContext context, int i) {
                            return lstAdverbSub[i].isNotEmpty
                                ? ExpansionTile(
                                    title: SelectableText(
                                        _capitalLetterModifier(lstAdverb[i]),
                                        style: TextStyle(
                                            fontWeight: fontWeightt,
                                            color: Theme.of(context)
                                                .bottomAppBarColor)),
                                    children: <Widget>[
                                      Container(
                                        height: (lstAdverbSub[i].length * 70)
                                            .toDouble(),
                                        child: ListView.builder(
                                            physics: def2ndTileVievPhs,
                                            itemCount: lstAdverbSub[i].length,
                                            itemBuilder:
                                                (BuildContext context1, int b) {
                                              return _justSentenceReturner(
                                                  lstAdverbSub[i][b]);
                                            }),
                                      )
                                    ],
                                  )
                                : _justSentenceReturner(lstAdverb[i]);
                          },
                        ),
                      ),
                    ])
              : Container(),
          adjectiveMap.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Adjective",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                        height: defConstraints,
                        child: ListView.builder(
                          itemCount: lstAdjective.length,
                          itemBuilder: (BuildContext context, int i) {
                            return lstAdjectiveSub[i].isNotEmpty
                                ? ExpansionTile(
                                    title: SelectableText(
                                        _capitalLetterModifier(lstAdjective[i]),
                                        style: TextStyle(
                                            fontWeight: fontWeightt,
                                            color: Theme.of(context)
                                                .bottomAppBarColor)),
                                    children: <Widget>[
                                      Container(
                                        height: (lstAdjectiveSub[i].length * 70)
                                            .toDouble(),
                                        child: ListView.builder(
                                            physics: def2ndTileVievPhs,
                                            itemCount:
                                                lstAdjectiveSub[i].length,
                                            itemBuilder:
                                                (BuildContext context1, int b) {
                                              return _justSentenceReturner(
                                                  lstAdjectiveSub[i][b]);
                                            }),
                                      )
                                    ],
                                  )
                                : _justSentenceReturner(lstAdjective[i]);
                          },
                        ),
                      ),
                    ])
              : Container(),
          nounMap.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Noun",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                        height: defConstraints,
                        child: ListView.builder(
                          itemCount: lstNoun.length,
                          itemBuilder: (BuildContext context, int i) {
                            return lstNounSub[i].isNotEmpty
                                ? ExpansionTile(
                                    title: SelectableText(
                                        _capitalLetterModifier(lstNoun[i]),
                                        style: TextStyle(
                                            fontWeight: fontWeightt,
                                            color: Theme.of(context)
                                                .bottomAppBarColor)),
                                    children: <Widget>[
                                      Container(
                                        height: (lstNounSub[i].length * 70)
                                            .toDouble(),
                                        child: ListView.builder(
                                            physics: def2ndTileVievPhs,
                                            itemCount: lstNounSub[i].length,
                                            itemBuilder:
                                                (BuildContext context1, int b) {
                                              return _justSentenceReturner(
                                                  lstNounSub[i][b]);
                                            }),
                                      )
                                    ],
                                  )
                                : _justSentenceReturner(lstNoun[i]);
                          },
                        ),
                      ),
                    ])
              : Container(),
          verbMap.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Verb",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                        height: defConstraints,
                        child: ListView.builder(
                          itemCount: lstVerb.length,
                          itemBuilder: (BuildContext context, int i) {
                            return lstVerbSub[i].isNotEmpty
                                ? ExpansionTile(
                                    title: SelectableText(
                                        _capitalLetterModifier(lstVerb[i]),
                                        style: TextStyle(
                                            fontWeight: fontWeightt,
                                            color: Theme.of(context)
                                                .bottomAppBarColor)),
                                    children: <Widget>[
                                      Container(
                                        height: (lstVerbSub[i].length * 70)
                                            .toDouble(),
                                        child: ListView.builder(
                                            physics: def2ndTileVievPhs,
                                            itemCount: lstVerbSub[i].length,
                                            itemBuilder:
                                                (BuildContext context1, int b) {
                                              return _justSentenceReturner(
                                                  lstVerbSub[i][b]);
                                            }),
                                      )
                                    ],
                                  )
                                : _justSentenceReturner(lstVerb[i]);
                          },
                        ),
                      ),
                    ])
              : Container(),
        ],
      );
      exWidget = ListView(
        physics: def2ndTileVievPhs,
        children: <Widget>[
          lstInterjEmp.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Exclamation",
                      style: TextStyle(
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                          height: defConstraints,
                          child: ListView.builder(
                              itemCount: lstInterjEmp.length,
                              itemBuilder: (BuildContext context, int i) {
                                return _justSentenceReturner(lstInterjEmp[i]);
                              })),
                    ])
              : Container(),
          lstAdverbEmp.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Adverb",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                          height: defConstraints,
                          child: ListView.builder(
                              itemCount: lstAdverbEmp.length,
                              itemBuilder: (BuildContext context, int i) {
                                return _justSentenceReturner(lstAdverbEmp[i]);
                              })),
                    ])
              : Container(),
          lstAdjectiveEmp.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Adjective",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                          height: defConstraints,
                          child: ListView.builder(
                              itemCount: lstAdjectiveEmp.length,
                              itemBuilder: (BuildContext context, int i) {
                                return _justSentenceReturner(
                                    lstAdjectiveEmp[i]);
                              })),
                    ])
              : Container(),
          lstNounEmp.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Noun",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                          height: defConstraints,
                          child: ListView.builder(
                              itemCount: lstNounEmp.length,
                              itemBuilder: (BuildContext context, int i) {
                                return _justSentenceReturner(lstNounEmp[i]);
                              })),
                    ])
              : Container(),
          lstVerbEmp.isNotEmpty
              ? ExpansionTile(
                  backgroundColor: tileColor,
                  title: Text("Verb",
                      style: TextStyle(
                          fontWeight: fontWeightt,
                          color: Theme.of(context).bottomAppBarColor)),
                  children: <Widget>[
                      Container(
                          height: defConstraints,
                          child: ListView.builder(
                              itemCount: lstVerbEmp.length,
                              itemBuilder: (BuildContext context, int i) {
                                return _justSentenceReturner(lstVerbEmp[i]);
                              })),
                    ])
              : Container(),
        ],
      );
      setState(() {
        isLoadingList[i] = false;
        tabsList[i] = Expanded(
          child: DefaultTabController(
              length: 3,
              child: Container(
                child: Scaffold(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).primaryColorDark,
                        child: expandWidget,
                      ),
                      Container(
                          color: Theme.of(context).primaryColorDark,
                          child: lstVerbEmp.isNotEmpty ||
                                  lstAdverbEmp.isNotEmpty ||
                                  lstAdjectiveEmp.isNotEmpty ||
                                  lstInterjEmp.isNotEmpty ||
                                  lstNounEmp.isNotEmpty
                              ? exWidget
                              : Center(
                                  child: AutoSizeTextWidget(
                                  text:
                                      "No example sentences for this word found",
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"] /
                                      2,
                                ))),
                      Container(
                        color: Theme.of(context).primaryColorDark,
                        child: etymologiesList[i] == ""
                            ? Center(
                                child: AutoSizeTextWidget(
                                text: "No etymologies for this word found",
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] /
                                    2,
                              ))
                            : Padding(
                                padding: EdgeInsets.all(15),
                                child: SelectableText(etymologiesList[i],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 17,
                                        color: Theme.of(context)
                                            .bottomAppBarColor)),
                              ),
                      )
                    ],
                  ),
                  appBar: TabBar(
                      indicatorColor: Theme.of(context).primaryColor,
                      labelColor: Theme.of(context).primaryColor,
                      tabs: [
                        Tooltip(
                          message: "Definitions",
                          child: Tab(
                            icon: Center(
                                child: Container(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                "assets/outline-book-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            )),
                          ),
                        ),
                        Tooltip(
                          message: "Sentences",
                          child: Tab(
                            icon: Center(
                                child: Container(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                "assets/round-format_list_bulleted-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            )),
                          ),
                        ),
                        Tooltip(
                          message: "Etymologies",
                          child: Tab(
                            icon: Container(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                "assets/round-text_fields-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      ]),
                ),
              )),
        );
        pronunAudioWord[i] = word;
      });
      _saveToHistory(word);
      SharedPreferences getter = await SharedPreferences.getInstance();
      List<String> favs = getter.getStringList("favs_list");
      if (favs == null) {
      } else if (favs.contains(word)) {
        setState(() {
          favsIconList[i] = Icons.star;
        });
      }
    } else {
      print(rsp.statusCode);
      setState(() {
        isLoadingList[i] = false;
        isFailureList[i] = true;
      });
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isFailureList[i] = false;
      });
    }
  }

  _aiImageAlert(int i) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Detect Objects?",
                style: TextStyle(color: Theme.of(context).bottomAppBarColor)),
            content: Text("This function uses AI, so results may vary.",
                style: TextStyle(color: Theme.of(context).bottomAppBarColor)),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
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
                padding: EdgeInsets.all(20.0),
                child: GestureDetector(
                    onTap: () {
                      //_mlKitRecognitionLabels(ImageSource.gallery, i);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: 40,
                      width: 50,
                      child: Center(
                        child: Text(
                          "OK",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
              )
            ],
          );
        });
  }

  _aiTextAlert(int i) {
    // return showDialog(
    //     context: context,
    //     barrierDismissible: true,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         backgroundColor: Theme.of(context).secondaryHeaderColor,
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(15))),
    //         title: Text("Recognize Text?",
    //             style: TextStyle(color: Theme.of(context).bottomAppBarColor)),
    //         content: Text(
    //           "Take a picture or choose a picture from your gallery with text needed to be recognised. This function uses AI, so results may vary.",
    //           style: TextStyle(color: Theme.of(context).bottomAppBarColor),
    //         ),
    //         actions: <Widget>[
    //           Padding(
    //             padding: const EdgeInsets.all(12.0),
    //             child: GestureDetector(
    //               onTap: () {
    //                 Navigator.of(context).pop();
    //               },
    //               child: Container(
    //                 color: Colors.transparent,
    //                 width: 90,
    //                 height: 40,
    //                 child: Center(
    //                   child: Text(
    //                     "CANCEL",
    //                     style: TextStyle(
    //                         color: Theme.of(context).primaryColor,
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.bold),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.all(12.0),
    //             child: GestureDetector(
    //               onTap: () {
    //                 Navigator.pop(context);
    //                 return Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                         builder: (context) => ForkPicker(
    //                               isMlSearch: true,
    //                             ))).whenComplete(() async {
    //                   SharedPreferences getter =
    //                       await SharedPreferences.getInstance();
    //                   bool hasDetected = getter.getBool("hasDetected");
    //                   if (hasDetected == false) {
    //                     setState(() {
    //                       isFailureList[i] = true;
    //                     });
    //                     await Future.delayed(Duration(seconds: 2));
    //                     setState(() {
    //                       isFailureList[i] = false;
    //                     });
    //                   } else {
    //                     bool hasFinished = getter.getBool("hasFinished");
    //                     if (hasFinished) {
    //                       String word = getter.getString("detectedWordMLkit");
    //                       _getWordData(word, i);
    //                       getter.setBool("hasFinished", false);
    //                     }
    //                   }
    //                 });
    //               },
    //               child: Container(
    //                 color: Colors.transparent,
    //                 width: 50,
    //                 height: 40,
    //                 child: Center(
    //                   child: Text(
    //                     "OK",
    //                     style: TextStyle(
    //                         color: Theme.of(context).primaryColor,
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.bold),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           )
    //         ],
    //       );
    //     });
    return Navigator.push(
        context,
        FadeRoute(
            page: ForkPicker(
          isMlSearch: true,
        ))).whenComplete(() async {
      SharedPreferences getter = await SharedPreferences.getInstance();
      bool hasDetected = getter.getBool("hasDetected");
      if (hasDetected == false) {
        setState(() {
          isFailureList[i] = true;
        });
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          isFailureList[i] = false;
        });
      } else {
        bool hasFinished = getter.getBool("hasFinished");
        if (hasFinished) {
          String word = getter.getString("detectedWordMLkit");
          _getWordData(word, i);
          getter.setBool("hasFinished", false);
        }
      }
    });
  }

  _setWordData(int i) {
    if (isFailureList[i] || isLoadingList[i]) {
      return isFailureList[i]
          ? FailureAnimation(
              key: ValueKey("failure"),
            )
          : LoadingAnimation(
              key: ValueKey("loading"),
            );
    } else {
      return Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"] /
                10),
        child: Column(children: <Widget>[
          Center(
              child: AutoSizeTextWidget(
            isSelectable: true,
            text: wordTitleList[i],
            fontStyle: FontStyle.italic,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"] /
                3,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                tooltip:
                    playButtonColorList[i] == Theme.of(context).primaryColor
                        ? "Listen"
                        : null,
                icon: Center(
                    child: Container(
                  width: 32,
                  height: 32,
                  child: SvgPicture.asset(
                    "assets/round-play_circle_outline-24px.svg",
                    color: playButtonColorList[i],
                  ),
                )),
                onPressed:
                    playButtonColorList[i] == Theme.of(context).primaryColor
                        ? () {
                            _playPronun(i);
                          }
                        : null,
              ),
              Center(
                child: AutoSizeTextWidget(
                  isSelectable: true,
                  text: pronunList[i],
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      1.5,
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      3,
                ),
              ),
              IconButton(
                  tooltip:
                      playButtonColorList[i] == Theme.of(context).primaryColor
                          ? "Add to Favourites"
                          : null,
                  icon: AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    crossFadeState: favsIconList[i] == Icons.star
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Icon(
                      Icons.star,
                      size: 32,
                      color: playButtonColorList[i],
                    ),
                    secondChild: Icon(
                      Icons.star_border,
                      size: 32,
                      color: playButtonColorList[i],
                    ),
                  ),
                  onPressed:
                      playButtonColorList[i] == Theme.of(context).primaryColor
                          ? () {
                              _saveToFavs(wordTitleList[i], i);
                            }
                          : null)
            ],
          ),
          tabsList[i],
        ]),
      );
    }
  }

  _straightToAccount() {
    if (isChekerLoading) {
      return LoadingAnimation();
    } else if (isTeacher == null && isLoggedIn) {
      return Container(
        key: ValueKey(3),
        height: MediaQuery.of(context).size.width *
            Provider.of<Map>(context)["width"] *
            Provider.of<Map>(context)["height"],
        width: MediaQuery.of(context).size.width *
            Provider.of<Map>(context)["width"],
        child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {},
            highlightColor: Colors.grey.withOpacity(0.2),
            child: Center(
              child: Container(
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] *
                      1.5,
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] *
                      1.5,
                  child: SvgPicture.asset(stmAvatar)),
            )),
      );
    } else if (isLoggedIn != true) {
      return Container(
        height: MediaQuery.of(context).size.width *
            Provider.of<Map>(context)["width"] *
            Provider.of<Map>(context)["height"],
        width: MediaQuery.of(context).size.width *
            Provider.of<Map>(context)["width"],
        key: ValueKey(2),
        child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () async {
              setState(() {
                animOffSettingsX = 0;
                animOffSettingsY = moveDownOff * -1;
                animOffProfileX = moveCenterRightOff;
                animOffProfileY = moveCenterRightOff;
                animOffStatsY = moveDownOff;
              });
              animationControllerPage2.forward();
              await Future.delayed(Duration(milliseconds: 180));
              await Navigator.push(
                      context,
                      ScaleRoute(
                          page: AnimationOffset(offsets: {
                        "moveDownOff": moveDownOff,
                        "moveRightOff": moveRightOff,
                        "moveCenterDownOff": moveCenterDownOff,
                        "moveCenterRightOff": moveCenterRightOff
                      }, child: StudentTeacherModeAdAndLogInClass())))
                  .whenComplete(() {
                _isLoggedInChecker();
              });
              await Future.delayed(Duration(milliseconds: 180));
              animationControllerPage2.reverse();
            },
            highlightColor: Colors.grey.withOpacity(0.2),
            child: Hero(
              tag: "supervised_user_icon",
              child: Icon(
                Icons.supervised_user_circle,
                size: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"],
                color: Theme.of(context).primaryColor,
              ),
            )),
      );
    } else if (isLoggedIn) {
      return Container(
        height: MediaQuery.of(context).size.width *
            Provider.of<Map>(context)["width"] *
            Provider.of<Map>(context)["height"],
        width: MediaQuery.of(context).size.width *
            Provider.of<Map>(context)["width"],
        child: InkWell(
            key: ValueKey(1),
            borderRadius: BorderRadius.circular(28),
            onTap: () async {
              setState(() {
                animOffSettingsX = 0;
                animOffSettingsY = moveDownOff * -1;
                animOffProfileX = moveCenterRightOff;
                animOffProfileY = moveCenterRightOff;
                animOffStatsY = moveDownOff;
              });
              animationControllerPage2.forward();
              await Future.delayed(Duration(milliseconds: 180));
              String data = await Navigator.push(
                  context,
                  ScaleRoute(
                      page: AnimationOffset(
                    offsets: {
                      "moveDownOff": moveDownOff,
                      "moveRightOff": moveRightOff,
                      "moveCenterDownOff": moveCenterDownOff,
                      "moveCenterRightOff": moveCenterRightOff
                    },
                    child: StudentTeacherModeProfileClass(
                      width: MediaQuery.of(context).size.width,
                      isDemo: false,
                      avatar: stmAvatar,
                      isTeacher: isTeacher,
                      userID: userID,
                      isLiveEnabled: isLiveEnabled,
                    ),
                  ))).whenComplete(() {
                _isLoggedInChecker();
              });
              setState(() {
                stmAvatar = data;
              });
              await Future.delayed(Duration(milliseconds: 180));
              animationControllerPage2.reverse();
            },
            highlightColor: Colors.grey.withOpacity(0.2),
            child: Hero(
              tag: stmAvatar,
              child: Center(
                child: Container(
                    width: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"] *
                        1.5,
                    height: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        Provider.of<Map>(context)["iconSize"] *
                        1.5,
                    child: SvgPicture.asset(stmAvatar)),
              ),
            )),
      );
    }
  }

  AnimationController animationControllerPage2;
  AnimationController animationControllerPage1;
  double animOffSettingsX = 0;
  double animOffSettingsY = 0;
  double animOffProfileX = 0;
  double animOffProfileY = 0;
  double animOffStatsX = 0;
  double animOffStatsY = 0;
  double animOffWordDayX = 0;
  double animOffWordDayY = 0;
  double animOffFavsX = 0;
  double animOffFavsY = 0;
  double animOffHistoryX = 0;
  double animOffHistoryY = 0;

  double moveDownOff;
  double moveRightOff;
  double moveCenterDownOff;
  double moveCenterRightOff;

  GlobalKey<ScaffoldState> scaffsts = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.of(context).push(FadeRoute(page: Test())),
      // ),
      key: scaffsts,
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
          child: PageView(
              controller: pageControllerMainVertical,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              children: <Widget>[
            PageView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: counter,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: (MediaQuery.of(context).size.width -
                                    (MediaQuery.of(context).size.width *
                                        Provider.of<Map>(
                                            context)["textFieldWidth"])) /
                                2 +
                            60,
                        child: Stack(children: [
                          Positioned(
                              left: ((MediaQuery.of(context).size.width -
                                          (MediaQuery.of(context).size.width *
                                              Provider.of<Map>(
                                                  context)["textFieldWidth"])) /
                                      2) +
                                  ((MediaQuery.of(context).size.width *
                                          Provider.of<Map>(
                                              context)["textFieldWidth"]) /
                                      7),
                              top: ((MediaQuery.of(context).size.width -
                                      (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(
                                              context)["textFieldWidth"])) /
                                  2.5),
                              child: _searchWaiter(i)),
                          Positioned(
                            top: (MediaQuery.of(context).size.width -
                                    (MediaQuery.of(context).size.width *
                                        Provider.of<Map>(
                                            context)["textFieldWidth"])) /
                                2,
                            left: (MediaQuery.of(context).size.width -
                                    (MediaQuery.of(context).size.width *
                                        Provider.of<Map>(
                                            context)["textFieldWidth"])) /
                                2,
                            right: (MediaQuery.of(context).size.width -
                                    (MediaQuery.of(context).size.width *
                                        Provider.of<Map>(
                                            context)["textFieldWidth"])) /
                                2,
                            child: Container(
                                child: TextField(
                              cursorColor: Theme.of(context).primaryColor,
                              onTap: () {
                                setState(() {
                                  isWaitingList[i] = false;
                                });
                              },
                              onSubmitted: (word) {
                                _getWordData(word, i);
                                focusList[0] = false;
                              },
                              maxLines: 1,
                              textInputAction: TextInputAction.search,
                              // autofocus: focusList[i],
                              focusNode: i == 0 ? nodeForSearch : null,
                              autofocus: focusField,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).bottomAppBarColor),
                              autocorrect: true,
                              decoration: InputDecoration(
                                fillColor: Colors.transparent,
                                suffixIcon: IconButton(
                                    tooltip: "Scan a Text",
                                    icon: Center(
                                        child: Container(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                        "assets/round-text_fields-24px.svg",
                                        color: Theme.of(context).hintColor,
                                      ),
                                    )),
                                    onPressed: () {
                                      setState(() {
                                        isWaitingList[i] = false;
                                      });
                                      _aiTextAlert(i);
                                    }),
                                prefixIcon: IconButton(
                                    tooltip: "Scan an Image",
                                    icon: Center(
                                        child: Container(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                        "assets/round-insert_photo-24px.svg",
                                        color: Theme.of(context).hintColor,
                                      ),
                                    )),
                                    onPressed: () {
                                      setState(() {
                                        isWaitingList[i] = false;
                                      });
                                      // _aiImageAlert(i);
                                    }),
                                labelText:
                                    counter == 1 ? null : ((i + 1).toString()),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(28 / 3.16666666666),
                                ),
                              ),
                            )),
                          ),
                        ]),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          switchInCurve: Curves.fastOutSlowIn,
                          switchOutCurve: Curves.fastOutSlowIn,
                          duration: Duration(milliseconds: 200),
                          child: _setWordData(i),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0),
                              end: Offset(animOffWordDayX, animOffWordDayY))
                          .animate(CurvedAnimation(
                              parent: animationControllerPage1,
                              curve: Curves.fastOutSlowIn)),
                      child: MainDesignButton(
                        tooltipMessage: "Word of the day",
                        onTap: () async {
                          setState(() {
                            animOffFavsX = 2;
                            animOffFavsY = 0;
                            animOffHistoryX = 0;
                            animOffHistoryY = 2;
                            animOffWordDayY = moveCenterRightOff;
                            animOffWordDayX = moveCenterDownOff;
                          });
                          animationControllerPage1.forward();
                          await Future.delayed(Duration(milliseconds: 150));
                          await Navigator.push(
                              context,
                              ScaleRoute(
                                  page: WordOfTheDayData(
                                isToList: true,
                              )));
                          await Future.delayed(Duration(milliseconds: 150));
                          animationControllerPage1.reverse();
                        },
                        child: WordOfTheDayData(isToList: false),
                      ),
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0),
                              end: Offset(animOffHistoryX, animOffHistoryY))
                          .animate(CurvedAnimation(
                              parent: animationControllerPage1,
                              curve: Curves.fastOutSlowIn)),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: ((MediaQuery.of(context).size.width -
                                    2 *
                                        (Provider.of<Map>(context)["width"] *
                                            MediaQuery.of(context)
                                                .size
                                                .width)) /
                                3)),
                        child: MainDesignButton(
                          tooltipMessage: "History",
                          onTap: () async {
                            setState(() {
                              animOffFavsX = moveRightOff;
                              animOffFavsY = 0;
                              animOffHistoryY = moveCenterDownOff * -1;
                              animOffHistoryX = moveCenterRightOff;
                              animOffWordDayX = moveRightOff * -1;
                              animOffWordDayY = 0;
                            });
                            animationControllerPage1.forward();
                            await Future.delayed(Duration(milliseconds: 150));
                            await Navigator.push(
                                context, ScaleRoute(page: History()));
                            await Future.delayed(Duration(milliseconds: 150));
                            animationControllerPage1.reverse();
                          },
                          child: isSpecial
                              ? Container(
                                  width: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"],
                                  height: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"],
                                  child: historyIcon,
                                )
                              : SvgPicture.asset(
                                  "assets/round-history-24px.svg",
                                  color: Theme.of(context).primaryColor,
                                  fit: BoxFit.contain,
                                  width: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"],
                                  height: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                SlideTransition(
                  position: Tween<Offset>(
                          begin: Offset(0, 0),
                          end: Offset(animOffFavsX, animOffFavsY))
                      .animate(CurvedAnimation(
                          parent: animationControllerPage1,
                          curve: Curves.fastOutSlowIn)),
                  child: MainDesignButton(
                    tooltipMessage: "Favourites",
                    isFavs: true,
                    onLongPress: widget.isShortcutEnabled
                        ? () async {
                            setState(() {
                              focusField = true;
                            });
                            pageControllerMainVertical.animateToPage(0,
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 300));
                            await Future.delayed(Duration(milliseconds: 300));
                            setState(() {
                              focusField = false;
                            });
                          }
                        : null,
                    onTap: () async {
                      setState(() {
                        animOffFavsX = moveCenterRightOff * -1;
                        animOffFavsY = 0;
                        animOffHistoryX = moveRightOff * -1;
                        animOffHistoryY = 0;
                        animOffWordDayX = 0;
                        animOffWordDayY = moveDownOff * -1;
                      });
                      animationControllerPage1.forward();
                      await Future.delayed(Duration(milliseconds: 150));
                      await Navigator.push(context, ScaleRoute(page: Favs()));
                      await Future.delayed(Duration(milliseconds: 150));
                      animationControllerPage1.reverse();
                    },
                    child: isSpecial
                        ? Center(
                            child: Container(
                            width: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["iconSize"],
                            height: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["iconSize"],
                            child: favsIcon,
                          ))
                        : Icon(
                            Icons.star_border,
                            color: Theme.of(context).primaryColor,
                            size: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["iconSize"],
                          ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0),
                              end: Offset(animOffProfileX, animOffProfileY))
                          .animate(CurvedAnimation(
                              parent: animationControllerPage2,
                              curve: Curves.fastOutSlowIn)),
                      child: MainDesignButton(
                        isNotTappable: true,
                        tooltipMessage: "StudentTeacherMode",
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: _straightToAccount(),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0),
                              end: Offset(animOffSettingsX, animOffSettingsY))
                          .animate(CurvedAnimation(
                              parent: animationControllerPage2,
                              curve: Curves.fastOutSlowIn)),
                      child: MainDesignButton(
                        onTap: () async {
                          setState(() {
                            animOffProfileY = 0;
                            animOffSettingsX = moveCenterRightOff * -1;
                            animOffSettingsY = moveCenterDownOff;
                            animOffProfileX = moveRightOff * -1;
                            animOffStatsY = moveDownOff;
                          });
                          animationControllerPage2.forward();
                          await Future.delayed(Duration(milliseconds: 150));
                          var data = await Navigator.push(
                              context, ScaleRoute(page: Settings()));
                          setState(() {
                            counter = data;
                          });
                          await Future.delayed(Duration(milliseconds: 150));
                          animationControllerPage2.reverse();
                        },
                        tooltipMessage: "Settings",
                        child: Icon(
                          Icons.settings,
                          color: Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              Provider.of<Map>(context)["iconSize"],
                        ),
                      ),
                    ),
                  ],
                ),
                SlideTransition(
                  position: Tween<Offset>(
                          begin: Offset(0, 0),
                          end: Offset(animOffStatsX, animOffStatsY))
                      .animate(CurvedAnimation(
                          parent: animationControllerPage2,
                          curve: Curves.fastOutSlowIn)),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ((MediaQuery.of(context).size.width -
                                2 *
                                    (Provider.of<Map>(context)["width"] *
                                        MediaQuery.of(context).size.width)) /
                            3)),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 0.7),
                          borderRadius: BorderRadius.all(Radius.circular(28))),
                      height: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["height"],
                      width: ((MediaQuery.of(context).size.width -
                                  ((MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"]) *
                                      2)) /
                              3) +
                          ((MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"]) *
                              2),
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(28),
                        color: Theme.of(context).secondaryHeaderColor,
                        child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            highlightColor: Colors.grey.withOpacity(0.2),
                            child: WordStats()),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ])),
    );
  }
}

class Test extends StatefulWidget {
  final String imageUr;
  Test({this.imageUr});

  @override
  _Tst createState() => _Tst();
}

class _Tst extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("old"),),
      backgroundColor: Colors.white,
      body: Center(child: Container(
        decoration: BoxDecoration(
            border:
                Border.all(color: Colors.grey.withOpacity(0.5), width: 0.7),
            borderRadius: BorderRadius.all(Radius.circular(28))),
        height: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["height"],
        width: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"],
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).secondaryHeaderColor,
          child:Center(child: Container(),),
        ),
      ),),
    );
  }
  // int start = 60;
  // @override
  // // void initState() {
  // //   super.initState();
  // //   setState(() {
  // //     timer = CountdownTimer(Duration(seconds: start), Duration(seconds: 1));
  // //   });
  // //   timer.listen(null).onData((duration) {
  // //     print(start - duration.elapsed.inSeconds);
  // //     setState(() {
  // //      a = (start - duration.elapsed.inSeconds).toString();
  // //     });
  // //   });
  // // }

  // CountdownTimer timer;
  // _timeReturner() {
  //   print(start - timer.elapsed.inSeconds);
  //   setState(() {
  //     a = timer.remaining.inSeconds.toString();
  //   });
  // }

  // _timeChecker() async{
  //   DateTime before = DateTime.now().toUtc();
  //   var data = await http.get("http://worldtimeapi.org/api/timezone/Etc/UTC");
  //   Duration reqTime = before.difference(DateTime.now().toUtc());
  //   Duration after =
  //       Duration(milliseconds: ((reqTime.inMilliseconds) / 2).toInt());
  //   var js = json.decode(data.body);
  //   String deviceUTC = before.toIso8601String().substring(0, 16);
  //   String serverUTC = DateTime.tryParse(js["utc_datetime"])
  //       .subtract(after)
  //       .toIso8601String();
  //   String serverString = (serverUTC.substring(0, 16));
  //   if (serverString != deviceUTC) {
  //     int diff = DateTime.tryParse(serverUTC).difference(before).inSeconds;
  //     print(diff);
  //     if (diff > 10) {
  //       setState(() {
  //        isTimeCorrect = false; 
  //       });
  //     }
  //   }
  // }

  // bool isTimeCorrect = true;
  // String a = "100";
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SafeArea(
  //         child: Center(
  //       child: GestureDetector(onTap: () async {}, child: Text(a)),
  //     )),
  //   );
  // }
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

class AnimationOffset extends InheritedWidget {
  final Map offsets;
  AnimationOffset({this.offsets, Widget child}) : super(child: child);
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static AnimationOffset of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(AnimationOffset);
}

class ShortcutRoute extends PageRouteBuilder {
  final Widget page;
  ShortcutRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              child,
        );
}
