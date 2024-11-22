import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
class Practitioners extends StatefulWidget {
  const Practitioners({super.key});

  @override
  State<Practitioners> createState() => _PractitionersState();
}

class _PractitionersState extends State<Practitioners> {
  List<Practitioner> dataList = [];
  Future<void> getData() async {
    String jsonString = await rootBundle.loadString('assets/json/practitioner.json');
    List<dynamic> jsonList = json.decode(jsonString);
    dataList = jsonList.map((json) => Practitioner.fromJson(json)).toList();

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
          icon: Icon(Icons.arrow_back,
            color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromRGBO(170, 77, 254, 1),
        title: Text("Our General Practitioners",style: TextStyle(
            fontSize: 20,fontWeight: FontWeight.w300,
            color: Colors.white,
            fontFamily: "Itim"
        ),),
      ),
      body: Container(
        child: dataList.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.23,
                          child: Card(
                            elevation: 15,
                            shadowColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                Container(
                                  height:
                                  MediaQuery.of(context).size.height *
                                      0.16,
                                  width: MediaQuery.of(context).size.width *
                                      0.3,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(170,77, 254,1),
                                      image: DecorationImage(
                                        image: AssetImage(dataList[index].picture),
                                        fit: BoxFit.fill
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(15)),
                                  margin: EdgeInsets.all(20),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 10),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width*0.4,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "${dataList[index].name}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "Itim",
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "${dataList[index].hospital}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontFamily: "Itim",
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: Text("See now",
                                            style: TextStyle(
                                                color: Colors.white
                                            ),),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromRGBO(
                                                  170, 77, 254, 1),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      10))),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                            ),
                                            Text(
                                              " 4.9   (90 reviews)",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontFamily: "Itim",
                                                fontSize: 15,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class Practitioner {
  final String name;
  final String picture;
  final String hospital;

  Practitioner({
    required this.name,
    required this.picture,
    required this.hospital,
  });

  factory Practitioner.fromJson(Map<String, dynamic> json) => Practitioner(
    name: json['name'],
    picture: json['picture'],
    hospital: json['hospital'],
  );
}
