import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vid/model/feed_item.dart';
import 'package:vid/pages/feeds_page.dart';
import 'package:vid/database.dart';

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  static const _pageSize = 20;
  final PagingController<int, FeedItem> _pagingController = PagingController(firstPageKey: 0);
  List<FeedItem> _feedItems = [];

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

      // Update the feed items list
      setState(() {
        _feedItems.addAll(newItems);
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeds'),
      ),
      body: PagedListView<int, FeedItem>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<FeedItem>(
          itemBuilder: (context, item, index) => FeedItemWidget(
            feedItem: item,
            feedItems: _feedItems,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
