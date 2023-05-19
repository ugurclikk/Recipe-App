import 'package:flutter/material.dart';

class respui {
  final double heightInDesign = 60;
  final double widthInDesign = 350;
  final double padding = 18;
  final double spaceBetween = 24;
  late double responsiveHeight = 0;
  late double responsiveWidth = 0;
  respui getinfoui(BuildContext context) {
    respui holder = respui();
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double deviceWidth = mediaQueryData.size.width;
    /*final double responsiveWidth =
        (deviceWidth / 2) - padding - (spaceBetween / 2);

    final double responsiveHeight =
        (heightInDesign / widthInDesign) * responsiveWidth;*/
    final double responsiveHeight = (mediaQueryData.size.height / 15);
    final double responsiveWidth = mediaQueryData.size.width;
    holder.responsiveHeight = responsiveHeight;
    holder.responsiveWidth = responsiveWidth;
    return holder;
  }
}
