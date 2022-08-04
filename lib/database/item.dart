class Item {
  final String uid;
  final String user;
  final int userColor;
  final String item;
  final int itemCount;
  final DateTime date;
  final bool isChecked;
  final List<dynamic> votedToDeleteBy;

  Item({
    required this.userColor,
    required this.item,
    required this.itemCount,
    required this.date,
    required this.isChecked,
    required this.votedToDeleteBy,
    required this.uid,
    required this.user,
  });
}
