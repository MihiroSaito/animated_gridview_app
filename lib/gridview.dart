import 'package:flutter/material.dart';

class AnimatedGridView extends StatefulWidget {

  const AnimatedGridView({
    Key? key,
    required this.gridviewItems,
    required this.selectingItemsList,
    required this.crossAxisCount,
    required this.enableAnimation,
    required this.animation}) : super(key: key);

  final List<dynamic> gridviewItems;
  final List<Map<String, dynamic>> selectingItemsList;
  final int crossAxisCount;
  final bool enableAnimation;
  final Animation<Offset> animation;

  @override
  _AnimatedGridViewState createState() => _AnimatedGridViewState();
}

class _AnimatedGridViewState extends State<AnimatedGridView> with SingleTickerProviderStateMixin {



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
          duration: const Duration(milliseconds: 200),
          child: SlideTransition(
            position: widget.animation,
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





void deleteFunction({
  required List<Map<String, dynamic>> gridviewItems,
  required List<Map<String, dynamic>> selectingItemsList,
  required int crossAxisCount,
  required Function reBuild,
  required Function startAnimation
}) {

  final Map<String, dynamic> oldItemsInfoListAndNewItemsInfoList = identifyThePositionToMove(
      gridviewItems: gridviewItems,
      selectingItemsList: selectingItemsList,
      crossAxisCount: crossAxisCount);
  /// アイテムを削除する前と削除した後の位置を管理するリストを取得する。



  //todo: アイテムの削除アニメーションを追加する
  startAnimation();


  // for (int i = 0; i < selectingItemsList.length; i++) {
  //   gridviewItems.remove(selectingItemsList[i]);
  // }
  // selectingItemsList.clear();
  // reBuild();
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
