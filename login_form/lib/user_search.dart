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
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Controller for email search
  final TextEditingController _searchEmailController = TextEditingController();
  Map<String, dynamic>? _searchResult;

  // Function to add user data to Firestore
  Future<void> addUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
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

  // Function to search user data by email
  Future<void> searchUserByEmail() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: _searchEmailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _searchResult =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
        });
      } else {
        setState(() {
          _searchResult = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No user found with that email.")),
        );
      }
    } catch (e) {
      print("Error searching user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching user: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("User Form and Search"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form Fields
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
              Divider(),
              // Search by Email Section
              TextField(
                controller: _searchEmailController,
                decoration: InputDecoration(
                  labelText: "Search by Email",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: searchUserByEmail,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _searchResult != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Company Name: ${_searchResult!['company_name']}"),
                        Text("Email: ${_searchResult!['email']}"),
                        Text("Position: ${_searchResult!['position']}"),
                        Text("Username: ${_searchResult!['username']}"),
                      ],
                    )
                  : Text("No user data to display"),
            ],
          ),
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
    _searchEmailController.dispose();
    super.dispose();
  }
}
