import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_movie_screen.dart';
import 'movie.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteMovie(String movieId) async {
    try {
      await _firestore.collection('Movies').doc(movieId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: MovieSearchDelegate(_firestore),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Movies').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildErrorWidget();
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyWidget();
          }

          final movies = snapshot.data!.docs
              .map((doc) => Movie.fromSnapshot(doc))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) => _buildMovieCard(movies[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditMovieScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _showActionMenu(movie),
        child: Stack(
          children: [
            Image.network(
              movie.imageUrl,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.duration} นาที',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(Movie movie) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMovieScreen(movie: movie),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(movie.id);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String movieId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure to delete this movie?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteMovie(movieId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildEmptyWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_creation, size: 80),
            const SizedBox(height: 16),
            const Text('No Movies Found'),
          ],
        ),
      );

  Widget _buildErrorWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error, color: Colors.red, size: 50),
            SizedBox(height: 16),
            Text('Error Loading Data'),
          ],
        ),
      );
}

class MovieSearchDelegate extends SearchDelegate {
  final FirebaseFirestore _firestore;

  MovieSearchDelegate(this._firestore);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Movies').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        final results = snapshot.data!.docs
            .map((doc) => Movie.fromSnapshot(doc))
            .where((movie) =>
                movie.name.toLowerCase().contains(query.toLowerCase()) ||
                movie.category.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(results[index].name),
            subtitle: Text('${results[index].duration} mins'),
            onTap: () => close(context, results[index]),
          ),
        );
      },
    );
  }
}
