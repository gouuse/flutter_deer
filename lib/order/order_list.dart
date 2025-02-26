
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deer/widgets/my_refresh_list.dart';
import 'package:flutter_deer/widgets/state_layout.dart';

import 'widgets/order_item.dart';
import 'widgets/order_item_tag.dart';

class OrderList extends StatefulWidget {

  const OrderList({
    Key key,
    @required this.index,
    @required this.tabIndex,
  }): super(key: key);

  final int index;
  final int tabIndex;
  
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> with AutomaticKeepAliveClientMixin<OrderList>{

  /// 是否正在加载数据
  bool _isLoading = false;
  int _page = 1;
  final int _maxPage = 3;
  StateType _stateType = StateType.loading;
  int _index = 0;
  ScrollController _controller = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _onRefresh();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NotificationListener(
      onNotification: (ScrollNotification note){
        if(note.metrics.pixels == note.metrics.maxScrollExtent){
          _loadMore();
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        displacement: 120.0, /// 默认40， 多添加的80为Header高度
        child: CustomScrollView(
          /// 这里指定controller可以与外层NestedScrollView的滚动分离，避免一处滑动，5个Tab中的列表同步滑动。
          controller: _index != widget.tabIndex ? _controller : null,
          key: PageStorageKey<String>("$_index"),
          slivers: <Widget>[
            SliverOverlapInjector(
              ///SliverAppBar的expandedHeight高度,避免重叠
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: _list.isEmpty ? SliverFillRemaining(child: StateLayout(type: _stateType)) : SliverList(
                delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  return index < _list.length ? (index % 5 == 0 ? OrderItemTag(date: "2019年2月5日", orderTotal: 4) : OrderItem(index: _index,))
                      : MoreWidget(_list.length, _hasMore(), 10);
                },
                childCount: _list.length + 1),
              ),
            )
          ],
        ),
      ),
    );
  }

  List _list = [];

  Future _onRefresh() async {
    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _page = 1;
        _list = List.generate(10, (i) => 'newItem：$i');
      });
    });
  }

  bool _hasMore(){
    return _page < _maxPage;
  }

  Future _loadMore() async {
    if (_isLoading) {
      return;
    }
    if (!_hasMore()){
      return;
    }
    _isLoading = true;
    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _list.addAll(List.generate(10, (i) => 'newItem：$i'));
        _page ++;
        _isLoading = false;
      });
    });
  }
  
  @override
  bool get wantKeepAlive => true;
}
