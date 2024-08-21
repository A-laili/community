import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:vid/database.dart';
import 'package:vid/pages/comment_page.dart';
import 'package:video_player/video_player.dart';
import 'package:vid/model/feed_item.dart';

class VideoDetailPage extends StatefulWidget {
  final List<FeedItem> feedItems;
  final int initialIndex;

  VideoDetailPage({required this.feedItems, required this.initialIndex});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  List<FeedItem> _feedItems = [];
  bool _isLoading = false;
  int _pageKey = 0;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _feedItems = widget.feedItems;
    _pageKey = widget.initialIndex;
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    List<FeedItem> newItems = await fetchFeedsFromApi(_pageKey, _pageSize);
    setState(() {
      _feedItems.addAll(newItems);
      _pageKey += _pageSize;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Details'),
      ),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                !_isLoading) {
              _loadMore(); // Fetch more items when the user scrolls to the bottom
            }
            return false;
          },
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return VideoDetailCard(feedItem: _feedItems[index]);
            },
            itemCount: _feedItems.length,
            scrollDirection: Axis.vertical,
            index: widget.initialIndex,
          ),
        ),
      ),
    );
  }
}

class VideoDetailCard extends StatefulWidget {
  final FeedItem feedItem;

  VideoDetailCard({required this.feedItem});

  @override
  _VideoDetailCardState createState() => _VideoDetailCardState();
}

class _VideoDetailCardState extends State<VideoDetailCard> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  void _initializeVideoController() {
    final videoUrl = widget.feedItem.videoUrl;
    if (videoUrl != null) {
      _videoController = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _incrementLikes() {
    setState(() {
      widget.feedItem.likes += 1; // Increment likes count
    });
  }

  void _navigateToComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(feedItem: widget.feedItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_videoController != null && _videoController!.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          )
        else
          Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 80,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.feedItem.userName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.feedItem.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: _incrementLikes,
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          '${widget.feedItem.likes}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: _navigateToComments,
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          '${widget.feedItem.comments}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.share, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    '${widget.feedItem.shares}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
