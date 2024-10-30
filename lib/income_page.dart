import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'batch_data_page.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({Key? key}) : super(key: key);

  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController _qrCodeController = TextEditingController();
  final FocusNode _qrFocusNode = FocusNode();

  Future<void> _fetchCellData() async {
    final qrDataIdentifier = _qrCodeController.text;
    final url = Uri.parse('http://127.0.0.1:8000/warehouse/batches/by-qr/$qrDataIdentifier/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final int? cellId = data.isNotEmpty ? data.first['cells'][0] as int? : null;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BatchDataPage(
              batchData: data,
              cellId: cellId,
            ),
          ),
        );

        if (data.isEmpty) {
          _showSnackbar('Данные не найдены, но можно добавить новые', Colors.grey);
        }
      } else {
        _showSnackbar('Стеллаж не определен', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Ошибка сети', Colors.red);
    } finally {
      _qrCodeController.clear();
      _qrFocusNode.requestFocus();
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Партии', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE30808), Color(0xFFE87210)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0E0E0), Color(0xFFB3E5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                'Отсканируйте QR-Код',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _qrCodeController,
                focusNode: _qrFocusNode,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.qr_code, color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  labelText: 'QR-Код',
                  labelStyle: const TextStyle(color: Colors.black54),
                ),
                onSubmitted: (value) => _fetchCellData(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _qrCodeController.dispose();
    _qrFocusNode.dispose();
    super.dispose();
  }
}
