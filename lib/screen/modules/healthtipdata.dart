class MyData {
  final String question;
  final String picture;


  MyData({
    required this.question,
    required this.picture,

  });

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
      question: json['question'] ,
      picture: json['picture'],

    );
  }
}
