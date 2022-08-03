import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/user.dart';
import 'phone_screens/phone_main_screen.dart';
import 'responsive_layout.dart';
import 'web_screens/web_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool canSignIn = true;

  final TextEditingController nameController = TextEditingController();

  Color pickerColor = Colors.blue[300]!;
  Color currentColor = Colors.blue[300]!;

  @override
  void initState() {
    super.initState();

    final randColor =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];
    pickerColor = randColor[300]!;
    currentColor = randColor[300]!;
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              const SelectableText(
                ":>",
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
              const SizedBox(height: 25),
              Container(
                height: 200,
                width: 350,
                decoration: BoxDecoration(
                  color: ThemeData.dark().cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      const SelectableText(
                        "Name",
                      ),
                      const SizedBox(height: 5),
                      Flexible(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Flexible(
                        child: ElevatedButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("User color"),
                              Icon(Icons.color_lens),
                            ],
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              currentColor,
                            ),
                            fixedSize: MaterialStateProperty.all(
                              const Size(400, 40),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Pick a color!'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: pickerColor,
                                    onColorChanged: changeColor,
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: const Text('Got it'),
                                    onPressed: () {
                                      setState(
                                          () => currentColor = pickerColor);
                                      // print(currentColor.value);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      Flexible(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.green[400],
                            ),
                            fixedSize: MaterialStateProperty.all(
                              const Size(400, 40),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Text("Sign in"),
                          onPressed: () => setState(() {
                            if (nameController.text.isEmpty) {
                              canSignIn = false;
                            } else {
                              canSignIn = true;

                              if (Hive.box("user").length != 0) {
                                for (int i = 0;
                                    i < Hive.box("user").length;
                                    i++) {
                                  Hive.box("user").deleteAt(i);
                                }
                              }

                              Hive.box("user").add(
                                User(
                                  nameController.text,
                                  currentColor.value,
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResponsiveLayout(
                                    phoneBody: PhoneMainScreen(),
                                    webBody: WebMainScreen(),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: !canSignIn,
                child: Container(
                  width: 350,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("No anonymity allowed"),
                        IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() {
                            canSignIn = true;
                          }),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
