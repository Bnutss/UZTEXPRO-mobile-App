import 'package:flutter/material.dart';
import 'income_page.dart';
import 'racks_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UZTEXPRO',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradientButton(
                icon: Icons.add_circle_outline,
                text: 'Партии',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IncomePage()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildGradientButton(
                icon: Icons.storage,
                text: 'Стеллажи',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RacksPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required IconData icon, required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: Colors.black38,
        backgroundColor: Colors.transparent,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.black38, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 250, minHeight: 45),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
