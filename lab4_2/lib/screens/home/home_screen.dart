import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import '../tabs/announcements_tab.dart';
import '../tabs/schedule_tab.dart';
import '../tabs/grades_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/children_tab.dart';
import '../tabs/manage_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().current?.role ?? 'student';

    final tabs = switch (role) {
      'teacher' => const [
        ManageTab(), // quản lý (điểm, thông báo)
        AnnouncementsTab(),
        ProfileTab(),
      ],
      'parent' => const [
        ChildrenTab(), // chọn con
        AnnouncementsTab(),
        ScheduleTab(),
        GradesTab(),
        ProfileTab(),
      ],
      _ => const [AnnouncementsTab(), ScheduleTab(), GradesTab(), ProfileTab()],
    };

    final navs = switch (role) {
      'teacher' => const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_customize),
          label: 'Quản lý',
        ),
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          label: 'Thông báo',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Cá nhân',
        ),
      ],
      'parent' => const [
        NavigationDestination(icon: Icon(Icons.family_restroom), label: 'Con'),
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          label: 'Thông báo',
        ),
        NavigationDestination(icon: Icon(Icons.event_note), label: 'Lịch'),
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Điểm'),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Cá nhân',
        ),
      ],
      _ => const [
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          label: 'Thông báo',
        ),
        NavigationDestination(icon: Icon(Icons.event_note), label: 'Lịch học'),
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Điểm'),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Cá nhân',
        ),
      ],
    };

    if (idx >= tabs.length) idx = 0;

    return Scaffold(
      appBar: AppBar(title: Text('School – ${role.toUpperCase()}')),
      body: tabs[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: navs,
      ),
    );
  }
}
