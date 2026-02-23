import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/artwork.dart';

class ArtworkService {
  static const String _fileName = 'artworks.json';

  // Get the local path for the device
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the file where data will be stored
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Load all artworks
  Future<List<Artwork>> loadArtworks() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      List<dynamic> jsonList = json.decode(contents);

      // Convert to Artwork objects
      return jsonList.map((json) => Artwork.fromJson(json)).toList();
    } catch (e) {
      // If file doesn't exist or is invalid, return empty list
      return [];
    }
  }

  // Save artworks
  Future<void> saveArtworks(List<Artwork> artworks) async {
    final file = await _localFile;

    // Convert to JSON
    List<Map<String, dynamic>> jsonList = artworks
        .map((artwork) => artwork.toJson())
        .toList();

    // Write to file
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Add a new artwork
  Future<void> addArtwork(Artwork artwork) async {
    List<Artwork> artworks = await loadArtworks();

    // Check if artwork with same ID already exists, if so, replace it
    int existingIndex = artworks.indexWhere(
      (element) => element.id == artwork.id,
    );
    if (existingIndex != -1) {
      artworks[existingIndex] = artwork;
    } else {
      artworks.add(artwork);
    }

    await saveArtworks(artworks);
  }

  // Delete an artwork
  Future<void> deleteArtwork(int id) async {
    List<Artwork> artworks = await loadArtworks();
    artworks.removeWhere((element) => element.id == id);
    await saveArtworks(artworks);
  }

  // Get the next available ID
  Future<int> getNextId() async {
    List<Artwork> artworks = await loadArtworks();
    if (artworks.isEmpty) {
      return 1;
    }
    int maxId = artworks
        .map((artwork) => artwork.id)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}
