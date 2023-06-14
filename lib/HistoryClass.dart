import 'package:flutter/material.dart';
import 'package:notexactly/FavouritesClass.dart';
import 'package:notexactly/quickClasses.dart';
//import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
// Import needed classes

class History extends StatefulWidget {
  @override
  _History createState() => _History();
}

class _History extends State<History> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getData());
  }

  bool isLoading = true;
  bool isEmpty = false;

  _getData() async {
    SharedPreferences getter = await SharedPreferences.getInstance();
    setState(() {
      historyList = getter.getStringList("history_list");
      if (historyList == null || historyList.isEmpty) {
        isEmpty = true;
      }
      isLoading = false;
    });
  }

  List<String> historyList = [];
  GlobalKey<AnimatedListState> state = GlobalKey<AnimatedListState>();
  _scaff() {
    if (isEmpty) {
      return Center(
        child: AutoSizeTextWidget(
          width: MediaQuery.of(context).size.width * 0.7,
          text: "No searched words found",
        ),
      );
    } else if (isLoading) {
      // return LoadingAnimation();
      return Container();
    } else {
      return AnimatedList(
          key: state,
          initialItemCount: historyList.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index, animation) {
            return FadeTransition(
              opacity: animation,
              child: ItemReturner(
                onLongPress: () async {
                  state.currentState.removeItem(
                      index,
                      (context, animation) => FadeTransition(
                          opacity: animation,
                          child: ItemReturner(
                            data: historyList[index],
                          )),
                      duration: Duration(milliseconds: 250));
                  await Future.delayed(Duration(milliseconds: 250));
                  historyList.removeAt(index);
                  SharedPreferences newsave =
                      await SharedPreferences.getInstance();
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("The word has been deleted from History")));
                  newsave.setStringList("history_list", historyList);
                  _getData();
                },
                onDoubleTap: () async {
                  SharedPreferences newsave =
                      await SharedPreferences.getInstance();
                  List<String> favs = newsave.getStringList("favs_list");
                  if (favs == null) {
                    favs = [historyList[index]];
                    Scaffold.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text("The word has been added to Favourites"),
                    ));
                    newsave.setStringList("favs_list", favs);
                  } else if (favs.contains(historyList[index])) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("The word is already in Favourites"),
                      duration: Duration(seconds: 1),
                    ));
                  } else {
                    favs.insert(0, historyList[index]);
                    newsave.setStringList("favs_list", favs);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text("The word has been added to Favourites"),
                    ));
                  }
                },
                data: historyList[index],
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _scaff(),
      ),
    );
  }
}
