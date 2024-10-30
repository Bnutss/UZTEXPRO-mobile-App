import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'batch_data_page.dart';

class PartyPage extends StatefulWidget {
  const PartyPage({Key? key}) : super(key: key);

  @override
  _PartyPageState createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  final TextEditingController _qrCodeController = TextEditingController();
  final FocusNode _qrFocusNode = FocusNode();

  Future<void> _fetchCellData() async {
    final qrDataIdentifier = _qrCodeController.text;
    final url = Uri.parse('http://192.168.11.14:8000/warehouse/batches/by-qr/$qrDataIdentifier/');

    try {
      final response = await http.get(url);
      final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 || response.statusCode == 404) {
        final List<dynamic> batches = responseData['batches'] ?? [];
        final int? cellId = responseData['cell_id'] ?? responseData['cell']?['id'] as int?;
        final String rackName = responseData['cell']?['rack_shelf']?['shelf']?['code'] ?? 'N/A';
        final String shelfName = responseData['cell']?['rack_shelf']?['code'] ?? 'N/A';
        final String cellName = responseData['cell']?['code'] ?? 'N/A';
        final String displayLocation = "$rackName Полка $shelfName Ячейка $cellName";

        if (cellId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BatchDataPage(
                batchData: batches,
                cellId: cellId,
                rackName: displayLocation,
                shelfName: '',
                cellName: '',
              ),
            ),
          );
        } else {
          _showSnackbar('Ячейка не найдена.', Colors.red);
        }
      } else {
        _showSnackbar('Ошибка при загрузке данных.', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Ошибка сети.', Colors.red);
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE30808), Color(0xFFE87210)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
