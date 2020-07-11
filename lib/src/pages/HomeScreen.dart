import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flyweb/src/elements/DrawerListTitle.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/menu.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/models/social.dart';
import 'package:flyweb/src/themes/UIImages.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:launch_review/launch_review.dart';

import 'AboutScreen.dart';

class HomeScreen extends StatefulWidget {
  final String url;

  const HomeScreen(this.url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  SharedPref sharedPref = SharedPref();
  Settings settings = Settings();
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  InAppWebViewController webView;

  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadSharedPrefs();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    super.dispose();
  }

  Future loadSharedPrefs() async {
    try {
      Settings _settings = Settings.fromJson(await sharedPref.read("settings"));
      setState(() {
        settings = _settings;
      });

      FirebaseAdMob.instance.initialize(
          appId: Platform.isAndroid
              ? _settings.admobId
              : _settings.admobIdIos); //FirebaseAdMob.testAppId

      if (_settings.adBanner == "1") {
        _bannerAd = createBannerAd()..load();
      } else {
        _bannerAd?.dispose();
      }

      if (_settings.adInterstitial == "1") {
        Timer.periodic(new Duration(seconds: int.parse(_settings.admobDealy)),
            (timer) {
          _interstitialAd?.dispose();
          _interstitialAd = createInterstitialAd()..load();
          _interstitialAd?.show();
        });
      } else {
        _interstitialAd?.dispose();
      }
    } catch (Excepetion) {}
  }

  @override
  Future<ShouldOverrideUrlLoadingAction> shouldOverrideUrlLoading(
      ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest) async {
    this.webView.loadUrl(url: shouldOverrideUrlLoadingRequest.url);
    return ShouldOverrideUrlLoadingAction.CANCEL;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    /*SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: HexColor(settings.secondColor))
    );*/

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    var bottomPadding = mediaQueryData.padding.bottom;

    return WillPopScope(
      onWillPop: () async {
        _onBackPressed(context, webView);
      },
      child: Container(
          decoration: BoxDecoration(color: HexColor("#f5f4f4")),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Scaffold(
            key: _scaffoldKey,
            appBar: _renderAppBar(context, settings, webView),
            drawer: Drawer(
              child: ListView(
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  DrawerHeader(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: <Color>[
                        HexColor(settings.firstColor),
                        HexColor(settings.secondColor)
                      ])),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 70.0,
                              height: 70.0,
                              child: Image.network(
                                settings.logoUrl,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(settings.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(settings.subTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            )
                          ],
                        ),
                      )),
                  DrawerListTitle(
                      icon: Icons.home,
                      text: "Home",
                      onTap: () {
                        webView.loadUrl(url: settings.url);
                        Navigator.pop(context);
                      }),
                  _renderMenuDrawer(settings.menus, webView, context),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Divider(height: 1, color: Colors.grey[400]),
                  ),
                  DrawerListTitle(
                      icon: Icons.share,
                      text: "Share",
                      onTap: () {
                        shareApp(context, settings.title, settings.share);
                      }),
                  DrawerListTitle(
                      icon: Icons.info,
                      text: "About",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: AboutScreen()));
                      }),
                  DrawerListTitle(
                      icon: Icons.star,
                      text: "Rate Us",
                      onTap: () => LaunchReview.launch(
                          androidAppId: settings.androidId,
                          iOSAppId: settings.iosId)),
                  settings.socials.length != 0
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Divider(height: 1, color: Colors.grey[400]),
                        )
                      : Container(),
                  _renderSocialDrawer(settings.socials, webView, context),
                ],
              ),
            ),
            body: ModalProgressHUD(
                progressIndicator:
                    _renderLoader(settings.loader, settings.secondColor),
                child: InAppWebView(
                  initialUrl: widget.url,
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  initialHeaders: {},
                  initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                          domStorageEnabled: true, geolocationEnabled: true),
                      ios: IOSInAppWebViewOptions(),
                      crossPlatform: InAppWebViewOptions(
                          useOnDownloadStart: true,
                          useShouldOverrideUrlLoading: true,
                          useOnLoadResource: true,
                          javaScriptCanOpenWindowsAutomatically: true)),
                  onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      isLoading = true;
                    });
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    this.setState(() {
                      isLoading = false;
                    });
                  },
                  shouldOverrideUrlLoading: (InAppWebViewController controller,
                      ShouldOverrideUrlLoadingRequest request) async {
                    if (request.url.contains("mailto:") ||
                        request.url.contains("tel:") ||
                        request.url.contains("sms:") ||
                        request.url.contains('.pdf')) {
                      launch(request.url);
                      return ShouldOverrideUrlLoadingAction.CANCEL;
                    }

                    return ShouldOverrideUrlLoadingAction.ALLOW;
                  },
                ),
                inAsyncCall: isLoading),
            bottomNavigationBar: Container(
                height: settings.adBanner == "1"
                    ? Platform.isAndroid ? 50 : 80
                    : 0),
          )),
    );
  }

  BannerAd createBannerAd() {
    String testAdUnitId = Platform.isAndroid
        ? settings.admobKeyAdBanner
        : settings.admobKeyAdBannerIos;

    return BannerAd(
        adUnitId: testAdUnitId, //BannerAd.testAdUnitId,
        size: AdSize.banner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            _bannerAd..show();
          }
        });
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: Platform.isAndroid
          ? settings.admobKeyAdInterstitial
          : settings.admobKeyAdInterstitialIos, //InterstitialAd.testAdUnitId
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }
}

Widget _renderMenuDrawer(
    List<Menu> menus, InAppWebViewController webView, context) {
  return new Column(
    children: menus
        .map(
          (Menu menu) => DrawerListTitle(
              icon_url: menu.iconUrl,
              text: menu.title,
              onTap: () {
                webView.loadUrl(url: menu.url);
                Navigator.pop(context);
              }),
        )
        .toList(),
  );
}

Widget _renderSocialDrawer(
    List<Social> socials, InAppWebViewController webView, context) {
  return new Column(
    children: socials
        .map(
          (Social social) => DrawerListTitle(
              icon_url: social.iconUrl,
              text: social.title,
              onTap: () async {
                if (await canLaunch(
                    social.linkUrl.replaceAll("id_app", social.idApp))) {
                  await launch(
                      social.linkUrl.replaceAll("id_app", social.idApp));
                } else {
                  launch(social.url.replaceAll("id_app", social.idApp));
                }
              }),
        )
        .toList(),
  );
}

Widget _renderAppBar(
    context, Settings settings, InAppWebViewController webView) {
  return settings.navigatinBarStyle != "empty"
      ? AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _renderMenuIcon(context, settings.leftButton,
                    settings.navigatinBarStyle, webView, settings, "left"),
                _renderTitle(settings.navigatinBarStyle, settings),
                _renderMenuIcon(context, settings.rightButton,
                    settings.navigatinBarStyle, webView, settings, "right"),
              ]),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  HexColor(settings.firstColor),
                  HexColor(settings.secondColor)
                ],
              ),
            ),
          ))
      : PreferredSize(
          preferredSize: Size(0.0, 0.0),
          child: Container(
            color: HexColor(settings.secondColor),
          ));
}

Widget _renderTitle(String type, Settings settings) {
  var direction = MainAxisAlignment.start;

  switch (type) {
    case "left":
      direction = MainAxisAlignment.start;
      break;
    case "right":
      direction = MainAxisAlignment.end;
      break;
    case "center":
      direction = MainAxisAlignment.center;
      break;
    default:
      direction = MainAxisAlignment.center;
  }

  return Expanded(
    child: Row(
      mainAxisAlignment: direction,
      children: [
        Flexible(
          child: Container(
            child: settings.typeHeader == "text"
                ? Text(
                    settings.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  )
                : settings.typeHeader == "image"
                    ? Image.network(settings.logoHeaderUrl, height: 40)
                    : Container(),
          ),
        )
      ],
    ),
  );
}

Widget _renderMenuIcon(
    BuildContext context,
    String type,
    String navigatinBarStyle,
    InAppWebViewController webView,
    Settings settings,
    String direction) {
  return type != "icon_empty"
      ? Container(
          padding: direction == "right"
              ? new EdgeInsets.only(left: 12)
              : new EdgeInsets.only(right: 12),
          child: InkWell(
              splashColor: Colors.orangeAccent,
              onTap: () {
                actionButtonMenu(type, webView, settings, context);
              },
              child: Image.asset(UIImages.imageDir + "/$type.png",
                  height: 25, width: 25, color: Colors.white)))
      : Container(
          width: navigatinBarStyle == "center" ? 37 : 0,
        );
}

Widget _renderLoader(String type, String color) {
  Widget loader;
  switch (type) {
    case "RotatingPlain":
      loader = SpinKitRotatingPlain(
        color: HexColor(color),
        size: 100.0,
      );
      break;

    case "FadingFour":
      loader = SpinKitFadingFour(
        color: HexColor(color),
        size: 100.0,
      );
      break;

    case "FadingCube":
      loader = SpinKitFadingCube(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "Pulse":
      loader = SpinKitPulse(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "ChasingDots":
      loader = SpinKitChasingDots(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "ThreeBounce":
      loader = SpinKitThreeBounce(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "Circle":
      loader = SpinKitCircle(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "CubeGrid":
      loader = SpinKitCubeGrid(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "FadingCircle":
      loader = SpinKitFadingCircle(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "FoldingCube":
      loader = SpinKitFoldingCube(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "PumpingHeart":
      loader = SpinKitPumpingHeart(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "DualRing":
      loader = SpinKitDualRing(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "HourGlass":
      loader = SpinKitHourGlass(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "FadingGrid":
      loader = SpinKitFadingGrid(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "Ring":
      loader = SpinKitRing(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "Ripple":
      loader = SpinKitRipple(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "SpinningCircle":
      loader = SpinKitSpinningCircle(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "SquareCircle":
      loader = SpinKitSquareCircle(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "WanderingCubes":
      loader = SpinKitWanderingCubes(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "Wave":
      loader = SpinKitWave(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "DoubleBounce":
      loader = SpinKitDoubleBounce(
        color: HexColor(color),
        size: 100.0,
      );
      break;
    case "empty":
      loader = Container();
      break;
    default:
      loader = Container();
      break;
  }

  return loader;
}

Future<bool> _onBackPressed(context, InAppWebViewController webView) async {
  if (webView != null) {
    if (await webView.canGoBack()) {
      webView.goBack();
      return false;
    } else {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Close APP'),
              content: new Text('Are you sure want to quit this application ?'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text("CANCEL"),
                ),
                SizedBox(height: 16),
                new FlatButton(
                  onPressed: () => exit(0),
                  child: new Text("OK"),
                ),
              ],
            ),
          ) ??
          false;
    }
  }
  return false;
}

actionButtonMenu(String type, InAppWebViewController webView, Settings settings,
    BuildContext context) {
  //icon_menu icon_home icon_reload icon_share icon_empty
  switch (type) {
    case "icon_menu":
      _HomeScreen._scaffoldKey.currentState.openDrawer();
      break;
    case "icon_home":
      webView.loadUrl(url: settings.url);
      break;
    case "icon_reload":
      webView.reload();
      break;
    case "icon_share":
      shareApp(context, settings.title, settings.share);
      break;
    default:
      () {};
      break;
  }
}

shareApp(BuildContext context, String text, String share) {
  final RenderBox box = context.findRenderObject();
  Share.share(share,
      subject: text,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}
