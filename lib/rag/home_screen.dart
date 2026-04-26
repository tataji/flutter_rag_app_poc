import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pipeline_screen.dart';
import 'chat_screen.dart';
import 'vector_store_screen.dart';
import 'modules_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  final List<Widget> _screens = const [
    PipelineScreen(),
    ChatScreen(),
    VectorStoreScreen(),
    ModulesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          _buildBackground(),
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1120),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.account_tree_outlined, Icons.account_tree, 'Pipeline'),
              _navItem(1, Icons.chat_bubble_outline, Icons.chat_bubble, 'RAG Chat'),
              _navItem(2, Icons.grid_view_outlined, Icons.grid_view, 'Vectors'),
              _navItem(3, Icons.widgets_outlined, Icons.widgets, 'Modules'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D4FF).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF6B7280),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF6B7280),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.025)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
