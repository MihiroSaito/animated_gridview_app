import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedGridView extends StatefulWidget {

  const AnimatedGridView({
    Key? key,
    required this.gridviewItems,
    required this.selectingItemsList,
    required this.crossAxisCount,
    required this.enableAnimation,
    required this.streamController,

    /// Gridviewに渡す変数
    /// todo: ここの値を変更した場合、offsetAnimationの値を調節する
    this.padding = const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 15),
    this.crossAxisSpacing = 10.0,
    this.mainAxisSpacing = 10.0,
  }) : super(key: key);

  final List<Map<String, dynamic>> gridviewItems;
  final List<Map<String, dynamic>> selectingItemsList;
  final int crossAxisCount;
  final bool enableAnimation;
  final StreamController<bool> streamController;

  /// Gridviewに渡す変数
  final EdgeInsets padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  @override
  _AnimatedGridViewState createState() => _AnimatedGridViewState();
}

class _AnimatedGridViewState extends State<AnimatedGridView> with TickerProviderStateMixin {

  List<AnimationController> animationControllerList = [];
  List<Animation<Offset>> offsetAnimationList = [];
  GlobalKey gridviewKey = GlobalKey();
  GlobalKey gridviewItemKey = GlobalKey();
  late ScrollController _scrollControllerForGridview;
  late ScrollController _scrollControllerForSingleChildView;
  late List<Map<String, dynamic>> itemsRelateInAnimationList = [];

  int count = 0;
  late Size gridviewItemSize;

  @override
  void initState() {
    _scrollControllerForGridview = ScrollController();
    _scrollControllerForSingleChildView = ScrollController();
    createAnimations(widget.gridviewItems.length);
    widget.streamController.stream.listen((data){
      if (data == true) {
        _startAnimation(
          gridviewItems: widget.gridviewItems,
          selectingItemsList: widget.selectingItemsList,
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpace: widget.mainAxisSpacing,
          padding: widget.padding
        );
      } else {
        _finishAnimation();
      }
    });
    super.initState();
  }


  void createAnimations(int itemLength) {
    for (int i = 0; i < itemLength; i++) {
      setState(() {
        animationControllerList.add(
            AnimationController(
                duration: const Duration(milliseconds: 300),
                vsync: this)
        );

        /// アイテムを削除した時にListを新しくするため、それまで空データを格納しておく
        final Animation<Offset> offsetAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 0.0),
        ).animate(animationControllerList.last);
        offsetAnimationList.add(offsetAnimation);

      });
    }
  }



  void _startAnimation({
    required List<Map<String, dynamic>> gridviewItems,
    required List<Map<String, dynamic>> selectingItemsList,
    required int crossAxisCount,
    required double mainAxisSpace,
    required EdgeInsets padding
  }) {

    // setState(() {
    //   isUsingPartGridview = true;
    // });

    final RenderBox renderBox = gridviewKey.currentContext?.findRenderObject() as RenderBox;
    final Size gridViewSize = renderBox.size;
    /// girdviewのSize

    var result = gridViewSize.height / (gridviewItemSize.height + mainAxisSpace);
    int displayableRows = result.ceil() + 1;
    int displayableItemCount = displayableRows * crossAxisCount;
    /// 1画面に表示できるアイテムの数を取得する。

    double aaa = _scrollControllerForGridview.offset / (gridviewItemSize.height + mainAxisSpace);
    /// 画面外（上）に段数を取得する 例: 3.31243215（3段と1/3段ある）

    int previouslyDisplayedItemCount = aaa.floor() * crossAxisCount;
    /// 画面外（上）にあるアイテムの数を取得する。

    itemsRelateInAnimationList = [...gridviewItems];
    itemsRelateInAnimationList.removeRange(0, previouslyDisplayedItemCount);
    itemsRelateInAnimationList.removeRange(displayableItemCount + selectingItemsList.length, itemsRelateInAnimationList.length);
    /// アニメーションに関係するアイテムの数を取得

    double affectsAnimationAreaHeight =
        (itemsRelateInAnimationList.length / crossAxisCount) *
            (gridviewItemSize.height + mainAxisSpace) + padding.top + padding.bottom;
    /// アニメーションに必要なWidgetの高さ。



    double bbb = double.parse(aaa.toString().replaceAll('${aaa.floor()}.', '0.'));
    /// 画面に表示されている最初の段の表示具合（%）を取得する 例: 0.562238（1つのアイテムの約半分が表示されている）

    double scrollAmountSurplus = gridviewItemSize.height * bbb;
    /// 画面に表示されている最初の段の表示具合（サイズ）を取得する





    /// アイテムを削除する前と削除した後の位置を管理するリストを取得する。
    final List<Map<String, dynamic>> movingItemsInfoList = identifyThePositionToMove(
        gridviewItems: gridviewItems,
        selectingItemsList: selectingItemsList,
        crossAxisCount: crossAxisCount);

    /// 空データを消す。
    offsetAnimationList.clear();

    for (int i = 0; i < animationControllerList.length; i++) {
      if (widget.selectingItemsList.contains(widget.gridviewItems[i])) {

        /// 削除するアイテムのアニメーション（slideAnimationはなし）
        final Animation<Offset> offsetAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 0.0),
        ).animate(animationControllerList.last);
        offsetAnimationList.add(offsetAnimation);

      } else {

        final dx = 1.085 * movingItemsInfoList[i]['movingColumnCount'];
        final dy = 1.085 * movingItemsInfoList[i]['movingRowCount'];
        final Offset offsetEnd = Offset(dx, dy);

        /// 残ったアイテムのアニメーション（アイテムに応じてアニメーションを変える）
        final Animation<Offset> offsetAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: offsetEnd, // アイテム1個分の縦横幅 -1.085

          //Offsetの左側はプラス値であれば右に移動する。マイナス値であれば左に移動する

        ).chain(CurveTween(curve: Curves.easeInOut)
        ).animate(animationControllerList.last);
        offsetAnimationList.add(offsetAnimation);
      }

      /// 各アイテムのアニメーションスタート
      animationControllerList[i].forward();
    }

    if (_scrollControllerForSingleChildView.hasClients) {
      _scrollControllerForSingleChildView.jumpTo(gridviewItemSize.height * scrollAmountSurplus + 1);
    }
  }


  void _finishAnimation() {
    for (int i = 0; i < animationControllerList.length; i++) {
      animationControllerList[i].dispose();
    }
    animationControllerList.clear();
    offsetAnimationList.clear();
    createAnimations(widget.gridviewItems.length);
  }

  @override
  void dispose() {
    for (int i = 0; i < animationControllerList.length; i++) {
      animationControllerList[i].dispose();
    }
    _scrollControllerForGridview.dispose();
    _scrollControllerForSingleChildView.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          key: gridviewKey,
          controller: _scrollControllerForGridview,
          padding: widget.padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
          ),
          itemCount: widget.gridviewItems.length,
          itemBuilder: (BuildContext context, int index) {
            return VisibilityDetector(
              onVisibilityChanged: (visibilityInfo) {
                if (count == 0) {
                  gridviewItemSize = visibilityInfo.size;
                }
                count++;
              },
              key: UniqueKey(),
              child: itemWidget(
                  selectingItemsList: widget.selectingItemsList,
                  gridviewItems: widget.gridviewItems,
                  index: index,
                  enableAnimation: widget.enableAnimation,
                  offsetAnimationList: offsetAnimationList,
                  setState: setState)
            );
          },
        ),
        if (widget.enableAnimation)
          SingleChildScrollView(
            controller: _scrollControllerForSingleChildView,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: widget.padding,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,
              ),
              itemCount: itemsRelateInAnimationList.length,
              itemBuilder: (BuildContext context, int index) {
                return itemWidget(
                    selectingItemsList: widget.selectingItemsList,
                    gridviewItems: widget.gridviewItems,
                    index: index,
                    enableAnimation: widget.enableAnimation,
                    offsetAnimationList: offsetAnimationList,
                    setState: setState);
              },
            ),
          )
      ],
    );
  }
}

Widget itemWidget({
  required List<Map<String, dynamic>> selectingItemsList,
  required List<Map<String, dynamic>> gridviewItems,
  required int index,
  required bool enableAnimation,
  required List<Animation<Offset>> offsetAnimationList,
  required Function setState
}) {
  //todo: どうにかしてFadeOutを聞かせるようにする
  return AnimatedOpacity(
    opacity: selectingItemsList.contains(gridviewItems[index]) && enableAnimation
        ? 0
        : 1,
    duration: enableAnimation? const Duration(milliseconds: 300) : const Duration(milliseconds: 0),
    child: SlideTransition(
      position: offsetAnimationList[index],
      child: GestureDetector(
        onTap: () {
          if (selectingItemsList.contains(gridviewItems[index])) {
            setState(() {
              selectingItemsList.remove(gridviewItems[index]);
            });
          } else {
            setState(() {
              selectingItemsList.add(gridviewItems[index]);
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: selectingItemsList.contains(gridviewItems[index])
                  ? Colors.indigo
                  : Colors.blue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                )
              ]
          ),
          child: Center(
            child: Text(
              gridviewItems[index]['id'],
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
          ),
        ),
      ),
    ),
  );
}






List<Map<String, dynamic>> identifyThePositionToMove({
  //todo: gridviewItemsのmap内のkeyには'id'が必須
  required List<Map<String, dynamic>> gridviewItems,
  required List<Map<String, dynamic>> selectingItemsList,
  required int crossAxisCount
}) {

  final List<Map<String, dynamic>> oldItemsList = [...gridviewItems];
  /// 削除前のアイテムを管理する

  final List<Map<String, dynamic>> newItemsList = [...gridviewItems];
  /// 削除後のアイテムを管理する

  for (int i = 0; i < selectingItemsList.length; i++) {
    if (newItemsList.contains(selectingItemsList[i])) {
      newItemsList.remove(selectingItemsList[i]);
    }
  }
  /// oldItemsListとnewItemsListの用意が完了



  final List<Map<String, dynamic>> oldItemsInfoList = [];
  /// oldItemsの位置を管理する（何段目の何列目にアイテムがあるのか）

  for (int i = 0; i < oldItemsList.length; i++) {
    int currentRow = (i / crossAxisCount).floor();
    int currentColumn = i % crossAxisCount;
    oldItemsInfoList.add(
        {'id': oldItemsList[i]['id'], 'rowPosition': currentRow, 'columnPosition': currentColumn}
    );
  }

  final List<Map<String, dynamic>> newItemsInfoList = [];
  /// newItemsの位置を管理する（何段目の何列目にアイテムがあるのか）

  for (int i = 0; i < newItemsList.length; i++) {
    int newRow = (i / crossAxisCount).floor();
    int newColumn = i % crossAxisCount;
    newItemsInfoList.add(
        {'id': newItemsList[i]['id'], 'rowPosition': newRow, 'columnPosition': newColumn}
    );

  }
  /// rowPositionは何段目かを管理している。(0から始まる)
  /// columnPositionは何列目かを管理していて、(0から始まり、crossAxisCount - 1 で終わる)
  /// 例: 3列のgridviewであれば一番左の列が0で一番右の列がcrossAxisCount - 1 の2で終わる
  /// oldItemsPositionListとnewItemsPositionListの用意が完了

  final List<Map<String, dynamic>> movingItemsInfoList = [];

  for (int i = 0; i < oldItemsInfoList.length; i++) {
    if (oldItemsInfoList[i]['id'] == newItemsInfoList[i]['id']) {
      int movingRowCount = newItemsInfoList[i]['rowPosition'] - oldItemsInfoList[i]['rowPosition'];
      int movingColumnCount = newItemsInfoList[i]['columnPosition'] - oldItemsInfoList[i]['columnPosition'];
      movingItemsInfoList.add(
        {'movingRowCount': movingRowCount, 'movingColumnCount': movingColumnCount}
      );
    } else {
      newItemsInfoList.insert(i, {});
      movingItemsInfoList.add(
        {}
      );
    }
  }

  return movingItemsInfoList;

}




/// アイテムを削除するための関数
void deleteFunction({
  required List<Map<String, dynamic>> gridviewItems,
  required List<Map<String, dynamic>> selectingItemsList,
  required int crossAxisCount,
  required Function reBuild,
  required Function startAnimation,
  required Function finishAnimation,
  required StreamController<bool> streamController
}) {

  startAnimation();
  streamController.sink.add(true);
  /// アニメーションスタート


  Timer(const Duration(milliseconds: 310), () {
    finishAnimation();
    for (int i = 0; i < selectingItemsList.length; i++) {
      gridviewItems.remove(selectingItemsList[i]);
    }
    selectingItemsList.clear();
    reBuild();

    streamController.sink.add(false);
    /// アニメーション終了
  });
}


/// deleteFunctionの呼び出しに必要な関数と変数
// List<Map<String, dynamic>> selectingItemsList = [];
//
// void reBuild() {
//   setState(() {});
// }
//
//
// bool enableAnimation = false;
//
// void startAnimation() {
//   setState(() {
//     enableAnimation = true;
//   });
// }
//
// void finishAnimation() {
//   setState(() {
//     enableAnimation = false;
//   });
// }
//
// final streamController = StreamController<bool>();
