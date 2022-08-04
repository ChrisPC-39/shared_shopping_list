import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../firebase_methods/firestore_methods.dart';
import '../../database/user.dart';

class WebMainScreen extends StatefulWidget {
  const WebMainScreen({Key? key}) : super(key: key);

  @override
  State<WebMainScreen> createState() => _WebMainScreenState();
}

class _WebMainScreenState extends State<WebMainScreen> {
  final user = Hive.box("user").getAt(0) as User;

  int addItemCount = 1;
  String addItemString = "";
  final TextEditingController addItemController = TextEditingController();

  final List<String> hintList = [
    "Mici",
    "Mustar",
    "Ketchup",
    "Paine",
    "Bautura",
    "Boxe",
    "Voie buna"
  ];

  @override
  void dispose() {
    addItemController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
        child: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              SizedBox(
                width: 500,
                child: Column(
                  children: [
                    Flexible(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("items")
                            .orderBy("date", descending: true)
                            .snapshots(),
                        builder: (context, itemsnapshot) {
                          if (itemsnapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !itemsnapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                (itemsnapshot.data! as dynamic).docs.length,
                            itemBuilder: (context, index) {
                              final item = (itemsnapshot.data! as dynamic)
                                  .docs[index]
                                  .data();

                              final itemDate = item["date"].toDate();

                              return !item["item"]
                                      .toLowerCase()
                                      .contains(addItemString.toLowerCase())
                                  ? Container()
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          FirestoreMethods().updateItem(
                                            uid: item["uid"],
                                            user: item["user"],
                                            userColor: item["userColor"],
                                            item: item["item"],
                                            itemCount: item["itemCount"],
                                            date: item["date"].toDate(),
                                            isChecked: !item["isChecked"],
                                            votedToDeleteBy:
                                                item["votedToDeleteBy"],
                                          );
                                        },
                                        onLongPress: () {
                                          voteToDelete(
                                            item,
                                            item["votedToDeleteBy"],
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color(item["userColor"])
                                                  .withOpacity(0.5),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: !item["isChecked"]
                                                ? ThemeData.dark()
                                                    .cardColor
                                                    .withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        item["user"],
                                                        style: TextStyle(
                                                          color: Color(
                                                            item["userColor"],
                                                          ),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      itemDate.hour < 10
                                                          ? "0"
                                                          : "" +
                                                              itemDate.hour
                                                                  .toString() +
                                                              ":" +
                                                              (itemDate.minute <
                                                                      10
                                                                  ? "0"
                                                                  : "") +
                                                              itemDate.minute
                                                                  .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        item["item"],
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color:
                                                              item["isChecked"]
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .white,
                                                          decoration: item[
                                                                  "isChecked"]
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      "x${item["itemCount"]}",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: item["isChecked"]
                                                            ? Colors.grey
                                                            : Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: addItemController,
                            onChanged: (newVal) => setState(() {
                              addItemString = newVal;
                            }),
                            onSubmitted: (val) {
                              submitTextField();
                              setState(() {
                                addItemController.clear();
                                addItemString = "";
                              });
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(user.color)),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(user.color)),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              hintText:
                                  hintList[Random().nextInt(hintList.length)],
                              labelText: "Item",
                              floatingLabelStyle:
                                  TextStyle(color: Color(user.color)),
                              prefixIcon: Icon(
                                Icons.add,
                                color: Color(user.color),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            IconButton(
                              splashRadius: addItemCount == 1 ? 1 : 20,
                              icon: Icon(
                                Icons.remove,
                                color: addItemCount == 1
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                              onPressed: () => setState(() {
                                if (addItemCount > 1) {
                                  addItemCount--;
                                }
                              }),
                            ),
                            const SizedBox(width: 5),
                            Text(addItemCount.toString()),
                            const SizedBox(width: 5),
                            IconButton(
                              splashRadius: 20,
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() {
                                addItemCount++;
                              }),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void voteToDelete(dynamic item, List<dynamic> votedBy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Vote to delete"),
          content: SizedBox(
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("2 votes are required in order to delete.\n"),
                Text("Currently ${votedBy.length} vote(s) have been made.\n"),
                Visibility(
                  visible: votedBy.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Voted by:"),
                      Text("• ${votedBy.isNotEmpty ? votedBy[0] : ""}"),
                    ],
                  )
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Delete"),
              onPressed: () => setState(() {
                final user = Hive.box("user").getAt(0) as User;
                final List<dynamic> votedToDeleteBy = item["votedToDeleteBy"];

                if(votedToDeleteBy.length >= 2) {
                  FirestoreMethods().deleteItem(uid: item["uid"]);
                  Navigator.of(context).pop();
                  return;
                }

                if(votedToDeleteBy.contains(user.name)) {
                  Navigator.of(context).pop();
                  return;
                }

                votedToDeleteBy.add(user.name);

                FirestoreMethods().updateItem(
                  uid: item["uid"],
                  user: item["user"],
                  userColor: item["userColor"],
                  item: item["item"],
                  itemCount: item["itemCount"],
                  date: item["date"].toDate(),
                  isChecked: item["isChecked"],
                  votedToDeleteBy: votedToDeleteBy,
                );

                if(votedToDeleteBy.length >= 2) {
                  FirestoreMethods().deleteItem(uid: item["uid"]);
                  Navigator.of(context).pop();
                  return;
                }

                Navigator.of(context).pop();
              }),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red[400]),
              ),
            ),
          ],
        );
      },
    );
  }

  void submitTextField() {
    final uid = const Uuid().v4();
    final user = Hive.box("user").getAt(0) as User;

    FirestoreMethods().addItem(
      uid: uid,
      user: user.name,
      userColor: user.color,
      item: addItemString,
      itemCount: addItemCount,
      date: DateTime.now(),
      isChecked: false,
      votedToDeleteBy: [],
    );
  }
}
