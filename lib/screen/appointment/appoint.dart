class Doctors {
  final String name;
  final String picture;
  final String hospital;

  Doctors({
    required this.name,
    required this.picture,
    required this.hospital,
  });

  factory Doctors.fromJson(Map<String, dynamic> json) => Doctors(
    name: json['name'],
    picture: json['picture'],
    hospital: json['hospital'],
  );
}
