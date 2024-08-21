import 'package:vid/model/feed_item.dart';

Future<List<FeedItem>> fetchFeedsFromApi(int pageKey, int pageSize) async {
  // Simulate API call
  await Future.delayed(Duration(seconds: 2));

  // Create a list for the feed items
  List<FeedItem> feedItems = [];

  // Add a mix of video and image posts
  List<String> videoUrls = [
     'https://assets.mixkit.co/videos/preview/mixkit-taking-photos-from-different-angles-of-a-model-34421-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4',
    'https://allfit.s3.eu-west-3.amazonaws.com/videos/iViMAC4ofvYMT6TyDIBMmxo4l4fDXctzAUK3skIQ.mp4'
  ];

  feedItems.addAll(
    List.generate(
      pageSize,
      (index) => FeedItem(
        userName: 'User ${pageKey + index + 1}',
        userAvatarUrl: 'https://placekitten.com/200/200',
        postTime: 'Just now',
        content: 'This is a post content for feed item ${pageKey + index + 1}.',
        contentImageUrl: index % 3 == 0 ? 'https://placekitten.com/400/300' : null,
        videoUrl: index % 3 == 1 ? videoUrls[index % videoUrls.length] : null,
        likes: (pageKey + index + 1) * 2,
        comments: (pageKey + index + 1) * 1,
        shares: (pageKey + index + 1) * 0,
      ),
    ),
  );

  return feedItems;
}
