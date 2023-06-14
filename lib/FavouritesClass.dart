import 'package:flutter/material.dart';
import 'package:notexactly/main.dart';
import 'package:notexactly/quickClasses.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dataLoaderNoField.dart';

class Favs extends StatefulWidget {
  @override
  _Favs createState() => _Favs();
}

class _Favs extends State<Favs> {
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
      favsList = getter.getStringList("favs_list");
      if (favsList == null || favsList.isEmpty) {
        setState(() {
          isEmpty = true;
        });
      }
      isLoading = false;
    });
    print(favsList);
  }

  List<String> favsList = [];
  GlobalKey<AnimatedListState> listState = GlobalKey<AnimatedListState>();
  _scaff() {
    if (isEmpty) {
      return Center(
          child: AutoSizeTextWidget(
        width: MediaQuery.of(context).size.width * 0.8,
        text: "No Favourite words added",
      ));
    } else if (isLoading) {
      return Center(child: LoadingAnimation());
      // return Container();
    } else {
      return AnimatedList(
          key: listState,
          initialItemCount: favsList.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index, animation) {
            return FadeTransition(
              opacity: animation,
              child: ItemReturner(
                data: favsList[index],
                onLongPress: () async {
                  listState.currentState.removeItem(index, (context, animation)=> FadeTransition(
                    opacity: animation,
                    child: ItemReturner(
                      data: favsList[index],
                    ),
                  ), duration: Duration(milliseconds: 300));
                  await Future.delayed(Duration(milliseconds: 300));
                  favsList.removeAt(index);
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Deleted from Favoirites"),
                  ));
                  SharedPreferences setter =
                      await SharedPreferences.getInstance();
                  setter.setStringList("favs_list", favsList);
                  _getData();
                },
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

class ItemReturner extends StatelessWidget {
  final Function() onDoubleTap;
  final Function() onLongPress;
  final String data;
  ItemReturner({@required this.data, this.onDoubleTap, this.onLongPress});
  @override
  Widget build(BuildContext context) {
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
          color: Theme.of(context).secondaryHeaderColor,
          elevation: 3,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onDoubleTap: onDoubleTap,
            onLongPress: onLongPress,
            onTap: () => Navigator.push(
                context,
                FadeRoute(
                    page: Loader(
                  word: data,
                ))),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.withOpacity(0.2))),
              height: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"] /
                  2,
              width: MediaQuery.of(context).size.width *
                      Provider.of<Map>(context)["width"] *
                      2 +
                  (MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["width"] *
                              2) /
                      3,
              child: Center(
                  child: AutoSizeTextWidget(
                text: data,
                height: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"] /
                    3.5,
                width: MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        2 +
                    (MediaQuery.of(context).size.width -
                            MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                2) /
                        3 *
                        0.9,
              )),
            ),
          ),
        ),
      ),
    );
  }
}
