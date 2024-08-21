import 'package:flutter/material.dart';
import 'package:vid/model/feed_item.dart';
import 'package:vid/pages/comment_page.dart';
import 'package:vid/pages/video_details.dart';

class FeedItemWidget extends StatefulWidget {
  final FeedItem feedItem;
  final List<FeedItem> feedItems;

  FeedItemWidget({required this.feedItem, required this.feedItems});

  @override
  _FeedItemWidgetState createState() => _FeedItemWidgetState();
}

class _FeedItemWidgetState extends State<FeedItemWidget> {
  void _incrementLikes() {
    setState(() {
      widget.feedItem.likes += 1; // Increment likes count
    });
  }

  void _navigateToComments(BuildContext context) {
    // Navigate to the comments page or handle comment actions here
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(feedItem: widget.feedItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.feedItem.userAvatarUrl),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.feedItem.userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.feedItem.postTime,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(widget.feedItem.content),
            if (widget.feedItem.contentImageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.network(widget.feedItem.contentImageUrl!),
              ),
            if (widget.feedItem.videoUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoDetailPage(
                        feedItems: widget.feedItems,
                        initialIndex: widget.feedItems.indexOf(widget.feedItem),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200, // Adjust height as needed
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.feedItem.thumbnailUrl ??
                          'https://via.placeholder.com/400x300'), // Use a placeholder or thumbnail URL
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _incrementLikes,
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 20),
                      SizedBox(width: 5),
                      Text('${widget.feedItem.likes} Likes'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToComments(context),
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined, size: 20),
                      SizedBox(width: 5),
                      Text('${widget.feedItem.comments} Comments'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 5),
                    Text('${widget.feedItem.shares} Shares'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


