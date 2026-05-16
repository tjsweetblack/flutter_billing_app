import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> submitLoanRequest(Map<String, dynamic> loanData) async {
    try {
      await _firestore.collection('loan_requests').add(loanData);
      return true;
    } catch (e) {
      debugPrint('Error submitting loan request: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLoanRequests() async {
    try {
      final snapshot = await _firestore
          .collection('loan_requests')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      debugPrint('Error fetching loan requests: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLoanRequestsByBank(String bank) async {
    try {
      final snapshot = await _firestore
          .collection('loan_requests')
          .where('bank', isEqualTo: bank)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      debugPrint('Error fetching loan requests by bank: $e');
      return [];
    }
  }

  Future<bool> updateLoanStatus(String docId, String status) async {
    try {
      await _firestore.collection('loan_requests').doc(docId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating loan status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getLoanRequestById(String docId) async {
    try {
      final doc = await _firestore.collection('loan_requests').doc(docId).get();
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching loan request: $e');
      return null;
    }
  }

  Stream<Map<String, dynamic>?> watchLoanRequest(String docId) {
    return _firestore.collection('loan_requests').doc(docId).snapshots().map((doc) {
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    });
  }

  Future<List<Map<String, dynamic>>> getPendingLoansByBank(String bank) async {
    try {
      final snapshot = await _firestore
          .collection('loan_requests')
          .where('bank', isEqualTo: bank)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      debugPrint('Error fetching pending loans: $e');
      return [];
    }
  }
}