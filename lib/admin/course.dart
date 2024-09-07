import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoursePage extends StatefulWidget {
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _coursecodeController = TextEditingController();
  final TextEditingController _coursenameController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  // final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searhcoursebycode = TextEditingController();

  final TextEditingController _groups = TextEditingController();
  final TextEditingController _receives = TextEditingController();

  bool isEditing = false;
  int? editingId;

  late Future<List<dynamic>> futureCourseList;
  final Uri url =
      Uri.parse('http://192.168.48.179/app_qa/connect/addcourse.php');

  @override
  void initState() {
    super.initState();
    futureCourseList = selectAll();
  }

  Future<void> insertCourse(String coursecode, String coursename,
      String credits, String instructor, String groups, String receives) async {
    try {
      final response = await http.post(url, body: {
        "action": "INSERT_COURSE",
        "coursecode": coursecode,
        "coursename": coursename,
        "credits": credits,
        "instructor": instructor,
        "groups": groups,
        "receives": receives,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course inserted successfully')));
        setState(() {
          futureCourseList = selectAll();
        });
        _clearFields();
      } else {
        print('Failed to insert course');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateCourse(int id, String coursecode, String coursename,
      String credits, String instructor, String groups, String receives) async {
    try {
      final response = await http.post(url, body: {
        "action": "UPDATE_COURSE",
        "id": id.toString(),
        "coursecode": coursecode,
        "coursename": coursename,
        "credits": credits,
        "instructor": instructor,
        "groups": groups,
        "receives": receives,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course updated successfully')));
        setState(() {
          futureCourseList = selectAll();
        });
        _clearFields();
      } else {
        print('Failed to update course');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      final response = await http.post(url, body: {
        "action": "DELETE_COURSE",
        "id": id.toString(),
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course deleted successfully')));
        setState(() {
          futureCourseList = selectAll();
        });
      } else {
        print('Failed to delete course');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<dynamic>> selectCourseBycode(String coursecode) async {
    try {
      final response = await http.post(url, body: {
        "action": "SELECT_COURSE_BY_CODE",
        "coursecode": coursecode,
      });

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody == "No records found") {
          return [];
        }
        final data = jsonDecode(responseBody);
        return data;
      } else {
        print('Failed to select course by code');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> selectAll() async {
    try {
      final response = await http.post(url, body: {
        "action": "SELECT_ALL_COURSES",
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else {
          return [];
        }
      } else {
        print('Failed to select all courses');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void _clearFields() {
    _coursecodeController.clear();
    _coursenameController.clear();
    _creditsController.clear();
    _instructorController.clear();
    _searchController.clear();
    _searhcoursebycode.clear();
    _groups.clear();
    _receives.clear();
    isEditing = false;
  }

  void _editCourse(Map<String, dynamic> course) {
    setState(() {
      _coursecodeController.text = course['coursecode'];
      _coursenameController.text = course['coursename'];
      _creditsController.text = course['credits'] ?? '';
      _instructorController.text = course['instructor'];
      _groups.text = course['groups'];
      _receives.text = course['receives'];
      editingId = int.tryParse(course['id']) ?? null;
      isEditing = true;
    });
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this course?'),
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
                deleteCourse(id);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> searchCourseByCode() async {
    if (_searhcoursebycode.text.isNotEmpty) {
      String coursecode = _searhcoursebycode.text;
      List<dynamic> result = await selectCourseBycode(coursecode);
      if (result.isNotEmpty) {
        // Show course details in a dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 500,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.blue[100], // กำหนดสีพื้นหลังเป็นสีฟ้าอ่อน
                  borderRadius: BorderRadius.circular(10), // ปรับขอบให้โค้งมน
                ),
                child: AlertDialog(
                  title: Text(
                    'Course Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'ID: ${result[0]['id']}\n'
                    'Course Code: ${result[0]['coursecode']}\n'
                    'Course Name: ${result[0]['coursename']}\n'
                    'Credits: ${result[0]['credits']}\n'
                    'Instructor: ${result[0]['instructor']}\n'
                    'Groups: ${result[0]['groups']}\n'
                    'Receives: ${result[0]['receives']}',
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
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.of(context).pop(); // ปิด Dialog
                    //     _editCourse(result[0]); // เรียกฟังก์ชันแก้ไขข้อมูล
                    //   },
                    //   child: Text(
                    //     'Edit',
                    //     style: TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.blue[700]),
                    //   ),
                    // ),
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
          SnackBar(content: Text('No course found with code $coursecode')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a course code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Page',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add / Edit Course',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600]),
              ),
              Form(
                key: _formKey,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _coursecodeController,
                      decoration: InputDecoration(
                        labelText: 'Course Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a course code';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _coursenameController,
                      decoration: InputDecoration(
                        labelText: 'Course Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a course name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _creditsController,
                      decoration: InputDecoration(
                        labelText: 'Credits',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of credits';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _instructorController,
                      decoration: InputDecoration(
                        labelText: 'Instructor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the instructor name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _groups,
                      decoration: InputDecoration(
                        labelText: 'groups',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the groups name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _receives,
                      decoration: InputDecoration(
                        labelText: 'receives',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the receives name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (isEditing && editingId != null) {
                          updateCourse(
                              editingId!,
                              _coursecodeController.text,
                              _coursenameController.text,
                              _creditsController.text,
                              _instructorController.text,
                              _groups.text,
                              _receives.text);
                        } else {
                          insertCourse(
                              _coursecodeController.text,
                              _coursenameController.text,
                              _creditsController.text,
                              _instructorController.text,
                              _groups.text,
                              _receives.text);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade700,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize:
                          Size(double.infinity, 20), // ปรับให้ปุ่มเต็มความกว้าง
                      shadowColor: Colors.grey, // สีของเงา
                      elevation: 10, // ความสูงของเงา
                    ),
                    child: Text(
                      isEditing ? 'Update Course' : 'Add Course',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 10,
              ),
              // SizedBox(height: 20),
              Text(
                'Search Course by Code',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600]),
              ),
              TextFormField(
                controller: _searhcoursebycode,
                decoration: InputDecoration(
                  labelText: 'Course Code',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: searchCourseByCode,
                  ),
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<List<dynamic>>(
                future: futureCourseList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No courses available'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Prevents ListView from scrolling
                      itemBuilder: (context, index) {
                        final course = snapshot.data![index];
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
                                    color: Colors.purple[400], // พื้นหลังสีม่วง
                                    borderRadius: BorderRadius.circular(
                                        4), // รัศมีของมุมคอนเทนเนอร์
                                  ),
                                  child: Text(
                                    course['coursecode'], // แสดงรหัสวิชา
                                    style: TextStyle(
                                      color: Colors.white, // ข้อความสีขาว
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18, // ขนาดตัวอักษร
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        8), // เว้นระยะห่างระหว่างรหัสวิชาและข้อมูลอื่นๆ
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              'ID: ${course['id']}\n'
                              'Coursename: ${course['coursename']}', // แสดง ID และรายละเอียดเพิ่มเติม (ถ้ามี)
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () => _editCourse(course),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _confirmDelete(int.parse(course['id'])),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
