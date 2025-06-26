import 'package:flutter/material.dart';
import 'chatbot_fab.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final void Function(int)? onTab;
  const BaseScaffold({
    Key? key,
    required this.child,
    this.currentIndex = 0,
    this.onTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: const ChatbotFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: currentIndex,
            selectedItemColor: Color(0xFF7C3AED),
            unselectedItemColor: Colors.black54,
            selectedFontSize: 14,
            unselectedFontSize: 13,
            iconSize: 30,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.report_outlined),
                label: 'Report',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
            onTap: (i) {
              if (onTab != null) {
                onTab!(i);
              } else {
                if (i == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (i == 1) {
                  Navigator.pushReplacementNamed(context, '/learn');
                } else if (i == 2) {
                  Navigator.pushReplacementNamed(context, '/report');
                } else if (i == 3) {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
