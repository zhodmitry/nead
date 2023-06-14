import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//show PlatformException;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'quickClasses.dart';

class Loader extends StatefulWidget {
  final String word;
  final bool textFieldEnabled;
  Loader({this.word, this.textFieldEnabled});
  @override
  LoaderItself createState() => LoaderItself();
}

class LoaderItself extends State<Loader> {
  void initState() {
    super.initState();
    if (widget.textFieldEnabled == null || widget.textFieldEnabled == false) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _getWordData(widget.word));
    }
  }

  IconData favsIcon = Icons.star_border;
  _saveToFavs(String word) async {
    SharedPreferences ffs = await SharedPreferences.getInstance();
    List<String> favs = ffs.getStringList("favs_list");
    if (favs == null) {
      favs = [word];
      setState(() {
        favsIcon = Icons.star;
      });
      ffs.setStringList("favs_list", favs);
    } else if (favs.contains(word)) {
      favs.removeAt(favs.indexOf(word));
      setState(() {
        favsIcon = Icons.star_border;
      });
      ffs.setStringList("favs_list", favs);
    } else {
      favs.insert(0, word);
      setState(() {
        favsIcon = Icons.star;
      });
      ffs.setStringList("favs_list", favs);
    }
  }

  AudioPlayer audioPlayer = new AudioPlayer();

  _playPronun() async {
    final before = await http.get(
        "https://www.dictionaryapi.com/api/v3/references/collegiate/json/" +
            wordTitle.toLowerCase() +
            "?key=bcc8d128-e346-4242-aaf9-999b50db756a");
    List middle = json.decode(before.body);
    String dataWord = middle[0]["hwi"]["prs"][0]["sound"]["audio"];
    await audioPlayer.play("https://media.merriam-webster.com/soundc11/" +
        dataWord.substring(0, 1) +
        "/" +
        dataWord +
        ".wav");
  }

  String wordToUrl = "";
  String letter = "";
  String pronun = "";
  String etymologies = "";
  bool isLoading = false;
  bool isFailure = false;
  final appIdOxford = "46575095";
  final appKeyOxford = "af0c3986a356cac82597f8cc25ebdb28";
  var playButtonColor = Colors.transparent;

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
        style:
            TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 17, color: Theme.of(context).bottomAppBarColor),
      ),
    );
  }

  _capitalLetterModifier(String sentence) {
    String rtn = sentence.substring(0, 1).toUpperCase() +
        sentence.substring(1, sentence.length);
    return rtn;
  }

  _getWordData(String word) async {
    setState(() {
      isLoading = true;
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
      if (mounted) {
        setState(() {
          playButtonColor = Theme.of(context).primaryColor;
          wordTitle = word;
          try {
            pronun = data["results"][0]["lexicalEntries"][0]["pronunciations"]
                [1]["phoneticSpelling"];
          } catch (e) {
            pronun = "";
          }
          try {
            etymologies = data["results"][0]["lexicalEntries"][0]["entries"][0]
                        ["etymologies"][0]
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
            etymologies = "";
          }
        });
      }
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                                        style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                                        style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                                        style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                                        style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
                      style: TextStyle(fontWeight: fontWeightt,
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
        isLoading = false;
        tabs = Expanded(
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
                        child: etymologies == ""
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
                                child: SelectableText(etymologies,
                                    style: TextStyle(fontWeight: fontWeightt,
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
      });
      SharedPreferences getter = await SharedPreferences.getInstance();
      List<String> favs = getter.getStringList("favs_list");
      if (favs == null) {
      } else if (favs.contains(word)) {
        setState(() {
          favsIcon = Icons.star;
        });
      }
    } else {
      print(rsp.statusCode);
      setState(() {
        isLoading = false;
        isFailure = true;
      });
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isFailure = false;
      });
    }
  }

  Widget tabs = Text("");
  _setWordData() {
    Widget rtrWgt;
    if (isFailure || isLoading) {
      rtrWgt = isFailure
          ? FailureAnimation(
              key: ValueKey("failure"),
            )
          : LoadingAnimation(
              key: ValueKey("loading"),
            );
    } else {
      rtrWgt = Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"] /
                10),
        child: Column(children: <Widget>[
          Center(
            child: AutoSizeTextWidget(
              isSelectable: true,
              text: wordTitle,
              fontStyle: FontStyle.italic,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["iconSize"] /
                  3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                tooltip: playButtonColor == Theme.of(context).primaryColor
                    ? "Listen"
                    : null,
                icon: Center(
                    child: Container(
                  width: 32,
                  height: 32,
                  child: SvgPicture.asset(
                    "assets/round-play_circle_outline-24px.svg",
                    color: playButtonColor,
                  ),
                )),
                onPressed: playButtonColor == Theme.of(context).primaryColor
                    ? () {
                        _playPronun();
                      }
                    : null,
              ),
              Center(
                child: AutoSizeTextWidget(
                  isSelectable: true,
                  text: pronun,
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
                  tooltip: playButtonColor == Theme.of(context).primaryColor
                      ? "Add to Favourites"
                      : null,
                  icon: AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    crossFadeState: favsIcon == Icons.star
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Icon(
                      Icons.star,
                      size: 32,
                      color: playButtonColor,
                    ),
                    secondChild: Icon(
                      Icons.star_border,
                      size: 32,
                      color: playButtonColor,
                    ),
                  ),
                  onPressed: playButtonColor == Theme.of(context).primaryColor
                      ? () {
                          _saveToFavs(wordTitle);
                        }
                      : null)
            ],
          ),
          tabs,
        ]),
      );
    }
    return rtrWgt;
  }

  String wordTitle = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: widget.textFieldEnabled == null ||
                widget.textFieldEnabled == false
            ? AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: _setWordData(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(
                          top: (MediaQuery.of(context).size.width -
                                  2 *
                                      (Provider.of<Map>(context)["width"] *
                                          MediaQuery.of(context).size.width)) /
                              3),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              Provider.of<Map>(context)["textFieldWidth"],
                          child: TextField(
                            onSubmitted: (string) => _getWordData(string),
                            cursorColor: Theme.of(context).primaryColor,
                            maxLines: 1,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).bottomAppBarColor),
                            autocorrect: true,
                            decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(28 / 3.16666666666),
                              ),
                            ),
                          ),
                        ),
                      )),
                  Expanded(
                    child: AnimatedSwitcher(
                      switchInCurve: Curves.fastOutSlowIn,
                      switchOutCurve: Curves.fastOutSlowIn,
                      duration: Duration(milliseconds: 200),
                      child: _setWordData(),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
