import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String name;
  final String category;
  final int duration;
  final String imageUrl;

  Movie({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.imageUrl,
  });

  factory Movie.fromSnapshot(DocumentSnapshot snapshot) {
    return Movie(
      id: snapshot.id,
      name: snapshot['name'],
      category: snapshot['category'],
      duration: snapshot['duration'],
      imageUrl: snapshot['imageUrl'],
    );
  }
}
