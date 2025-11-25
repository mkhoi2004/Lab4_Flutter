import 'package:flutter/material.dart';
import 'manage_announcements_tab.dart';
import 'manage_grades_tab.dart';
import 'manage_schedules_tab.dart';

class ManageTab extends StatelessWidget {
  const ManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // ✅ phải = số tab
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.campaign), text: 'Thông báo'),
            Tab(icon: Icon(Icons.school), text: 'Điểm'),
            Tab(icon: Icon(Icons.event_note), text: 'Lịch học'),
          ],
        ),
        body: TabBarView(
          children: [
            ManageAnnouncementsTab(),
            ManageGradesTab(),
            ManageSchedulesTab(), // ✅ dùng ở đây thì import hết unused ngay
          ],
        ),
      ),
    );
  }
}
