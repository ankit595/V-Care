import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'healthtipdata.dart';

class Healthtip extends StatefulWidget {
  const Healthtip({super.key});

  @override
  State<Healthtip> createState() => _HealthtipState();
}

class _HealthtipState extends State<Healthtip> {
  List<MyData> dataList = [];

  Future<void> getData() async {
    String jsonString =
        await rootBundle.loadString('assets/json/Health tips.json');
    List<dynamic> jsonList = json.decode(jsonString);
    dataList = jsonList.map((json) => MyData.fromJson(json)).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 10,
        title: Text(
          "First -Aid Tips",
          style:
              TextStyle(color: Colors.white, fontFamily: "Itim", fontSize: 20),
        ),
        backgroundColor: Colors.purple[700],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/h.jpeg"),
          fit: BoxFit.cover,
        )),
        child: dataList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FirstAid_Ans(index: index)));
                      },
                      child: Hero(
                        tag: "hero-tag",
                        child: Card(
                          elevation: 8,
                          margin: EdgeInsets.all(10),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Image.network(
                                  dataList[index].picture,
                                ),
                                Text(
                                  "${dataList[index].question}",
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: "Itim"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}

class FirstAid_Ans extends StatefulWidget {
  final int index;

  const FirstAid_Ans({Key? key, required this.index}) : super(key: key);

  @override
  State<FirstAid_Ans> createState() => _FirstAid_AnsState();
}

class _FirstAid_AnsState extends State<FirstAid_Ans> {
  List<Map<String, dynamic>> jsonDataList = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    String jsonString =
        await rootBundle.loadString('assets/json/Healthtips_ans.json');
    List<dynamic> decodedData = json.decode(jsonString);
    setState(() {
      jsonDataList = decodedData.cast<Map<String, dynamic>>();
    });
    }

  bool _isButtonClicked = false;
  void _returnBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (jsonDataList.isEmpty ||
        widget.index < 0 ||
        widget.index >= jsonDataList.length) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Map<String, dynamic> jsonData = jsonDataList[widget.index];

    return Scaffold(
      body: Hero(
        tag: "hero-tag",
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  alignment: Alignment.center,
                  color: Colors.deepPurpleAccent,
                  child: Image.network(jsonData["picture"]),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(13.0),
                    topLeft: Radius.circular(13.0),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.73,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        jsonData['question'],
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Itim",
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height *
                            .5, // Adjust height as needed
                        child: SingleChildScrollView(
                          child: Text(
                            jsonData['answer'],
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Itim",
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isButtonClicked ? Colors.green : Colors.red,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.black38,
                title: Text(
                  'Returning back to Health tips',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Itim",
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _returnBack();
                    },
                  ),
                ],
              );
            },
          );
          setState(() {
            _isButtonClicked = !_isButtonClicked;
          });
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
            _returnBack();
          });
        },
        child: Icon(
          Icons.thumb_up_alt_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}
