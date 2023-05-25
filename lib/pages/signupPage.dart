import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: unused_import
import '../controller/local_notification_controller.dart';
import 'signinPage.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  @override
  Widget build(BuildContext context) {
    late String _email, _password;
    final _formKey = GlobalKey<FormState>();
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              Stack(children: [
            Container(
              padding: EdgeInsets.only(
                right: 35,
                left: 35,
                // top: MediaQuery.of(context).size.height * 0.27
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Create an Account\n\nLet’s help you set up your account, it won’t take long.".tr(),
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Text("Name".tr()),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            hintText: 'Enter Name'.tr(),
                            hintStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text("E-Mail"),
                        const SizedBox(
                          height: 10,
                        ),
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
                            hintText: 'Enter Email'.tr(),
                            hintStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text("Password".tr()),
                        const SizedBox(
                          height: 10,
                        ),
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
                            hintText: 'Enter Password'.tr(),
                            hintStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text("Reconfirm Password".tr()),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
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
                            hintText: 'Reconfirm Password'.tr(),
                            hintStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _email, password: _password)
                                  .then((_) {
                                /*  Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomePage()));*/
                              });
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8)),
                              height: 60,
                              width: constraints.maxWidth < 350 ? 350 : 775,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Sing up".tr(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Icon(
                                    Icons.arrow_right_alt,
                                    color: Colors.white,
                                  )
                                ],
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 125,
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Text("Or Sign up With".tr()),
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
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already a member?".tr()),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyLogin(),
                                      ));

                                  //Get.to(MyLogin());
                                },
                                child: Text(
                                  'Sign in'.tr(),
                                  style: TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ]),
                      ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
