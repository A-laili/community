import 'package:flutter/material.dart';
import 'package:vid/model/feed_item.dart';

class CommentPage extends StatefulWidget {
  final FeedItem feedItem;

  CommentPage({required this.feedItem});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
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

  void _onBackPressed() {
    Navigator.pop(context, comments.length);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Comments'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _onBackPressed,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.feedItem.content,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (widget.feedItem.contentImageUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.network(widget.feedItem.contentImageUrl!),
                ),
              Divider(),
              Expanded(
                child: ListView.builder(
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
      ),
    );
  }
}
