import 'package:flutter/material.dart';

class ShowCardListWidget extends StatelessWidget {
  final String documentId;
  final String fromWhere;
  final String toWhere;
  final String date;
  final String arrTimeTask;
  final String deptTimeTask;

  const ShowCardListWidget({
    super.key,
    required this.documentId,
    required this.fromWhere,
    required this.toWhere,
    required this.date,
    required this.deptTimeTask,
    required this.arrTimeTask,
  });

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
