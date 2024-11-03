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
      title: 'Firestore Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserForm(),
    );
  }
}

class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  // Controllers for text fields
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Function to add user data to Firestore
  Future<void> addUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Data to store in Firestore
    Map<String, dynamic> userData = {
      'company_name': _companyNameController.text,
      'email': _emailController.text,
      'position': _positionController.text,
      'username': _usernameController.text,
    };

    try {
      await firestore.collection('users').add(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User data added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding user data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User Data"),
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
              child: Text("Save User Data"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _companyNameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
