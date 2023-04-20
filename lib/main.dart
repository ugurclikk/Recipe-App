import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:recipe/signinPage.dart';

import 'recipecontrol.dart';
import 'signupPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MyLogin(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff129575),
          child: Icon(Icons.add),
          onPressed: () {
            //get paketi sadece router icin kullanılıyor flutter navigator sorun cıkardıgı için simdilik öğrenene kadar get kullanıyorum
            Get.to(RecipeApp());
          },
        ),
      ),
    );
  }
}
