import 'package:flutter/material.dart';

class AnimatedGridView extends StatefulWidget {

  const AnimatedGridView({
    Key? key,
    required this.gridviewItems,
    required this.selectingItemsList,
    required this.crossAxisCount}) : super(key: key);

  final List<dynamic> gridviewItems;
  final List<Map<String, dynamic>> selectingItemsList;
  final int crossAxisCount;

  @override
  _AnimatedGridViewState createState() => _AnimatedGridViewState();
}

class _AnimatedGridViewState extends State<AnimatedGridView> {

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
        return GestureDetector(
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
  required Function reBuild
}) {

  final Map<String, dynamic> oldItemsInfoListAndNewItemsInfoList = identifyThePositionToMove(
      gridviewItems: gridviewItems,
      selectingItemsList: selectingItemsList,
      crossAxisCount: crossAxisCount);
  /// アイテムを削除する前と削除した後の位置を管理するリストを取得する。


  //todo: アイテムの削除アニメーションを追加する


  for (int i = 0; i < selectingItemsList.length; i++) {
    gridviewItems.remove(selectingItemsList[i]);
  }
  selectingItemsList.clear();
  reBuild();
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
  /// oldItemsPositionListとnewItemsPositionListの用意が完了



  final Map<String, dynamic> oldItemsInfoListAndNewItemsInfoList = {
    'oldItemsInfoList': oldItemsInfoList,
    'newItemsInfoList': newItemsInfoList
  };

  return oldItemsInfoListAndNewItemsInfoList;

}
