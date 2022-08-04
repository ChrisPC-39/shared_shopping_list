import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../database/item.dart';
import '../../database/user.dart';
import '../../firebase_methods/firestore_methods.dart';

class PhoneCommentScreen extends StatefulWidget {
  final Item item;

  const PhoneCommentScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<PhoneCommentScreen> createState() => _PhoneCommentScreenState();
}

class _PhoneCommentScreenState extends State<PhoneCommentScreen> {
  String commentString = "";
  final commentController = TextEditingController();

  late User user;

  @override
  void initState() {
    super.initState();

    user = Hive.box("user").getAt(0) as User;
  }

  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 20,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(widget.item.userColor).withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: widget.item.isChecked
                      ? ThemeData.dark().cardColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.item.user,
                              style: TextStyle(
                                color: Color(
                                  widget.item.userColor,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            widget.item.date.hour < 10
                                ? "0"
                                : "" +
                                widget.item.date.hour.toString() +
                                ":" +
                                (widget.item.date.minute < 10
                                    ? "0"
                                    : "") +
                                widget.item.date.minute.toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.item.item,
                              style: TextStyle(
                                fontSize: 20,
                                color: !widget.item.isChecked
                                    ? Colors.grey
                                    : Colors.white,
                                decoration: !widget.item.isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "x${widget.item.itemCount}",
                            style: TextStyle(
                              fontSize: 20,
                              color: !widget.item.isChecked
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
              const Divider(thickness: 1),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("items")
                    .doc(widget.item.uid)
                    .collection("comments")
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (context, commentsnapshot) {
                  if (commentsnapshot.connectionState ==
                      ConnectionState.waiting ||
                      !commentsnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Flexible(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false,
                      ),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                        (commentsnapshot.data! as dynamic).docs.length,
                        itemBuilder: (context, index) {
                          final comment = (commentsnapshot.data! as dynamic)
                              .docs[index]
                              .data();

                          final commentDate = comment["date"].toDate();

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment["user"] + ": ",
                                      style: TextStyle(
                                        color: Color(
                                          comment["userColor"],
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      comment != 0 ? comment["comment"] : "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  comment != 0
                                      ? commentDate.hour < 10
                                      ? "0"
                                      : "" +
                                      commentDate.hour.toString() +
                                      ":" +
                                      (commentDate.minute < 10
                                          ? "0"
                                          : "") +
                                      commentDate.minute.toString()
                                      : "",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      onChanged: (newVal) => setState(() {
                        commentString = newVal;
                      }),
                      onSubmitted: (val) {
                        if(commentString.isEmpty) {
                          return;
                        }
                        submitTextField();
                        FocusScope.of(context).unfocus();
                        setState(() {
                          commentController.clear();
                          commentString = "";
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
                        labelText: "Comment",
                        hintText: "Say something nice",
                        floatingLabelStyle:
                        TextStyle(color: Color(user.color)),
                        // prefixIcon: Icon(
                        //   Icons.add,
                        //   color: Color(user.color),
                        // ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Color(user.color),
                    child: IconButton(
                      splashRadius: 20,
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => setState(() {
                        if (commentString.isEmpty) {
                          return;
                        }

                        submitTextField();
                        FocusScope.of(context).unfocus();
                        commentString = "";
                        commentController.clear();
                      }),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitTextField() {
    final comuid = const Uuid().v4();
    final user = Hive.box("user").getAt(0) as User;

    FirestoreMethods().addComment(
      uid: widget.item.uid,
      user: user.name,
      userColor: user.color,
      comment: commentString,
      date: DateTime.now(),
      comuid: comuid,
    );
  }
}
