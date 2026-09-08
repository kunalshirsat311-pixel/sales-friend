import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── GENERATE 6 DIGIT CODE ──────────────────────────────────
  Future<String> generateShareCode() async {
    String userId = _auth.currentUser!.uid;

    // Generate random 6-digit code
    String code = (100000 + Random().nextInt(900000)).toString();

    // Save code to Firestore with salesman's userId
    await _firestore.collection('share_codes').doc(code).set({
      'salesmanId': userId,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
    });

    return code;
  }

  // ─── GET EXISTING CODE ───────────────────────────────────────
  Future<String?> getExistingCode() async {
    String userId = _auth.currentUser!.uid;

    QuerySnapshot query = await _firestore
        .collection('share_codes')
        .where('salesmanId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  // ─── LINK MANAGER TO SALESMAN VIA CODE ──────────────────────
  Future<String?> linkWithCode(String code) async {
    try {
      String managerId = _auth.currentUser!.uid;

      // Check if code exists
      DocumentSnapshot codeDoc = await _firestore
          .collection('share_codes')
          .doc(code)
          .get();

      if (!codeDoc.exists) {
        return 'Invalid code. Please check and try again.';
      }

      Map<String, dynamic> codeData = codeDoc.data() as Map<String, dynamic>;

      if (codeData['isActive'] != true) {
        return 'This code has expired.';
      }

      String salesmanId = codeData['salesmanId'];

      if (salesmanId == managerId) {
        return 'You cannot link to your own account.';
      }

      // Safe update with merge: true creates the document if it does not exist
      await _firestore.collection('users').doc(managerId).set({
        'linkedSalesmen': FieldValue.arrayUnion([salesmanId]),
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(salesmanId).set({
        'linkedManagers': FieldValue.arrayUnion([managerId]),
      }, SetOptions(merge: true));

      return null; // null indicates success
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ─── GET LINKED SALESMEN FOR MANAGER ────────────────────────
  Future<List<String>> getLinkedSalesmen() async {
    String managerId = _auth.currentUser!.uid;

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(managerId)
        .get();

    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['linkedSalesmen'] ?? []);
    }
    return [];
  }

  // ─── REVOKE ACCESS ───────────────────────────────────────────
  Future<void> revokeAccess(String salesmanId) async {
    String managerId = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(managerId).set({
      'linkedSalesmen': FieldValue.arrayRemove([salesmanId]),
    }, SetOptions(merge: true));

    await _firestore.collection('users').doc(salesmanId).set({
      'linkedManagers': FieldValue.arrayRemove([managerId]),
    }, SetOptions(merge: true));
  }

  // ─── DEACTIVATE CODE ─────────────────────────────────────────
  Future<void> deactivateCode(String code) async {
    await _firestore.collection('share_codes').doc(code).update({
      'isActive': false,
    });
  }
}
