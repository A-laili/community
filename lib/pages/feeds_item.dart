import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vid/pages/comment_page.dart';
import 'package:vid/pages/video_details.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import 'package:vid/database.dart';
import 'package:vid/model/feed_item.dart';

enum MediaType { image, video }

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  static const _pageSize = 20;
  final PagingController<int, FeedItem> _pagingController = PagingController(firstPageKey: 0);
  List<FeedItem> _feedItems = [];
  List<File> _selectedMedia = []; // Changed to a list to store multiple images
  MediaType? _mediaType; // To store the media type (image or video)
  VideoPlayerController? _videoPlayerController; // Controller for video playback

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await fetchFeedsFromApi(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
      setState(() {
        _feedItems.addAll(newItems);
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // Function to pick multiple images
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(); // pickMultiImage allows selecting multiple images

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedMedia = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
        _mediaType = MediaType.image; // Set media type to 'image'
      });
    }
  }

  // Function to pick a video
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = [File(pickedFile.path)];
        _mediaType = MediaType.video; // Set media type to 'video'
        _videoPlayerController = VideoPlayerController.file(_selectedMedia.first)
          ..initialize().then((_) {
            setState(() {}); // Refresh UI after initialization
          });
      });
    }
  }

  // Function to show the bottom sheet
void _showPostBottomSheet(BuildContext context) {
  final TextEditingController _postController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9, // Adjust height as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Post",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _postController,
                    maxLines: null, // Allow multiple lines
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display selected media if available
                  if (_selectedMedia.isNotEmpty)
                    _mediaType == MediaType.image
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedMedia.asMap().entries.map((entry) {
                              int index = entry.key;
                              File file = entry.value;
                              return Stack(
                                children: [
                                  Image.file(
                                    file,
                                    height: 100, // Adjust height as needed
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedMedia.removeAt(index);
                                          if (_selectedMedia.isEmpty) {
                                            _mediaType = null;
                                          }
                                        });
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 12,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          )
                        : _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController!),
                              )
                            : Container(
                                height: 200,
                                color: Colors.black,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImages, // Change this to _pickImages
                          icon: const Icon(Icons.add_a_photo_rounded, color: Colors.pink),
                          label: const Text("Add Pictures", style: TextStyle(color: Colors.pink)),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.video_collection_sharp, color: Color.fromARGB(255, 27, 126, 175)),
                          label: const Text("Add Video", style: TextStyle(color: Color.fromARGB(255, 27, 126, 175))),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.label_important_outline_sharp, size: 30),
                            onPressed: () {
                              if (_postController.text.isNotEmpty || _selectedMedia.isNotEmpty) {
                                // Handle post submission logic here
                                print("User post: ${_postController.text}");
                                if (_selectedMedia.isNotEmpty) {
                                  _selectedMedia.forEach((media) {
                                    print("Media path: ${media.path}");
                                  });
                                }
                                _postController.clear(); // Clear the text field after submission
                                setState(() {
                                  _selectedMedia.clear(); // Clear the selected media after submission
                                  _mediaType = null;
                                  _videoPlayerController?.dispose(); // Dispose of the video controller
                                });
                              }
                              Navigator.pop(context); // Close the bottom sheet after submission
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  @override
  void dispose() {
    _pagingController.dispose();
    _videoPlayerController?.dispose(); // Dispose of the video controller if it exists
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeds'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () => _showPostBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Card(
                elevation: 4.0,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.grey),
                      SizedBox(width: 10),
                      Text("What's on your mind?", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PagedListView<int, FeedItem>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<FeedItem>(
                itemBuilder: (context, item, index) => FeedItemWidget(
                  feedItem: item,
                  feedItems: _feedItems,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
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
      widget.feedItem.likes += 1;
    });
  }

  void _showCommentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CommentBottomSheet(feedItem: widget.feedItem);
      },
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
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.feedItem.thumbnailUrl ??
                          'https://via.placeholder.com/400x300'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  onTap: () => _showCommentBottomSheet(context),
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined, size: 20),
                      SizedBox(width: 5),
                      Text('${widget.feedItem.comments} Comments'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

