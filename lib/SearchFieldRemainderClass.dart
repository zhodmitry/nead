import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class Remainder extends StatefulWidget {
  @override
  _Rmd createState() => _Rmd();
}

class _Rmd extends State<Remainder> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launcher());
  }

  _launcher() async {
    await Future.delayed(Duration(seconds: 8)); //6, 8 or 10
    if (mounted) {
      setState(() {
        isPlaying = true;
      });
      await Future.delayed(Duration(seconds: 6, milliseconds: 530)); //6.53
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  bool isPlaying = false;
  _wgt() {
    return AnimatedCrossFade(
        duration: Duration(milliseconds: 200),
        crossFadeState:
            isPlaying ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: Container(
          width: 70,
          height: 70,
          child: FlareActor(
            "assets/Pencil Icon.flr",
            animation: "animation",
            fit: BoxFit.contain,
            color: Theme.of(context).bottomAppBarColor,
          ),
        ),
        secondChild: Container(
          width: 70,
          height: 70,
          child: Text(""),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _wgt();
  }
}
