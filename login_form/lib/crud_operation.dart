import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserScreen(),
    );
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addUserData() async {
    Map<String, dynamic> userData = {
      'company_name': _companyNameController.text,
      'email': _emailController.text,
      'position': _positionController.text,
      'username': _usernameController.text,
    };

    try {
      await firestore.collection('users').add(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User added successfully!")),
      );
      clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add user: $e")),
      );
    }
  }

  Future<void> updateUserData(String docId) async {
    Map<String, dynamic> updatedData = {
      'company_name': _companyNameController.text,
      'email': _emailController.text,
      'position': _positionController.text,
      'username': _usernameController.text,
    };

    try {
      await firestore.collection('users').doc(docId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User updated successfully!")),
      );
      clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update user: $e")),
      );
    }
  }

  Future<void> deleteUserData(String docId) async {
    try {
      await firestore.collection('users').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete user: $e")),
      );
    }
  }

  void clearFields() {
    _companyNameController.clear();
    _emailController.clear();
    _positionController.clear();
    _usernameController.clear();
  }

  void setFields(Map<String, dynamic> userData) {
    _companyNameController.text = userData['company_name'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _positionController.text = userData['position'] ?? '';
    _usernameController.text = userData['username'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Firebase Firestore CRUD"),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: "Company Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _positionController,
              decoration: InputDecoration(labelText: "Position"),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addUserData,
              child: Text("Add User"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      var userData = user.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(userData['company_name'] ?? 'No Company'),
                        subtitle: Text(userData['email'] ?? 'No Email'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setFields(userData);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Update User"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _companyNameController,
                                          decoration: InputDecoration(
                                              labelText: "Company Name"),
                                        ),
                                        TextField(
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                              labelText: "Email"),
                                        ),
                                        TextField(
                                          controller: _positionController,
                                          decoration: InputDecoration(
                                              labelText: "Position"),
                                        ),
                                        TextField(
                                          controller: _usernameController,
                                          decoration: InputDecoration(
                                              labelText: "Username"),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          updateUserData(user.id);
                                        },
                                        child: Text("Update"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteUserData(user.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
