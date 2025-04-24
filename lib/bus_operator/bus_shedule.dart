import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:track_bus/common/show_model.dart';
import 'package:track_bus/bus_operator/ratings.dart';
import 'package:track_bus/widget/crad_todo_widget.dart';
import 'package:track_bus/bus_operator/navigation/bottom_navigation.dart';
import 'package:track_bus/bus_operator/bostarttrip.dart';
import 'package:track_bus/bus_operator/viewBOprofile.dart';

class BusScheduleScreen extends StatefulWidget {
  const BusScheduleScreen({Key? key}) : super(key: key);

  @override
  _BusScheduleScreenState createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {
  int _currentIndex = 1;

  final CollectionReference _busSchedule =
      FirebaseFirestore.instance.collection('busShedule');

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          toolbarHeight: 50,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Bus Schedule',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              )),
          actions: [
            IconButton(
              onPressed: () => _showDatePicker(context),
              icon: const Icon(
                CupertinoIcons.calendar,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upcoming Schedule",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: AddNewTaskModel(
                              onSave: (editedFrom, editedTo, editedDeptTime,
                                  editedArrTime, editedDate) {},
                              documentId: '',
                            ),
                          ),
                        );
                      },
                      child: const Text('+ Add Schedule'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: _busSchedule.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final documents = snapshot.data!.docs;

                    if (documents.isEmpty) {
                      return const Center(
                        child: Text("No schedules available."),
                      );
                    }

                    return ListView.builder(
                      itemCount: documents.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final data =
                            documents[index].data() as Map<String, dynamic>?;

                        if (data == null) return const SizedBox.shrink();

                        return CardTodoListWidget(
                          documentId: documents[index].id,
                          fromWhere: data['fromWhere'] ?? '',
                          toWhere: data['toWhere'] ?? '',
                          date: data['date'] ?? '',
                          deptTimeTask: data['deptTimeTask'] ?? '',
                          arrTimeTask: data['arrTimeTask'] ?? '',
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onTabTapped: (index) {
            if (index == _currentIndex) return;
            setState(() => _currentIndex = index);

            Widget targetScreen;
            switch (index) {
              case 0:
                targetScreen = const BOStartTrip();
                break;
              case 1:
                targetScreen = const BusScheduleScreen();
                break;
              case 2:
                targetScreen = const RatingScreen();
                break;
              case 3:
                targetScreen = const ProfileTypeScreen();
                break;
              default:
                return;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => targetScreen),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final currentDate = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate.subtract(const Duration(days: 365)),
      lastDate: currentDate.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      // You can handle selectedDate here.
      // For now it's not doing anything.
    }
  }
}
