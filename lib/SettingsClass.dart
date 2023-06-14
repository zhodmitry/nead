import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notexactly/quickClasses.dart';
//import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Settings extends StatefulWidget {
  @override
  _Sett createState() => _Sett();
}

class _Sett extends State<Settings> {

FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _themeIconCheck());
  }

  int counter = 1;
  bool isWaiting = true;
  _delayer() {
    if (isWaiting) {
      return Text("");
    } else {
      return PageView(
        controller: ppp,
        onPageChanged: (i) async {
          SharedPreferences saver = await SharedPreferences.getInstance();
          saver.setInt("MainPageStats", i);
        },
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Center(
            child: AutoSizeTextWidget(
              width: (MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"]),
              text: "24 hours",
            ),
          ),
          Center(
            child: AutoSizeTextWidget(
              width: (MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"]),
              text: "30 days",
            ),
          ),
        ],
      );
    }
  }

  _themeIconCheck() async {
    SharedPreferences getter = await SharedPreferences.getInstance();
    int pageController = getter.getInt("MainPageStats");
    if (pageController == 0) {
      setState(() {
        ppp = PageController(initialPage: 0);
      });
    } else if (pageController == 1) {
      setState(() {
        ppp = PageController(initialPage: 1);
      });
    } else if (pageController == 2) {
      setState(() {
        ppp = PageController(initialPage: 2);
      });
    }
    setState(() {
      isWaiting = false;
    });
    bool theme = getter.getBool("theme");
    if (theme == null) {
      theme = false;
      getter.setBool("theme", false);
    }
    if (theme) {
      setState(() {
        currentTheme = false;
        themeIcon = Icons.brightness_7;
      });
    } else {
      setState(() {
        currentTheme = true;
        themeIcon = Icons.brightness_4;
      });
    }
    setState(() {
      counter = getter.getInt("searchFieldCounter");
    });
    setState(() {
      isShortcutEnabled = getter.getBool("isShortcutEnabled");
    });
  if(isShortcutEnabled == false) {
    await Future.delayed(animDuration);
    _animationRunner();
  }
  }

  _animationRunner() async {
    int b = 2;
    while (b != 0) {
      setState(() {
        shortcutOpacity = 0;
      });
      await Future.delayed(animDuration);
      setState(() {
        shortcutOpacity = 1;
      });
      await Future.delayed(animDuration);
      b--;
    }
  }

_analytics(String value) async{
await firebaseAnalytics.setUserProperty(name: "theme", value: value);

}
  bool isShortcutEnabled = false;
  double shortcutOpacity = 1;
  Duration animDuration = Duration(milliseconds: 300);
//fasle is Light
  bool currentTheme;
  IconData themeIcon = Icons.brightness_4;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(counter);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        body: Builder(
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MainDesignButton(
                        tooltipMessage: "Amount of search fields",
                        isNotTappable: true,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              tooltip: "Add",
                              icon: Container(
                                  width: (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"]) /
                                      2,
                                  height: (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"]) /
                                      2,
                                  child: SvgPicture.asset(
                                    "assets/round-add-24px.svg",
                                    color: Theme.of(context).bottomAppBarColor,
                                  )),
                              onPressed: () async {
                                SharedPreferences saver =
                                    await SharedPreferences.getInstance();
                                setState(() {
                                  counter = counter + 1;
                                });
                                saver.setInt("searchFieldCounter", counter);
                              },
                              color: Theme.of(context).bottomAppBarColor,
                              iconSize: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] /
                                  2,
                            ),
                            AnimatedSwitcher(
                              switchInCurve: Curves.fastOutSlowIn,
                              switchOutCurve: Curves.fastOutSlowIn,
                              duration: Duration(milliseconds: 100),
                              child: AutoSizeTextWidget(
                                key: ValueKey(counter),
                                text: counter.toString(),
                                height: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    Provider.of<Map>(context)["iconSize"] /
                                    2.5,
                                width: MediaQuery.of(context).size.width *
                                    Provider.of<Map>(context)["width"] *
                                    0.9,
                              ),
                            ),
                            IconButton(
                              tooltip: "Remove",
                              icon: Container(
                                  width: (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"]) /
                                      2,
                                  height: (MediaQuery.of(context).size.width *
                                          Provider.of<Map>(context)["width"] *
                                          Provider.of<Map>(
                                              context)["iconSize"]) /
                                      2,
                                  child: SvgPicture.asset(
                                    "assets/round-remove-24px.svg",
                                    color: Theme.of(context).bottomAppBarColor,
                                  )),
                              onPressed: () async {
                                SharedPreferences saver =
                                    await SharedPreferences.getInstance();
                                if (counter == 1) {
                                  final snc = SnackBar(
                                    content: Text(
                                        "Amount of Search Fields cannot be equal to 0"),
                                    duration: Duration(seconds: 1),
                                  );
                                  Scaffold.of(context).showSnackBar(snc);
                                } else {
                                  setState(() {
                                    counter = counter - 1;
                                  });
                                  saver.setInt("searchFieldCounter", counter);
                                }
                              },
                              iconSize: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"] /
                                  2,
                            )
                          ],
                        ),
                      ),
                      MainDesignButton(
                        tooltipMessage: "Theme",
                        onTap: () async {
                          SharedPreferences getter =
                              await SharedPreferences.getInstance();
                          bool isDark = getter.getBool("theme");
                          bool isDark1 = isDark;
                          String changedTo;
                          if (isDark == null) {
                            isDark = true;
                            getter.setBool("theme", true);
                            changedTo = "dark";
                            _analytics(changedTo);
                            setState(() {
                              themeIcon = Icons.brightness_7;
                            });
                          } else if (isDark) {
                            isDark = false;
                            getter.setBool("theme", false);
                            changedTo = "light";
                            _analytics(changedTo);
                            setState(() {
                              themeIcon = Icons.brightness_4;
                            });
                          } else {
                            isDark = true;
                            getter.setBool("theme", true);
                            changedTo = "dark";
                            _analytics(changedTo);
                            setState(() {
                              themeIcon = Icons.brightness_7;
                            });
                          }
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(currentTheme == isDark1
                                  ? ("Theme has been changed back to $changedTo.")
                                  : ("Theme has been changed to $changedTo. Relaunch the app."))));
                        },
                        child: AnimatedCrossFade(
                            duration: Duration(milliseconds: 300),
                            crossFadeState: themeIcon == Icons.brightness_4
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Container(
                              height: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"],
                              width: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"],
                              child: SvgPicture.asset(
                                "assets/round-brightness_4-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            secondChild: Container(
                              height: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"],
                              width: MediaQuery.of(context).size.width *
                                  Provider.of<Map>(context)["width"] *
                                  Provider.of<Map>(context)["iconSize"],
                              child: SvgPicture.asset(
                                "assets/round-brightness_7-24px.svg",
                                color: Theme.of(context).primaryColor,
                              ),
                            )),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: (MediaQuery.of(context).size.width -
                                (MediaQuery.of(context).size.width *
                                        Provider.of<Map>(context)["width"]) *
                                    2) /
                            3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MainDesignButton(
                          onTap: () async {
                            setState(() {
                              if (isShortcutEnabled == null) {
                                isShortcutEnabled = false;
                              }
                              isShortcutEnabled =
                                  isShortcutEnabled ? false : true;
                            });
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.setBool(
                                "isShortcutEnabled", isShortcutEnabled);
                          },
                          tooltipMessage: "Main screen shortcut",
                          child: AnimatedOpacity(
                            opacity: shortcutOpacity,
                            duration: animDuration,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  key: ValueKey(isShortcutEnabled == true),
                                  height: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"],
                                  width: MediaQuery.of(context).size.width *
                                      Provider.of<Map>(context)["width"] *
                                      Provider.of<Map>(context)["iconSize"],
                                  child: isShortcutEnabled == null ||
                                          isShortcutEnabled == false
                                      ? SvgPicture.asset(
                                          "assets/dashboard_icon.svg",
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5))
                                      : SvgPicture.asset(
                                          "assets/dashboard_icon.svg",
                                          color:
                                              Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        MainDesignButton(
                          tooltipMessage: "Statistical period",
                          child: _delayer(),
                          isNotTappable: true,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PageController ppp = PageController();
}
