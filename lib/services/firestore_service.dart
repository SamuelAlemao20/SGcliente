
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic CRUD Operations
  Future<DocumentReference> create(String collection, Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Erro ao criar documento: $e');
    }
  }

  Future<void> createWithId(String collection, String id, Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(collection).doc(id).set(data);
    } catch (e) {
      throw Exception('Erro ao criar documento: $e');
    }
  }

  Future<DocumentSnapshot> read(String collection, String id) async {
    try {
      return await _firestore.collection(collection).doc(id).get();
    } catch (e) {
      throw Exception('Erro ao ler documento: $e');
    }
  }

  Future<QuerySnapshot> readCollection(String collection, {
    Query Function(CollectionReference)? queryBuilder,
  }) async {
    try {
      CollectionReference collectionRef = _firestore.collection(collection);
      Query query = queryBuilder?.call(collectionRef) ?? collectionRef;
      return await query.get();
    } catch (e) {
      throw Exception('Erro ao ler coleção: $e');
    }
  }

  Stream<DocumentSnapshot> watchDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  Stream<QuerySnapshot> watchCollection(String collection, {
    Query Function(CollectionReference)? queryBuilder,
  }) {
    CollectionReference collectionRef = _firestore.collection(collection);
    Query query = queryBuilder?.call(collectionRef) ?? collectionRef;
    return query.snapshots();
  }

  Future<void> update(String collection, String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar documento: $e');
    }
  }

  Future<void> delete(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar documento: $e');
    }
  }

  // Batch Operations
  WriteBatch batch() => _firestore.batch();

  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao executar batch: $e');
    }
  }

  // Transaction
  Future<T> runTransaction<T>(Future<T> Function(Transaction) transactionHandler) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      throw Exception('Erro na transação: $e');
    }
  }

  // Specific Collections Helper Methods
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get restaurants => _firestore.collection('restaurants');
  CollectionReference get orders => _firestore.collection('orders');
  CollectionReference get categories => _firestore.collection('categories');
  CollectionReference get products => _firestore.collection('products');
  CollectionReference get coupons => _firestore.collection('coupons');

  // Pagination Helper
  Future<QuerySnapshot> getPaginated(
    String collection, {
    int limit = 20,
    DocumentSnapshot? startAfter,
    Query Function(CollectionReference)? queryBuilder,
  }) async {
    try {
      CollectionReference collectionRef = _firestore.collection(collection);
      Query query = queryBuilder?.call(collectionRef) ?? collectionRef;
      
      query = query.limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      return await query.get();
    } catch (e) {
      throw Exception('Erro na paginação: $e');
    }
  }
}
