import 'dart:async';

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




const int crossAxisCount = 3;

const double mainAxisSpace = 10.0;



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {


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
    {'id': '30'},
    {'id': '31'},
    {'id': '32'},
    {'id': '33'},
    {'id': '34'},
    {'id': '35'},
    {'id': '36'},
    {'id': '37'},
    {'id': '38'},
    {'id': '39'},
    {'id': '40'},
    {'id': '41'},
    {'id': '42'},
    {'id': '43'},
    {'id': '44'},
    {'id': '45'},
    {'id': '46'},
    {'id': '47'},
    {'id': '48'},
    {'id': '49'},
    {'id': '50'},
    {'id': '51'},
    {'id': '52'},
    {'id': '53'},
    {'id': '54'},
    {'id': '55'},
    {'id': '56'},
    {'id': '57'},
    {'id': '58'},
    {'id': '59'},
    {'id': '60'},
    {'id': '61'},
    {'id': '62'},
    {'id': '63'},
    {'id': '64'},
    {'id': '65'},


  ];

  /// 削除したいアイテムを管理するリスト
  List<Map<String, dynamic>> selectingItemsList = [];

  void reBuild() {
    setState(() {});
  }


  bool enableAnimation = false;

  void startAnimation() {
    setState(() {
      enableAnimation = true;
    });
  }

  void finishAnimation() {
    setState(() {
      enableAnimation = false;
    });
  }

  final streamController = StreamController<bool>();









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AnimatedGridView(
          gridviewItems: gridviewItems,
          selectingItemsList: selectingItemsList,
          crossAxisCount: crossAxisCount,
          enableAnimation: enableAnimation,
          streamController: streamController,
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 15),
          crossAxisSpacing: 10.0,
          mainAxisSpacing: mainAxisSpace),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          deleteFunction(
              gridviewItems: gridviewItems,
              selectingItemsList: selectingItemsList,
              crossAxisCount: crossAxisCount,
              startAnimation: startAnimation,
              finishAnimation: finishAnimation,
              reBuild: reBuild,
              streamController: streamController);
        },
        tooltip: 'delete',
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }
}




