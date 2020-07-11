//images
import 'package:flutter/material.dart';

class UIImages {
  static const String imageDir = "assets/img";
  static Image logo = Image.asset("$imageDir/logo.png");
  static Image bg = Image.asset("$imageDir/bg.jpg");

  static Image no = Image.asset(
      "$imageDir/no.png",
      height: 50,
      width: 50,
      color: Colors.white
  );

  /** Navigation Bar Style */
  static AssetImage navigation_left =
      AssetImage("$imageDir/navigation_left.png");
  static AssetImage navigation_right =
      AssetImage("$imageDir/navigation_right.png");
  static AssetImage navigation_center =
      AssetImage("$imageDir/navigation_center.png");
  static AssetImage navigation_no = AssetImage("$imageDir/navigation_no.png");


  /** Header Type Style */
  static AssetImage header_type_nameapp =
  AssetImage("$imageDir/header_type_nameapp.png");
  static AssetImage header_type_logo =
  AssetImage("$imageDir/header_type_logo.png");
  static AssetImage header_type_empty = AssetImage("$imageDir/header_type_empty.png");


  /** Left Button Option */
  static AssetImage
  menu_left_drawer =
      AssetImage("$imageDir/menu_left_drawer.png");
  static AssetImage menu_left_home = AssetImage("$imageDir/menu_left_home.png");
  static AssetImage menu_left_roload =
      AssetImage("$imageDir/menu_left_roload.png");
  static AssetImage menu_left_share =
      AssetImage("$imageDir/menu_left_share.png");
  static AssetImage menu_left_no = AssetImage("$imageDir/menu_left_no.png");

  /** Right Menu */
  static AssetImage menu_right_drawer =
      AssetImage("$imageDir/menu_right_drawer.png");
  static AssetImage menu_right_home =
      AssetImage("$imageDir/menu_right_home.png");
  static AssetImage menu_right_no = AssetImage("$imageDir/menu_right_no.png");
  static AssetImage menu_right_roload =
      AssetImage("$imageDir/menu_right_roload.png");
  static AssetImage menu_right_share =
      AssetImage("$imageDir/menu_right_share.png");

  /** Icons */
  static Image checked = Image.asset(
    "$imageDir/checked.png",
    height: 45,
    width: 45,
    color: Colors.white
  );

}
