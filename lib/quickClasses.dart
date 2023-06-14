import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smart_flare/smart_flare.dart';

class LoadingAnimation extends StatelessWidget {
  final double width;
  final double height;
  LoadingAnimation({Key key, this.height, this.width}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: width == null
                ? MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"]
                : width,
            height: height == null
                ? MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"]
                : height,
            child: FlareActor(
              "assets/Loader.flr",
              animation: "anim",
              fit: BoxFit.contain,
              color: Theme.of(context).primaryColor,
            )));
  }
}

class FailureAnimation extends StatelessWidget {
  FailureAnimation({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"].toDouble(),
            height: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"].toDouble(),
            child: SmartFlareActor(
              width: null,
              height: null,
              filename: "assets/Status E_S.flr",
              startingAnimation: "Error",
            )));
  }
}

class SuccessAnimation extends StatelessWidget {
  final double size;
  SuccessAnimation({this.size});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SmartFlareActor(
        filename: "assets/Success Check.flr",
        startingAnimation: "Untitled",
        width: size == null
            ? MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"].toDouble()
            : size,
        height: size == null
            ? MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"].toDouble()
            : size,
      ),
    );
  }
}

class AutoSizeTextWidget extends StatelessWidget {
  final width;
  final height;
  final text;
  final FontWeight fontWeight;
  final Color textColor;
  final FontStyle fontStyle;
  final int maxLines;
  final TextAlign textAlign;
  final isSelectable;
  AutoSizeTextWidget(
      {Key key,
      this.textAlign,
      this.width,
      this.height,
      this.isSelectable,
      @required this.text,
      this.fontWeight,
      this.textColor,
      this.fontStyle,
      this.maxLines})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return isSelectable == null || isSelectable == false
        ? Container(
            width: width,
            height: height,
            child: Center(
              child: AutoSizeText(
                text,
                minFontSize: 1,
                textAlign: textAlign == null ? null : textAlign,
                maxLines: maxLines == null ? 1 : maxLines,
                style: TextStyle(
                    fontStyle: fontStyle == null ? FontStyle.normal : fontStyle,
                    fontSize: 5000,
                    fontWeight:
                        fontWeight == null ? FontWeight.w300 : fontWeight,
                    color: textColor == null
                        ? Theme.of(context).bottomAppBarColor
                        : textColor),
              ),
            ),
          )
        : SizedBox(
            width: width,
            height: height,
            child: FittedBox(
              child: Center(
                child: SelectableText(
                  text,
                  textAlign: textAlign == null ? null : textAlign,
                  maxLines: maxLines == null ? 1 : maxLines,
                  style: TextStyle(
                      fontStyle:
                          fontStyle == null ? FontStyle.normal : fontStyle,
                      fontSize: 30,
                      fontWeight:
                          fontWeight == null ? FontWeight.w300 : fontWeight,
                      color: textColor == null
                          ? Theme.of(context).bottomAppBarColor
                          : textColor),
                ),
              ),
            ),
          );
  }
}

class CircularButton extends StatelessWidget {
  final Function() onTap;
  final String tooltipMessage;
  final String icon;
  CircularButton({Key key, this.onTap, this.tooltipMessage, this.icon})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            height: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"] /
                2,
            width: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["width"] *
                Provider.of<Map>(context)["iconSize"] /
                2,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"] *
                    0.24,
                height: MediaQuery.of(context).size.width *
                    Provider.of<Map>(context)["width"] *
                    Provider.of<Map>(context)["iconSize"] *
                    0.24,
                child: SvgPicture.asset(
                  icon,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentTeacherModePageViewContainer extends StatelessWidget {
  final Widget child;
  StudentTeacherModePageViewContainer({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: MediaQuery.of(context).size.width / 2,
        width: MediaQuery.of(context).size.width * 0.43229166666 * 2 +
            ((MediaQuery.of(context).size.width -
                    (MediaQuery.of(context).size.width *
                        Provider.of<Map>(context)["width"] *
                        2)) /
                6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.grey.withOpacity(0.5), width: 0.7)),
        child: Material(
          color: Theme.of(context).secondaryHeaderColor,
          elevation: 5,
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
    );
  }
}

class SelectedPageIndidcator extends StatelessWidget {
  final color;
  SelectedPageIndidcator({Key key, @required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width / 40,
      height: MediaQuery.of(context).size.width / 40,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(100), color: color),
    );
  }
}

class MainDesignButton extends StatelessWidget {
  final Function() onTap;
  final Function() onLongPress;
  final Widget child;
  final String tooltipMessage;
  final bool isFavs;
  final bool isNotTappable;
  MainDesignButton({this.onTap,  @required this.child, @required this.tooltipMessage, this.isFavs, this.isNotTappable, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: tooltipMessage,
        verticalOffset: isFavs == null || isFavs == false ?110 : 220,
        child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey.withOpacity(0.5), width: 0.7),
              borderRadius: BorderRadius.all(Radius.circular(28))),
          height: isFavs == null || isFavs == false
              ? MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"] *
                  Provider.of<Map>(context)["height"]
              : (MediaQuery.of(context).size.width *
                          Provider.of<Map>(context)["width"] *
                          Provider.of<Map>(context)["height"]) *
                      2 +
                  ((MediaQuery.of(context).size.width -
                          2 *
                              (Provider.of<Map>(context)["width"] *
                                  MediaQuery.of(context).size.width)) /
                      3),
          width: isFavs == null || isFavs == false
              ? MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"]
              : MediaQuery.of(context).size.width *
                  Provider.of<Map>(context)["width"],
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(28),
            color: Theme.of(context).secondaryHeaderColor,
            child: isNotTappable == null || isNotTappable == false ? InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onTap,
              onLongPress: onLongPress,
              // highlightColor: Colors.grey.withOpacity(0.2),
              child: Center(child: child),
            ) : Center(child: child,),
          ),
        ));
  }
}
