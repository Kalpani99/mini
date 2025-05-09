import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:track_bus/constants/app_style.dart';
import 'package:track_bus/widget/date_time_widget.dart';
import 'package:track_bus/widget/textfield_widget.dart';

class AddNewTaskModel extends StatefulWidget {
  final String fromWhere;
  final String toWhere;
  final String arrTimeTask;
  final String deptTimeTask;
  final String dateTask;
  final String documentId;

  const AddNewTaskModel(
      {super.key,
      this.fromWhere = '',
      this.toWhere = '',
      this.deptTimeTask = '',
      this.arrTimeTask = '',
      this.dateTask = '',
      required Null Function(dynamic editedFrom, dynamic editedTo,
              dynamic editedArrTime, dynamic editedDeptTime, dynamic editedDate)
          onSave,
      required this.documentId});

  @override
  State<AddNewTaskModel> createState() => _AddNewTaskModelState();
}

class _AddNewTaskModelState extends State<AddNewTaskModel> {
  DateTime dateTime = DateTime(2025, 01, 01, 5, 30);
  DateTime dateTime1 = DateTime(2025, 01, 01, 4, 30);

  TextEditingController fromWhereController = TextEditingController();
  TextEditingController toWhereController = TextEditingController();
  TextEditingController arrTimeTaskController = TextEditingController();
  TextEditingController deptTimeTaskController = TextEditingController();
  TextEditingController dateTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the passed values
    fromWhereController.text = widget.fromWhere;
    toWhereController.text = widget.toWhere;
    arrTimeTaskController.text = widget.arrTimeTask;
    deptTimeTaskController.text = widget.deptTimeTask;
    dateTaskController.text = widget.dateTask;
  }

  @override
  void dispose() {
    fromWhereController.dispose();
    toWhereController.dispose();
    arrTimeTaskController.dispose();
    deptTimeTaskController.dispose();
    dateTaskController.dispose();
    super.dispose();
  }

  void _saveDataToFirestore() async {
    try {
      final CollectionReference busScheduleCollection =
          FirebaseFirestore.instance.collection('busShedule');

      await busScheduleCollection.add({
        'fromWhere': fromWhereController.text,
        'toWhere': toWhereController.text,
        'arrTimeTask': arrTimeTaskController.text,
        'deptTimeTask': deptTimeTaskController.text,
        'date': dateTaskController.text,
      });

      Navigator.pop(context); // Close the bottom sheet
    } catch (error) {
      // Handle the error appropriately
      print('Error saving data: $error');
    }
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
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  headerText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Divider(
                thickness: 1.2,
                color: Colors.grey.shade200,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'From',
                style: AppStyle.headingOne,
              ),
              const SizedBox(
                height: 6,
              ),
              TextFieldWidget(
                maxLine: 1,
                hintText: "add from where",
                txtController: fromWhereController,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'To',
                style: AppStyle.headingOne,
              ),
              const SizedBox(
                height: 6,
              ),
              TextFieldWidget(
                maxLine: 1,
                hintText: "add to where",
                txtController: toWhereController,
              ),
              const SizedBox(
                height: 12,
              ),
              DateTimeWidget(
                titleText: 'Date',
                valueText: '${dateTime.year}/${dateTime.month}/${dateTime.day}',
                iconSection: CupertinoIcons.calendar,
                onTap: () async {
                  final date = await pickDate();
                  if (date == null) return;

                  final newDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    dateTime.hour,
                    dateTime.minute,
                  );

                  setState(() {
                    dateTime = date;
                    dateTaskController.text =
                        '${date.year}/${date.month}/${date.day}';
                  });
                },
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DateTimeWidget(
                      titleText: 'Depature Time',
                      valueText:
                          '${dateTime1.hour.toString().padLeft(2, '0')}:${dateTime1.minute.toString().padLeft(2, '0')}',
                      iconSection: CupertinoIcons.clock,
                      onTap: () async {
                        final time1 = await pickTime1();
                        if (time1 == null) return;

                        final newDateTime1 = DateTime(
                            dateTime1.year,
                            dateTime1.month,
                            dateTime1.day,
                            time1.hour,
                            time1.minute);

                        setState(() {
                          dateTime1 = newDateTime1;
                        });
                        deptTimeTaskController.text =
                            '${time1.hour.toString().padLeft(2, '0')}:${time1.minute.toString().padLeft(2, '0')}';
                      },
                    ),
                    const SizedBox(
                      width: 22,
                    ),
                    DateTimeWidget(
                      titleText: 'Arrival Time',
                      valueText:
                          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                      iconSection: CupertinoIcons.clock,
                      onTap: () async {
                        final time = await pickTime();
                        if (time == null) return;

                        final newDateTime = DateTime(
                            dateTime.year,
                            dateTime.month,
                            dateTime.day,
                            time.hour,
                            time.minute);

                        setState(() {
                          dateTime = newDateTime;
                        });
                        arrTimeTaskController.text =
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 150),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(
                      width: 22,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (!_validateInputFields() &&
                              widget.documentId == '') {
                            _saveDataToFirestore();
                          } else {
                            _updateTaskInFirestore(
                                widget.documentId,
                                fromWhereController.text,
                                toWhereController.text,
                                arrTimeTaskController.text,
                                deptTimeTaskController.text,
                                dateTaskController.text);
                            Navigator.pop(context);
                          }
                        },
                        child: widget.documentId == ''
                            ? const Text('Create')
                            : const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));
  Future<TimeOfDay?> pickTime1() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime1.hour, minute: dateTime1.minute));

  bool _validateInputFields() {
    if (fromWhereController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a value for "From"')),
      );
      return true;
    }

    if (toWhereController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a value for "To"')),
      );
      return true;
    }

    if (arrTimeTaskController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a value for "arr Time"')),
      );
      return true;
    }

    if (deptTimeTaskController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a value for "dept time"')),
      );
      return true;
    }

    if (dateTaskController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a value for "date"')),
      );
      return true;
    }
    // Add more validation checks for other fields if needed
    return false;
  }

  String headerText() {
    if (fromWhereController.text.isEmpty) {
      return "Add Text";
    } else {
      return "Edit Text";
    }
  }
}
