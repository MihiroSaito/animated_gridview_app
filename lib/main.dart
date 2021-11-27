import 'package:animated_gridview_app/gridview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'animated_gridview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'animated_gridview'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  /// 全てのアイテム
  List<Map<String, dynamic>> gridviewItems = [
    {'id': '0'},
    {'id': '1'},
    {'id': '2'},
    {'id': '3'},
    {'id': '4'},
    {'id': '5'},
    {'id': '6'},
    {'id': '7'},
    {'id': '8'},
    {'id': '9'},
    {'id': '10'},
    {'id': '11'},
    {'id': '12'},
    {'id': '13'},
    {'id': '14'},
    {'id': '15'},
    {'id': '16'},
    {'id': '17'},
    {'id': '18'},
    {'id': '19'},
    {'id': '20'},
    {'id': '21'},
    {'id': '22'},
    {'id': '23'},
    {'id': '24'},
    {'id': '25'},
    {'id': '26'},
    {'id': '27'},
    {'id': '28'},
    {'id': '29'},
  ];

  /// 削除したいアイテムを管理するリスト
  List<Map<String, dynamic>> selectingItemsList = [];

  /// 削除後にアイテムが移動する数を管理するリスト
  List<int> transferenceNumberList = [];

  static const crossAxisCount = 3;


  void reBuild() {
    setState(() {});
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AnimatedGridView(
          gridviewItems: gridviewItems,
          selectingItemsList: selectingItemsList,
          crossAxisCount: crossAxisCount,),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          deleteFunction(
              gridviewItems: gridviewItems,
              selectingItemsList: selectingItemsList,
              crossAxisCount: crossAxisCount,
              reBuild: reBuild);
        },
        tooltip: 'delete',
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }
}
