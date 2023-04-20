import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe/signupPage.dart';

import 'recipecontrol.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    late String _email, _password;
    return Container(
      decoration: const BoxDecoration(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 80),
            child: const Text(
              "Hello,\nWelcome Back.",
              style: TextStyle(color: Colors.black, fontSize: 32),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  right: 35,
                  left: 35,
                  top: MediaQuery.of(context).size.height * 0.4),
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email"),
                      TextFormField(
                        onSaved: (value) => _email = value!,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text("Enter Password"),
                      TextFormField(
                        onSaved: (value) => _password = value!,
                        obscureText: true,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeApp(),
                              ));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _email, password: _password)
                                .then((value) {});

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [Text("Success")],
                                );
                              },
                            );
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8)),
                            height: 60,
                            width: 350,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sign in",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                                Icon(
                                  Icons.arrow_right_alt_outlined,
                                  color: Colors.white,
                                  size: 32,
                                )
                              ],
                            )),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 125,
                            child: Divider(
                              thickness: 2,
                            ),
                          ),
                          Text("Or Sign in With"),
                          Container(
                            width: 121,
                            child: Divider(
                              thickness: 2,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/gbutton.png",
                            width: 100,
                            height: 100,
                          ),
                          Image.asset(
                            "assets/fbbutton.png",
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have a account?"),
                            TextButton(
                                onPressed: () {
                                  Get.to(MyRegister());
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.orange),
                                ))
                          ])
                    ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
