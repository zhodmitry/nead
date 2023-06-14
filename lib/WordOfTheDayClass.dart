import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notexactly/dataLoaderNoField.dart';
import 'quickClasses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
//word string

class WordOfTheDayData extends StatefulWidget {
  final bool isToList;
  WordOfTheDayData({@required this.isToList});
  @override
  _Wd createState() => _Wd();
}

class _Wd extends State<WordOfTheDayData> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>_currentDayWord());
  }

  bool isLoading = true;
  String ctd = "";
  int lastUpdateDay;
  int currentDay;
  
  _currentDayWord() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences date = await SharedPreferences.getInstance();
    setState(() {
      currentDay = new DateTime.now().day;
      lastUpdateDay = date.getInt("lastUpdateDay");
    });
    if (currentDay == lastUpdateDay) {
      print("The word is up to date.");
      setState(() {
        isLoading = true;
      });
      SharedPreferences recieve = await SharedPreferences.getInstance();
      setState(() {
        ctd = recieve.getString("word");
        isLoading = false;
      });
    } else {
      print("The word has been updated.");
      setState(() {
        isLoading = true;
      });
      DocumentSnapshot snapshot = await Firestore.instance
          .collection("wordoftheday")
          .document("geDqhLZStYOcB3ad5bOo")
          .get();
      SharedPreferences save = await SharedPreferences.getInstance();
      setState(() {
        ctd = snapshot.data["data"];
        save.setString("word", ctd);
        save.setInt("lastUpdateDay", currentDay);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isToList
        ? isLoading
            ? LoadingAnimation()
            : Loader(
                word: ctd,
              )
        : Center(
            child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: isLoading
                ? LoadingAnimation()
                : AutoSizeTextWidget(
                    text: ctd,
                    width: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        0.8,
                    fontWeight: FontWeight.w200,
                  ),
          ));
  }
}
