import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to hold user data
  List<Map<String, dynamic>> users = [];

  // Fetch all users from Firestore
  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      users = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // Add a new user
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').add(userData);
      fetchUsers(); // Refresh the list after adding
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  // Update user data
  Future<void> updateUser(String docId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(docId).update(userData);
      fetchUsers(); // Refresh the list after updating
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // Delete user data
  Future<void> deleteUser(String docId) async {
    try {
      await _firestore.collection('users').doc(docId).delete();
      fetchUsers(); // Refresh the list after deleting
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
