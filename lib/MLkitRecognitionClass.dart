import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'quickClasses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'Classroom.dart';
import 'package:image_crop/image_crop.dart';
import 'package:provider/provider.dart';

class MLkitTextRecognititonPopUp extends StatefulWidget {
  final ImageSource imageSource;
  MLkitTextRecognititonPopUp({@required this.imageSource});

  @override
  _MlkitText createState() => _MlkitText();
}

class _MlkitText extends State<MLkitTextRecognititonPopUp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recognizer());
  }

  TextEditingController _controller = TextEditingController();
  int amount = 0;
  List elementList = [];
  List width;
  Widget imageWidget = Container();
  bool wordSelected = false;
  GlobalKey _key = GlobalKey();
  double ratio;
  bool hasSelected = false;
  double shiftX = 0;
  double shiftY = 0;
  bool isLoading = true;
  var imagePath;
  List colorList;
  var realWdth;

  PhotoViewController viewControllerValue = PhotoViewController();
  _builder() {
    if (isLoading) {
      return LoadingAnimation();
    } else if (hasSelected) {
      return Column(children: [
        Padding(
          padding: EdgeInsets.only(top: ((MediaQuery.of(context).size.width -
                                    2 *
                                        (Provider.of<Map>(context)["width"] *
                                            MediaQuery.of(context)
                                                .size
                                                .width)) /
                                3), bottom: ((MediaQuery.of(context).size.width -
                                    2 *
                                        (Provider.of<Map>(context)["width"] *
                                            MediaQuery.of(context)
                                                .size
                                                .width)) /
                                3)),
          child: Container(
            width: MediaQuery.of(context).size.width *
                Provider.of<Map>(context)["textFieldWidth"],
            child: Center(
              child: TextField(
                cursorColor: Theme.of(context).primaryColor,
                autocorrect: false,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    labelText: "Chosen word",
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(28 / 3.16666666666))),
                controller: _controller,
                style: TextStyle(color: Theme.of(context).bottomAppBarColor),
              ),
            ),
          ),
        ),
        Container(
            height: MediaQuery.of(context).size.height * 0.6267908309455588,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Center(
                  //     child: PhotoView(
                  //   controller: viewControllerValue,
                  //   scaleStateChangedCallback: (scale) {
                  //     print(viewControllerValue.scale);
                  //     setState(() {
                  //     ratio = realWdth.width * viewControllerValue.scale*10;
                  //     });
                  //   },
                  //   onTapDown: (BuildContext context, TapDownDetails dtp,
                  //       PhotoViewControllerValue pvct) {
                  //     print(pvct.scale);
                  //   },
                  //   gaplessPlayback: true,
                  //   basePosition: Alignment.topCenter,
                  //   minScale: PhotoViewComputedScale.contained,
                  //   maxScale: PhotoViewComputedScale.covered,
                  //   imageProvider: AssetImage(imagePath),
                  //   key: _key,
                  // )),
                  child: Image.file(
                    imagePath,
                    fit: BoxFit.contain,
                    key: _key,
                  ),
                ),
                Stack(
                  children: List.generate(amount, (index) {
                    return Positioned(
                        top: (elementList[index].cornerPoints[0].dy / ratio) +
                            shiftY,
                        left: ((elementList[index].cornerPoints[0].dx / ratio) +
                            shiftX),
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              colorList = List.filled(
                                  elementList.length,
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5));
                              width = List.filled(elementList.length, 1.2);
                              width[index] = 2.2;
                              colorList[index] = Theme.of(context).primaryColor;
                              _controller.text = elementList[index].text;
                              wordSelected = true;
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 250),
                                                      child: 
                                                      
                                                    width[index] == 1.2 ? Container(
                                                      key: ValueKey(1),
                              width:
                                  (elementList[index].boundingBox.width / ratio),
                              height:
                                  (elementList[index].boundingBox.height / ratio),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: colorList[index],
                                      width: width[index])),
                            ) :   
                                                      Container(
                                                        key: ValueKey(2),
                              width:
                                  (elementList[index].boundingBox.width / ratio),
                              height:
                                  (elementList[index].boundingBox.height / ratio),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: colorList[index],
                                      width: width[index])),
                            ),
                          ),
                        ));
                  }),
                )
              ],
            )),
      ]);
    }
  }

  _recognizer() async {
    setState(() {
      colorList =
          List.filled(10000, Theme.of(context).primaryColor.withOpacity(0.5));
    });
    SharedPreferences saver = await SharedPreferences.getInstance();
    saver.setBool("hasDetected", true);
    var image = await ImagePicker.pickImage(source: widget.imageSource);
    if (image == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        isLoading = true;
      });
      var data = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ImgCrop(
                image: image,
              )));
      if (data == null) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          imagePath = data;
        });
        File imageFilePath = File(data.path);
        var real = await decodeImageFromList(imageFilePath.readAsBytesSync());
        setState(() {
          realWdth = real;
        });
        /*
        imageWidget = PhotoView(
          onTapUp: (BuildContext context, TapUpDetails dtp, PhotoViewControllerValue pvct) {
            setState(() {
              scale = pvct.scale;
            });
            print(scale);
          },
          gaplessPlayback: true,
          basePosition: Alignment.topCenter,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered,
          imageProvider: AssetImage(image.path),
          key: _key,
        );*/
        final FirebaseVisionImage visionImage =
            FirebaseVisionImage.fromFile(data);
        final TextRecognizer textRecognizer =
            FirebaseVision.instance.textRecognizer();
        final VisionText visionText =
            await textRecognizer.processImage(visionImage);
        if (visionText.blocks.length == 0) {
          saver.setBool("hasDetected", false);
          Navigator.pop(context);
        } else {
          for (TextBlock block in visionText.blocks) {
            for (TextLine line in block.lines) {
              for (TextElement element in line.elements) {
                setState(() {
                  elementList.add(element);
                });
              }
            }
          }
          setState(() {
            isLoading = false;
            hasSelected = true;
          });
          //Needed delay below to correctly recognise the key.
          await Future.delayed(Duration(milliseconds: 500)); //165
          final renderBox = _key.currentContext;
          setState(() {
            width = List.filled(elementList.length, 1.2);
            shiftY =
                ((MediaQuery.of(context).size.height * 0.6267908309455588) -
                        renderBox.size.height) /
                    2;
            shiftX =
                (MediaQuery.of(context).size.width - renderBox.size.width) / 2;
            ratio = real.width / renderBox.size.width;
            amount = elementList.length;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        backgroundColor: Theme.of(context).primaryColorDark,
        floatingActionButton: wordSelected
            ? FloatingActionButton.extended(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () async {
                  SharedPreferences saver =
                      await SharedPreferences.getInstance();
                  saver.setString("detectedWordMLkit", _controller.text);
                  saver.setBool("hasFinished", true);
                  Navigator.pop(context);
                },
                label: Text(
                  "Continue",
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                icon: SvgPicture.asset("assets/arrow_forward_icon.svg",
                    color: Theme.of(context).primaryColorDark),
              )
            : null,
        body: SafeArea(child: _builder()));
  }
}

class ForkPicker extends StatelessWidget {
  final isMlSearch;
  ForkPicker({@required this.isMlSearch});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Tooltip(
                verticalOffset: 100,
                message: "Choose from gallery",
                child: Container(
                  width: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"],
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 0.7),
                      borderRadius: BorderRadius.all(Radius.circular(28))),
                  height: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["height"],
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(28),
                    color: Theme.of(context).secondaryHeaderColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => isMlSearch
                          ? Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      MLkitTextRecognititonPopUp(
                                        imageSource: ImageSource.gallery,
                                      )))
                              .whenComplete(() {
                              Navigator.of(context).pop();
                            })
                          : Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => TxtRec(
                                        imageSource: ImageSource.gallery,
                                      )))
                              .whenComplete(() {
                              Navigator.of(context).pop();
                            }),
                      child: Center(child: Container(
                        width:  MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"]*
                                Provider.of<Map>(context)["iconSize"],
                                height: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"]*
                                Provider.of<Map>(context)["iconSize"],
                        child: SvgPicture.asset("assets/photo_library_icon.svg", color: Theme.of(context).primaryColor),
                      )),
                    ),
                  ),
                ),
              ),
              Tooltip(
                verticalOffset: 100,
                message: "Take a picture",
                child: Container(
                  width: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] ,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 0.7),
                      borderRadius: BorderRadius.all(Radius.circular(28))),
                  height: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"] *
                                Provider.of<Map>(context)["height"],
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(28),
                    color: Theme.of(context).secondaryHeaderColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => isMlSearch
                          ? Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      MLkitTextRecognititonPopUp(
                                        imageSource: ImageSource.camera,
                                      )))
                              .whenComplete(() {
                              Navigator.of(context).pop();
                            })
                          : Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => TxtRec(
                                        imageSource: ImageSource.camera,
                                      )))
                              .whenComplete(() {
                              Navigator.of(context).pop();
                            }),
                      child: Center(child: Container(
                        width:  MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"]*
                                Provider.of<Map>(context)["iconSize"],
                                height: MediaQuery.of(context).size.width *
                                Provider.of<Map>(context)["width"]*
                                Provider.of<Map>(context)["iconSize"],
                        child: SvgPicture.asset("assets/camera_enhance_icon.svg", color: Theme.of(context).primaryColor),
                      )),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ImgCrop extends StatefulWidget {
  final image;
  ImgCrop({this.image});
  _ImgCp createState() => _ImgCp();
}

class _ImgCp extends State<ImgCrop> {
  _cp() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    final sample = await ImageCrop.sampleImage(
      file: widget.image,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );
    Navigator.of(context).pop(file);
  }

  final cropKey = GlobalKey<CropState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 500,
                child: Crop.file(
                  widget.image,
                  key: cropKey,
                  alwaysShowGrid: true,
                  maximumScale: 4.0,
                  scale: 1,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Material(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.grey.withOpacity(0.2),
                    onTap: _cp,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(28)),
                      width: 130,
                      height: 50,
                      child: Center(
                        child: Text(
                          "Crop",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.grey.withOpacity(0.2),
                    onTap: () => Navigator.of(context).pop(widget.image),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(28)),
                      width: 130,
                      height: 50,
                      child: Center(
                        child: Text(
                          "Don't crop",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
