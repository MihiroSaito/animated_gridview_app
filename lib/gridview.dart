import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedGridView extends StatefulWidget {

  const AnimatedGridView({
    Key? key,
    required this.gridviewItems,
    required this.selectingItemsList,
    required this.crossAxisCount,
    required this.enableAnimation,
    required this.streamController}) : super(key: key);

  final List<dynamic> gridviewItems;
  final List<Map<String, dynamic>> selectingItemsList;
  final int crossAxisCount;
  final bool enableAnimation;
  final StreamController<bool> streamController;

  @override
  _AnimatedGridViewState createState() => _AnimatedGridViewState();
}

class _AnimatedGridViewState extends State<AnimatedGridView> with TickerProviderStateMixin {

  List<AnimationController> animationControllerList = [];
  List<Animation<Offset>> offsetAnimationList = [];

  @override
  void initState() {
    createAnimations(widget.gridviewItems.length);
    widget.streamController.stream.listen((data){
      if (data == true) {
        _startAnimation(
          gridviewItems: widget.gridviewItems as List<Map<String, dynamic>>,
          selectingItemsList: widget.selectingItemsList,
          crossAxisCount: widget.crossAxisCount,
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
    required int crossAxisCount
  }) {

    /// アイテムを削除する前と削除した後の位置を管理するリストを取得する。
    final Map<String, dynamic> oldItemsInfoListAndNewItemsInfoList = identifyThePositionToMove(
        gridviewItems: gridviewItems,
        selectingItemsList: selectingItemsList,
        crossAxisCount: crossAxisCount);

    /// 空データを消す。
    offsetAnimationList.clear();


    for (int i = 0; i < animationControllerList.length; i++) {


      /// oldItemsListとnewItemsListを比較して同じIDのものを探して、rowPositionを比較＆columnPositionを比較する。
      final Offset offsetEnd = Offset(1.085, 0.0);

      if (widget.selectingItemsList.contains(widget.gridviewItems[i])) {

        /// 削除するアイテムのアニメーション（slideAnimationはなし）
        final Animation<Offset> offsetAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 0.0),
        ).animate(animationControllerList.last);
        offsetAnimationList.add(offsetAnimation);

      } else {

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
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(
          top: 15,
          left: 10,
          right: 10,
          bottom: 15
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (BuildContext context, int index) {
        return AnimatedOpacity(
          opacity: widget.selectingItemsList.contains(widget.gridviewItems[index]) && widget.enableAnimation
              ? 0
              : 1,
          duration: widget.enableAnimation? const Duration(milliseconds: 300) : const Duration(milliseconds: 0),
          child: SlideTransition(
            position: offsetAnimationList[index],
            child: GestureDetector(
              onTap: () {
                if (widget.selectingItemsList.contains(widget.gridviewItems[index])) {
                  setState(() {
                    widget.selectingItemsList.remove(widget.gridviewItems[index]);
                  });
                } else {
                  setState(() {
                    widget.selectingItemsList.add(widget.gridviewItems[index]);
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: widget.selectingItemsList.contains(widget.gridviewItems[index])
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
                    widget.gridviewItems[index]['id'],
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
      },
      itemCount: widget.gridviewItems.length,
    );
  }
}






Map<String, dynamic> identifyThePositionToMove({
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
        {'data': oldItemsList[i], 'rowPosition': currentRow, 'columnPosition': currentColumn}
    );
  }

  final List<Map<String, dynamic>> newItemsInfoList = [];
  /// newItemsの位置を管理する（何段目の何列目にアイテムがあるのか）

  for (int i = 0; i < newItemsList.length; i++) {
    int newRow = (i / crossAxisCount).floor();
    int newColumn = i % crossAxisCount;
    newItemsInfoList.add(
        {'data': newItemsList[i], 'rowPosition': newRow, 'columnPosition': newColumn}
    );
  }
  /// rowPositionは何段目かを管理している。(0から始まる)
  /// columnPositionは何列目かを管理していて、(0から始まり、crossAxisCount - 1 で終わる)
  /// 例: 3列のgridviewであれば一番左の列が0で一番右の列がcrossAxisCount - 1 の2で終わる
  /// oldItemsPositionListとnewItemsPositionListの用意が完了



  final Map<String, dynamic> oldItemsInfoListAndNewItemsInfoList = {
    'oldItemsInfoList': oldItemsInfoList,
    'newItemsInfoList': newItemsInfoList
  };

  return oldItemsInfoListAndNewItemsInfoList;

}
