import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Material(
        color: Colors.transparent,
        child: TabBar(
          unselectedLabelColor: Colors.lightBlueAccent.shade100,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(icon: Icon(Icons.cloud_outlined), text: 'Currently'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.view_week), text: 'Weekly'),
          ],
        ),
      ),
    );
  }
}
