import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'movie.dart';

class EditMovieScreen extends StatefulWidget {
  final Movie? movie;
  const EditMovieScreen({this.movie, super.key});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _nameController.text = widget.movie!.name;
      _categoryController.text = widget.movie!.category;
      _durationController.text = widget.movie!.duration.toString();
      _imageUrlController.text = widget.movie!.imageUrl;
    }
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      try {
        final movieData = {
          'name': _nameController.text,
          'category': _categoryController.text,
          'duration': int.parse(_durationController.text),
          'imageUrl': _imageUrlController.text,
        };

        if (widget.movie == null) {
          await _firestore.collection('Movies').add(movieData);
        } else {
          await _firestore
              .collection('Movies')
              .doc(widget.movie!.id)
              .update(movieData);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Add Movie' : 'Edit Movie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Movie Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (mins)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (!value.startsWith('http')) return 'Invalid URL';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMovie,
                child: const Text('Save Movie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
