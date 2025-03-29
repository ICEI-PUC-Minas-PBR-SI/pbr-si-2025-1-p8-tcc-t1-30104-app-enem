import 'package:app/screens/profile/profile_page.dart';
import 'package:app/screens/result/result_page.dart';
import 'package:app/screens/study_plan/study_plan_page.dart';
import 'package:flutter/material.dart';
import '../tests/tests_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    TestsPage(),
    ResultsPage(),
    StudyPlanPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Novo App de Testes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: _pages[_selectedIndex],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child:BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedItemColor: Colors.deepPurple,
                    unselectedItemColor: Colors.grey,
                    selectedFontSize: 14,
                    unselectedFontSize: 0,
                    showUnselectedLabels: false,
                    showSelectedLabels: true,
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.check_circle, size: 24),
                        activeIcon: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, size: 30),
                            SizedBox(height: 2),
                          ],
                        ),
                        label: 'Testes',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.bar_chart, size: 24),
                        activeIcon: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.bar_chart, size: 30),
                            SizedBox(height: 2),
                          ],
                        ),
                        label: 'Resultados',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.book, size: 24),
                        activeIcon: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.book, size: 30),
                            SizedBox(height: 2),
                          ],
                        ),
                        label: 'Plano de Estudo',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.person, size: 24),
                        activeIcon: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person, size: 30),
                            SizedBox(height: 2),
                          ],
                        ),
                        label: 'Perfil',
                      )
                    ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}