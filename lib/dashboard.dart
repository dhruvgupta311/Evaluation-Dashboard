import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentor/models/student.dart';
import 'package:mentor/models/mentor.dart';

void main() {
  runApp(const EvaluationDashboard());
}

class EvaluationDashboard extends StatelessWidget {
  const EvaluationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evaluation Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // Button color
            onPrimary: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const EvaluationDashboardPage(),
    );
  }
}

class EvaluationDashboardPage extends StatefulWidget {
  const EvaluationDashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EvaluationDashboardPageState createState() =>
      _EvaluationDashboardPageState();
}

class _EvaluationDashboardPageState extends State<EvaluationDashboardPage> {
  List<Student> unassignedStudents = [];
  List<Student> allStudents = [];
  List<Mentor> mentors = [];
  Mentor? selectedMentor;
  Student? selectedStudent;
  bool isDisabled = true;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchMentorsFromFirebase();
    fetchUnassignedStudentsFromFirebase();
  }

  Future<void> fetchMentorsFromFirebase() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('mentors').get();
    List<Mentor> fetchedMentors = querySnapshot.docs.map((doc) {
      List<String> assignedStudents =
          List<String>.from(doc['assignedStudents']);
      return Mentor(
        name: doc['name'],
        uid: doc['uid'],
        assignedStudents: assignedStudents,
      );
    }).toList();
    setState(() {
      mentors = fetchedMentors;
      selectedMentor = mentors.isNotEmpty ? mentors[0] : null;
    });
  }

  Future<void> fetchUnassignedStudentsFromFirebase() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('students').get();
    List<Student> fetchedStudents = querySnapshot.docs.map((doc) {
      return Student(
        name: doc['name'],
        uid: doc['uid'],
        ideationMarks: doc['ideationMarks'],
        executionMarks: doc['executionMarks'],
        vivaMarks: doc['vivaMarks'],
        isAssigned: doc['isAssigned'],
      );
    }).toList();

    List<Student> unassignedStudents = fetchedStudents
        .where((element) => element.isAssigned == false)
        .toList();

    setState(() {
      allStudents = fetchedStudents;
      this.unassignedStudents = unassignedStudents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchMentorsFromFirebase();
          await fetchUnassignedStudentsFromFirebase();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: DropdownButton<Mentor>(
                    value: selectedMentor,
                    onChanged: (Mentor? newValue) {
                      setState(() {
                        selectedMentor = newValue!;
                      });
                    },
                    items:
                        mentors.map<DropdownMenuItem<Mentor>>((Mentor mentor) {
                      return DropdownMenuItem<Mentor>(
                        value: mentor,
                        child: Text(mentor.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: DropdownButton<Student>(
                  value: selectedStudent,
                  onChanged: (Student? newValue) {
                    setState(() {
                      selectedStudent = newValue!;
                    });
                  },
                  hint: Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0), // Add padding here
                    child: const Text('Unassigned Students'),
                  ),
                  items: unassignedStudents
                      .map<DropdownMenuItem<Student>>((Student student) {
                    return DropdownMenuItem<Student>(
                      value: student,
                      child: Text(student.name),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (selectedStudent != null && selectedMentor != null) {
                    if (selectedMentor!.assignedStudents.length < 4) {
                      // Update the Firestore documents
                      log(selectedStudent!.uid);
                      await updateFirestore(
                          selectedStudent!.uid, selectedMentor!.uid);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mentor can only have a maximum of 4 students.',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Assign Students'),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: selectedMentor?.assignedStudents.length ?? 0,
                itemBuilder: (context, index) {
                  // print(selectedMentor?.assignedStudents.length);
                  String id = selectedMentor!.assignedStudents[index];
                  // print(allStudents);
                  // print(id);
                  Student s =
                      allStudents.firstWhere((element) => element.uid == id);
                  TextEditingController executionController =
                      TextEditingController(text: s.executionMarks);
                  TextEditingController ideationController =
                      TextEditingController(text: s.ideationMarks);
                  TextEditingController vivaController =
                      TextEditingController(text: s.vivaMarks);

                  // print(s);
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(s.name),
                      subtitle: Text(
                        s.isAssigned ? 'Marks assigned' : 'Marks not assigned',
                        style: TextStyle(
                          color: s.isAssigned ? Colors.green : Colors.red,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  // Calculate total marks
                                  int totalMarks =
                                      int.parse(executionController.text) +
                                          int.parse(ideationController.text) +
                                          int.parse(vivaController.text);

                                  return AlertDialog(
                                    title: const Text('Edit Marks'),
                                    content: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: <Widget>[
                                            TextFormField(
                                              enabled: isDisabled,
                                              validator: (value) {
                                                if (value == "") {
                                                  return "Please enter a value";
                                                }
                                                return null;
                                              },
                                              controller: executionController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Execution Marks',
                                              ),
                                            ),
                                            TextFormField(
                                              enabled: isDisabled,
                                              validator: (value) {
                                                if (value == "") {
                                                  return "Please enter a value";
                                                }
                                                return null;
                                              },
                                              controller: ideationController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Ideation Marks',
                                              ),
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == "") {
                                                  return "Please enter a value";
                                                }
                                                return null;
                                              },
                                              controller: vivaController,
                                              enabled: isDisabled,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Viva Marks',
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Total Marks: $totalMarks',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: !isDisabled
                                        ? [
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  isDisabled = false;
                                                });
                                              },
                                              icon: const Icon(Icons.lock),
                                            )
                                          ]
                                        : [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Save'),
                                              onPressed: () async {
                                                if (!(_formKey.currentState!
                                                    .validate())) {
                                                  return;
                                                }
                                                await FirebaseFirestore.instance
                                                    .collection('students')
                                                    .doc(s.uid)
                                                    .update({
                                                  'vivaMarks':
                                                      vivaController.text,
                                                  'executionMarks':
                                                      executionController.text,
                                                  'ideationMarks':
                                                      ideationController.text
                                                });
                                                if (context.mounted) {
                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(
                                                  //   const SnackBar(
                                                  //     content: Text(
                                                  //         'Marks saved successfully.'),
                                                  //   ),
                                                  // );
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  isDisabled = false;
                                                });
                                              },
                                              icon: const Icon(Icons.lock),
                                            )
                                          ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              if (selectedMentor != null &&
                                  selectedMentor!.assignedStudents.length > 3) {
                                await FirebaseFirestore.instance
                                    .collection('students')
                                    .doc(s.uid)
                                    .update({'isAssigned': false});
                                await FirebaseFirestore.instance
                                    .collection('mentors')
                                    .doc(selectedMentor!.uid)
                                    .update({
                                  'assignedStudents':
                                      FieldValue.arrayRemove([s.uid]),
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Mentor should have a minimum of 3 students.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateStudentMarksInFirestore(String studentName,
      int executionMarks, int ideationMarks, int vivaMarks) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentName)
          .update({
        'executionMarks': executionMarks,
        'ideationMarks': ideationMarks,
        'vivaMarks': vivaMarks,
      });
    } catch (error) {
      // print('Error updating student marks: $error');
      // Handle error
    }
  }

  Future<void> fetchStudentMarksFromFirestore(String studentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          selectedStudent!.executionMarks = data['executionMarks'] ?? 0;
          selectedStudent!.ideationMarks = data['ideationMarks'] ?? 0;
          selectedStudent!.vivaMarks = data['vivaMarks'] ?? 0;
        });
      } else {
        // print('No data found for student with ID: $studentId');
      }
    } catch (error) {
      // print('Error fetching student marks: $error');
      // Handle error
    }
  }

  Future<void> updateFirestore(String studentId, String mentorId) async {
    try {
      // Remove the student from the unassigned students list in Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({
        "isAssigned": true,
      });

      // Add the student to the mentor's assigned students list in Firestore
      await FirebaseFirestore.instance
          .collection('mentors')
          .doc(mentorId)
          .update({
        'assignedStudents': FieldValue.arrayUnion([studentId]),
      });
    } catch (error) {
      // print('Error updating Firestore: $error');
      // Handle the error here, e.g., show a snackbar or display an error message
    }
  }
}
