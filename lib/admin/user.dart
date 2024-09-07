import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController controllerselectbyId = TextEditingController();

  int? selectedId;
  String? selectedRole;
  bool isEditing = false;
  int? editingId;

  late Future<List<dynamic>> futureUserList;
  final Uri url = Uri.parse('http://192.168.48.179/app_qa/connect/user.php');

  @override
  void initState() {
    super.initState();
    futureUserList = selectAll();
  }

  Future<void> insert(
      String username, String password, String name, String role) async {
    try {
      final response = await http.post(url, body: {
        "user": "INSERT",
        "username": username,
        "password": password,
        "name": name,
        "role": role,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data inserted successfully')));
        setState(() {
          futureUserList = selectAll();
        });
        _clearFields();
      } else {
        print('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> update(int id, String username, String password, String name,
      String role) async {
    try {
      final response = await http.post(url, body: {
        "user": "UPDATE",
        "id": id.toString(),
        "username": username,
        "password": password,
        "name": name,
        "role": role,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Data updated successfully')));
        setState(() {
          futureUserList = selectAll();
        });
        _clearFields();
      } else {
        print('Failed to update data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await http.post(url, body: {
        "user": "DELETE",
        "id": id.toString(),
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Data deleted successfully')));
        setState(() {
          futureUserList = selectAll();
        });
      } else {
        print('Failed to delete data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<dynamic>> selectById(int id) async {
    try {
      final response = await http.post(url, body: {
        "user": "SELECT",
        "id": id.toString(),
      });

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody == "No records found") {
          return [];
        }
        final data = jsonDecode(responseBody);
        return data;
      } else {
        print('Failed to select data by ID');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> selectAll({String search = ''}) async {
    try {
      final response = await http.post(url, body: {
        "user": "SELECT_ALL",
        "search": search,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to select all data');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _nameController.clear();
    _idController.clear();
    controllerselectbyId.clear();
    selectedRole = null;
    isEditing = false;
  }

  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _usernameController.text = user['username'];
      _passwordController.text = user['password'];
      _nameController.text = user['name'];
      _idController.text = user['id'];
      selectedRole = user['role'];
      editingId = int.parse(user['id']);
      isEditing = true;
    });
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                delete(id);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> searchUserById() async {
    if (controllerselectbyId.text.isNotEmpty) {
      int id = int.parse(controllerselectbyId.text);
      List<dynamic> result = await selectById(id);
      if (result.isNotEmpty) {
        // Show user details in a dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 300,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blue[100], // กำหนดสีพื้นหลังเป็นสีฟ้าอ่อน
                  borderRadius: BorderRadius.circular(10), // ปรับขอบให้โค้งมน
                ),
                child: AlertDialog(
                  title: Text(
                    'User Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'ID: ${result[0]['id']}\n'
                    'Username: ${result[0]['username']}\n'
                    'Name: ${result[0]['name']}\n'
                    'Role: ${result[0]['role']}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[400]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // ปิด Dialog
                        _editUser(result[0]); // เรียกฟังก์ชันแก้ไขข้อมูล
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700]),
                      ),
                    ),
                  ],
                  backgroundColor: Colors
                      .transparent, // ปรับให้พื้นหลังของ AlertDialog เองเป็นโปร่งใส
                ),
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with ID $id')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an ID')),
      );
    }
  }

// ฟังก์ชันแก้ไขข้อมูล

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Page',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple.shade400,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _idController,
                        decoration: InputDecoration(
                          labelText: 'ID',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        enabled: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: <String>['admin', 'user'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a role';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (isEditing) {
                            update(
                              editingId!,
                              _usernameController.text,
                              _passwordController.text,
                              _nameController.text,
                              selectedRole!,
                            );
                          } else {
                            insert(
                              _usernameController.text,
                              _passwordController.text,
                              _nameController.text,
                              selectedRole!,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        minimumSize: Size(double.infinity, 20),
                        shadowColor: Colors.grey,
                        elevation: 10,
                      ),
                      child: Text(
                        isEditing ? 'Save Changes' : 'Add User',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'User List',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controllerselectbyId,
                  decoration: InputDecoration(
                    labelText: 'Search by ID',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an ID';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 8),
              Container(
                child: Center(
                  child: ElevatedButton(
                    onPressed: searchUserById,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade700,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      minimumSize: Size(double.infinity, 20),
                      shadowColor: Colors.grey,
                      elevation: 10,
                    ),
                    child: Text(
                      'Search User',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<List<dynamic>>(
                future: futureUserList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    final data = snapshot.data!;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          color: Colors.grey[200],
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .purple[400], // พื้นหลังสีม่วงสำหรับ ID
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${data[index]['id']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // ข้อความสีขาว
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        8), // เว้นระยะห่างระหว่าง ID กับข้อมูลอื่นๆ
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              'Username: ${data[index]['username']}\n'
                              'Name: ${data[index]['name']} \n Role: ${data[index]['role']}',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _editUser(data[index]);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(
                                        int.parse(data[index]['id']));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
