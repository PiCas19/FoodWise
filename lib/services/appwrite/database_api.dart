import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_api.dart';

class DatabaseAPI extends AppwriteAPI{
  late final Account account;
  late final Databases databases;

  DatabaseAPI() : super() {
    account = Account(client);
    databases = Databases(client);
  }

  Future<Document> createDocument({
    required String databaseId,
    required String collectionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: data,
      );
      if (response.data.isNotEmpty) {
        final documentId = response.data['\$id'];
        final documentResponse = await databases.getDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentId,
        );
        return documentResponse;
      } else {
        throw Exception('Failed to create document');
      }
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<DocumentList> listDocuments({
    required String databaseId,
    required String collectionId,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to list documents: $e');
    }
  }

  Future<void> updateDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> removeDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception('Failed to remove document: $e');
    }
  }

  Future<Document> getDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      final response = await databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

}