import 'package:flutter/material.dart';

class AnimatedGridView extends StatefulWidget {
  const AnimatedGridView({
    Key? key,
    required this.gridviewItems,
    required this.selectingItemsList}) : super(key: key);
  final List<dynamic> gridviewItems;
  final List<Map<String, dynamic>> selectingItemsList;

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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
  required List gridviewItems,
  required List selectingItemsList,
  required Function reBuild
}) {
  for (int i = 0; i < selectingItemsList.length; i++) {
    gridviewItems.remove(selectingItemsList[i]);
  }
  selectingItemsList.clear();
  reBuild();
}
