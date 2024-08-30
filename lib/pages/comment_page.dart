import 'package:flutter/material.dart';
import 'package:vid/model/feed_item.dart';

class CommentBottomSheet extends StatefulWidget {
  final FeedItem feedItem;

  CommentBottomSheet({required this.feedItem});

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<String> comments = [];

  @override
  void initState() {
    super.initState();
    // Load initial comments if available
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add(_commentController.text);
        _commentController.clear();
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(  // Use Container or SizedBox to set the height
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Column adjusts to content height
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context, comments.length);
                },
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true, // Ensures the ListView doesn't expand infinitely
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(comments[index]),
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _addComment,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
void showCommentBottomSheet(BuildContext context, FeedItem feedItem) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return CommentBottomSheet(feedItem: feedItem);
    },
  );
}

