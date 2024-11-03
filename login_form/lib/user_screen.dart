import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class UserScreen extends StatelessWidget {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Firestore CRUD with Provider"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => userProvider.fetchUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // User Form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                    controller: companyController,
                    decoration: InputDecoration(labelText: "Company Name")),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email")),
                TextField(
                    controller: positionController,
                    decoration: InputDecoration(labelText: "Position")),
                TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: "Username")),
                ElevatedButton(
                  onPressed: () {
                    userProvider.addUser({
                      'company_name': companyController.text,
                      'email': emailController.text,
                      'position': positionController.text,
                      'username': usernameController.text,
                    });
                  },
                  child: Text("Add User"),
                ),
              ],
            ),
          ),
          Divider(),

          // User List
          Expanded(
            child: FutureBuilder(
              future: userProvider.fetchUsers(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: userProvider.users.length,
                  itemBuilder: (context, index) {
                    final user = userProvider.users[index];
                    return ListTile(
                      title: Text(user['company_name']),
                      subtitle: Text(user['email']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              companyController.text = user['company_name'];
                              emailController.text = user['email'];
                              positionController.text = user['position'];
                              usernameController.text = user['username'];
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Edit User"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                          controller: companyController,
                                          decoration: InputDecoration(
                                              labelText: "Company Name")),
                                      TextField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                              labelText: "Email")),
                                      TextField(
                                          controller: positionController,
                                          decoration: InputDecoration(
                                              labelText: "Position")),
                                      TextField(
                                          controller: usernameController,
                                          decoration: InputDecoration(
                                              labelText: "Username")),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        userProvider.updateUser(user['docId'], {
                                          'company_name':
                                              companyController.text,
                                          'email': emailController.text,
                                          'position': positionController.text,
                                          'username': usernameController.text,
                                        });
                                        Navigator.pop(context);
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
                            onPressed: () =>
                                userProvider.deleteUser(user['docId']),
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
    );
  }
}
