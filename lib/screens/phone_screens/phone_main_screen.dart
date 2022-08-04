import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../database/item.dart';
import '../../firebase_methods/firestore_methods.dart';
import '../../database/user.dart';
import 'phone_comment_screen.dart';

class PhoneMainScreen extends StatefulWidget {
  const PhoneMainScreen({Key? key}) : super(key: key);

  @override
  State<PhoneMainScreen> createState() => _PhoneMainScreenState();
}

class _PhoneMainScreenState extends State<PhoneMainScreen> {
  final user = Hive.box("user").getAt(0) as User;

  int addItemCount = 1;
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
          child: Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Column(
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

                              return !item["item"].toLowerCase().contains(
                                      addItemController.text.toLowerCase())
                                  ? Container()
                                  : Row(
                                      children: [
                                        Flexible(
                                          child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection("items")
                                                  .doc(item["uid"])
                                                  .collection("comments")
                                                  .orderBy("date",
                                                      descending: true)
                                                  .snapshots(),
                                              builder:
                                                  (context, commentsnapshot) {
                                                if (commentsnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting ||
                                                    !commentsnapshot.hasData) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }

                                                dynamic comment = 0;
                                                DateTime commentDate =
                                                    DateTime(0);
                                                final numOfComments =
                                                    (commentsnapshot.data!
                                                            as dynamic)
                                                        .docs
                                                        .length;
                                                if (numOfComments > 0) {
                                                  comment = (commentsnapshot
                                                          .data! as dynamic)
                                                      .docs[0]
                                                      .data();

                                                  commentDate =
                                                      comment["date"].toDate();
                                                }

                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom:
                                                              numOfComments > 0
                                                                  ? 0
                                                                  : 10),
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        onTap: () {
                                                          FirestoreMethods()
                                                              .updateItem(
                                                            uid: item["uid"],
                                                            user: item["user"],
                                                            userColor: item[
                                                                "userColor"],
                                                            item: item["item"],
                                                            itemCount: item[
                                                                "itemCount"],
                                                            date: item["date"]
                                                                .toDate(),
                                                            isChecked: !item[
                                                                "isChecked"],
                                                            votedToDeleteBy: item[
                                                                "votedToDeleteBy"],
                                                          );
                                                        },
                                                        onLongPress: () {
                                                          voteToDelete(
                                                            item,
                                                            item[
                                                                "votedToDeleteBy"],
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: Color(item[
                                                                      "userColor"])
                                                                  .withOpacity(
                                                                      0.5),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: !item[
                                                                    "isChecked"]
                                                                ? ThemeData
                                                                        .dark()
                                                                    .cardColor
                                                                    .withOpacity(
                                                                        0.1)
                                                                : Colors.grey
                                                                    .withOpacity(
                                                                        0.1),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        item[
                                                                            "user"],
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(
                                                                            item["userColor"],
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      itemDate.hour <
                                                                              10
                                                                          ? "0"
                                                                          : "" +
                                                                              itemDate.hour.toString() +
                                                                              ":" +
                                                                              (itemDate.minute < 10 ? "0" : "") +
                                                                              itemDate.minute.toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        item[
                                                                            "item"],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color: item["isChecked"]
                                                                              ? Colors.grey
                                                                              : Colors.white,
                                                                          decoration: item["isChecked"]
                                                                              ? TextDecoration.lineThrough
                                                                              : TextDecoration.none,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      "x${item["itemCount"]}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            20,
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
                                                    ),
                                                    Visibility(
                                                      visible: comment != 0,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10),
                                                        child: InkWell(
                                                          onTap: () =>
                                                              Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PhoneCommentScreen(
                                                                item: Item(
                                                                  uid: item[
                                                                      "uid"],
                                                                  user: item[
                                                                      "user"],
                                                                  userColor: item[
                                                                      "userColor"],
                                                                  item: item[
                                                                      "item"],
                                                                  itemCount: item[
                                                                      "itemCount"],
                                                                  date: item[
                                                                          "date"]
                                                                      .toDate(),
                                                                  isChecked: !item[
                                                                      "isChecked"],
                                                                  votedToDeleteBy:
                                                                      item[
                                                                          "votedToDeleteBy"],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      comment !=
                                                                              0
                                                                          ? comment["user"] +
                                                                              ": "
                                                                          : "",
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            Color(
                                                                          comment != 0
                                                                              ? comment["userColor"]
                                                                              : Colors.red.value,
                                                                        ),
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        comment !=
                                                                                0
                                                                            ? comment["comment"]
                                                                            : "",
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.fade,
                                                                        softWrap:
                                                                            false,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            15),
                                                                    Text(
                                                                      comment !=
                                                                              0
                                                                          ? commentDate.hour < 10
                                                                              ? "0"
                                                                              : "" + commentDate.hour.toString() + ":" + (commentDate.minute < 10 ? "0" : "") + commentDate.minute.toString()
                                                                          : "",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      "$numOfComments comment(s)",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .chevron_right,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 18,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                        const SizedBox(width: 5),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.message,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PhoneCommentScreen(
                                                item: Item(
                                                  uid: item["uid"],
                                                  user: item["user"],
                                                  userColor: item["userColor"],
                                                  item: item["item"],
                                                  itemCount: item["itemCount"],
                                                  date: item["date"].toDate(),
                                                  isChecked: !item["isChecked"],
                                                  votedToDeleteBy:
                                                      item["votedToDeleteBy"],
                                                ),
                                              ),
                                            ),
                                          ),
                                          splashRadius: 20,
                                        ),
                                      ],
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
                            onSubmitted: (val) {
                              if (addItemController.text.isEmpty) {
                                return;
                              }

                              submitTextField();
                              FocusScope.of(context).unfocus();
                              addItemController.clear();
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
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Color(user.color),
                          child: IconButton(
                            splashRadius: 20,
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              if (addItemController.text.isEmpty) {
                                return;
                              }

                              submitTextField();
                              FocusScope.of(context).unfocus();
                              addItemController.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
                    )),
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

                if (votedToDeleteBy.length >= 2) {
                  FirestoreMethods().deleteItem(uid: item["uid"]);
                  Navigator.of(context).pop();
                  return;
                }

                if (votedToDeleteBy.contains(user.name)) {
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

                if (votedToDeleteBy.length >= 2) {
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
      item: addItemController.text,
      itemCount: addItemCount,
      date: DateTime.now(),
      isChecked: false,
      votedToDeleteBy: [],
    );
  }
}
