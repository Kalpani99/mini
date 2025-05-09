import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:track_bus/common/show_model.dart';
import 'package:flutter/material.dart';

class CardTodoListWidget extends StatelessWidget {
  final String documentId;
  final String fromWhere;
  final String toWhere;
  final String date;
  final String arrTimeTask;
  final String deptTimeTask;

  const CardTodoListWidget({
    super.key,
    required this.documentId,
    required this.fromWhere,
    required this.toWhere,
    required this.date,
    required this.deptTimeTask,
    required this.arrTimeTask,
  });

  void _deleteData(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('busShedule')
          .doc(documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data and widget deleted")),
      );
    } catch (error) {
      print("Error deleting document: $error");
    }
  }

  void _editTask(BuildContext context, String documentId, String fromWhere,
      String toWhere, String arrTimeTask, String deptTimeTask, String date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: AddNewTaskModel(
            documentId: documentId,
            fromWhere: fromWhere,
            toWhere: toWhere,
            arrTimeTask: arrTimeTask,
            deptTimeTask: deptTimeTask,
            dateTask: date,
            onSave: (editedFrom, editedTo, editedArrTime, editedDeptTime,
                editedDate) {
              _updateTaskInFirestore(documentId, editedFrom, editedTo,
                  editedArrTime, editedDeptTime, editedDate);
              Navigator.pop(context); // Close the bottom sheet
            },
          ),
        );
      },
    );
  }

  Future<void> _updateTaskInFirestore(
      String documentId,
      String editedFrom,
      String editedTo,
      String editedArrTime,
      String editedDeptTime,
      String editedDate) async {
    try {
      await FirebaseFirestore.instance
          .collection('busShedule')
          .doc(documentId)
          .update({
        'fromWhere': editedFrom,
        'toWhere': editedTo,
        'arrTimeTask': editedArrTime,
        'deptTimeTask': editedDeptTime,
        'date': editedDate,
      });
      print("Document updated");
    } catch (error) {
      print("Error updating document: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              width: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('From: $fromWhere'),
                      subtitle: Text(
                        'To: $toWhere',
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _editTask(context, documentId, fromWhere, toWhere,
                                  deptTimeTask, arrTimeTask, date);
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Entry'),
                                    content: const Text(
                                        'Are you sure you want to delete this entry?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('busShedule')
                                                .doc(
                                                    documentId) // Use the document ID to identify the document
                                                .delete();
                                            print("Document deleted");
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Data and widget deleted")),
                                            );
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          } catch (error) {
                                            print(
                                                "Error deleting document: $error");
                                          }
                                        },
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 2, 2, 2)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.black, // You can change the color
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: Container(
                        child: Column(
                          children: [
                            Divider(
                                thickness: 1.5,
                                color:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            Row(
                              children: [
                                Text(date),
                                const SizedBox(width: 12),
                                Text(
                                  arrTimeTask.isNotEmpty &&
                                          deptTimeTask.isNotEmpty
                                      ? '$deptTimeTask - $arrTimeTask'
                                      : 'No time available',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
