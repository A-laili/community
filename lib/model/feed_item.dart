class FeedItem {
  String userName;
  String userAvatarUrl;
  String postTime;
  String content;
  String? contentImageUrl;
  String? videoUrl;
  String? thumbnailUrl;
  int likes;
  int comments;
  int shares;

  FeedItem({
    required this.userName,
    required this.userAvatarUrl,
    required this.postTime,
    required this.content,
    this.contentImageUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.likes = 0,  // Default to 0 likes
    this.comments = 0,  // Default to 0 comments
    this.shares = 0,  // Default to 0 shares
  });
}
