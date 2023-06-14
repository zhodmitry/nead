import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
//import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'quickClasses.dart';

class WordStats extends StatefulWidget {
  @override
  _rsct createState() => _rsct();
}

class _rsct extends State<WordStats> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getter());
  }

  _getter() async {
    SharedPreferences getter = await SharedPreferences.getInstance();
    int mainPageStats = getter.getInt("MainPageStats");
    if (mainPageStats == null) {
      getter.setInt("MainPageStats", 0);
      mainPageStats = 0;
    }
    if (mainPageStats == 0) {
      int currentDay = new DateTime.now().day;
      int lastUpdateDay = getter.getInt("lastUpdateDayCounter");
      if (lastUpdateDay == null || lastUpdateDay != currentDay) {
        setState(() {
          counter = 0;
          addedToFavs = 0;
        });
        getter.setInt("lastUpdateDayCounter", DateTime.now().day);
        getter.setInt("StatsCounterDay", 0);
        getter.setInt("FavsStatsDay", 0);
      } else if (currentDay == lastUpdateDay) {
        setState(() {
          counter = getter.getInt("StatsCounterDay");
          addedToFavs = getter.getInt("FavsStatsDay");
          msg = "Searched words for the last 24 hours";
          msgFavs = "Favourite words for the last 24 hours";
        });
        if (counter == null) {
          setState(() {
            counter = 0;
          });
          getter.setInt("StatsCounterDay", 0);
        }
        if (addedToFavs == null) {
          setState(() {
            addedToFavs = 0;
          });
          getter.setInt("FavsStatsDay", 0);
        }
      }
    } else if (mainPageStats == 1) {
      int currentMonth = DateTime.now().month;
      int lastUpdateMonth = getter.getInt("lastUpdateMonth");
      if (lastUpdateMonth == null || lastUpdateMonth != currentMonth) {
        setState(() {
          counter = 0;
        });
        getter.setInt("lastUpdateMonth", DateTime.now().month);
        getter.setInt("StatsCounterMonth", 0);
        getter.setInt("FavsStatsMonth", 0);
      } else if (lastUpdateMonth == currentMonth) {
        setState(() {
          counter = getter.getInt("StatsCounterMonth");
          addedToFavs = getter.getInt("FavsStatsMonth");
          msg = "Searched words for the last 30 days";
          msgFavs = "Favourite words for the last 30 days";
        });
        if (counter == null) {
          setState(() {
            counter = 0;
          });
          getter.setInt("StatsCounterMonth", 0);
        }
        if (addedToFavs == null) {
          setState(() {
            addedToFavs = 0;
          });
          getter.setInt("FavsStatsMonth", 0);
        }
      }
    }
  }

  int counter = 0;
  String msg = "";
  String msgFavs = "";
  int addedToFavs = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Tooltip(
          message: msg,
          verticalOffset: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          2,
                      height: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] /
                          2,
                      child: SvgPicture.asset(
                        "assets/round-history-24px.svg",
                        color: Theme.of(context).primaryColor,
                      ))),
              Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] * 0.35
                  ),
                    child: AutoSizeTextWidget(
                text: counter.toString(),
                height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      3,
                width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      0.9,
              ),
                  ))
            ],
          ),
        ),
        Container(
          width: 1,
          color: Colors.grey.withOpacity(0.3),
        ),
        Tooltip(
          message: msgFavs,
          verticalOffset: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                  child: Icon(
                Icons.star_border,
                color: Theme.of(context).primaryColor,
                size: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"] /
                    2,
              )),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["iconSize"] * 0.35),
                child: AutoSizeTextWidget(
                  text: addedToFavs.toString(),
                  height: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      Provider.of<Map>(context)["iconSize"] /
                      3,
                  width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      0.9,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
