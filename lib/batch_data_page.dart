import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BatchDataPage extends StatefulWidget {
  final List batchData;
  final int? cellId;
  final String rackName;
  final String shelfName;
  final String cellName;

  const BatchDataPage({
    Key? key,
    required this.batchData,
    this.cellId,
    required this.rackName,
    required this.shelfName,
    required this.cellName,
  }) : super(key: key);

  @override
  _BatchDataPageState createState() => _BatchDataPageState();
}

class _BatchDataPageState extends State<BatchDataPage> {
  late List _batchData;

  @override
  void initState() {
    super.initState();
    _batchData = widget.batchData;
  }

  Future<void> _fetchBatchData() async {
    if (widget.cellId == null) return;

    final url = Uri.parse('http://192.168.11.14:8000/warehouse/batches/by-cell/${widget.cellId}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _batchData = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        _showSnackbar('Ошибка загрузки данных', Colors.orange, Icons.warning);
      }
    } catch (e) {
      _showSnackbar('Ошибка сети', Colors.red, Icons.error);
    }
  }

  Future<void> _detachBatch(int batchId) async {
    final url = Uri.parse('http://192.168.11.14:8000/warehouse/batches/detach/$batchId/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({"cell_id": widget.cellId}),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Партия успешно откреплена', Colors.green, Icons.check_circle);
        _fetchBatchData();
      } else {
        _showSnackbar('Ошибка при откреплении партии', Colors.red, Icons.error);
      }
    } catch (e) {
      _showSnackbar('Ошибка сети', Colors.red, Icons.error);
    }
  }

  void _showSnackbar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
      ),
    );
  }

  void _navigateToAddBatch(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: AddBatchForm(cellId: widget.cellId, showSnackbar: _showSnackbar),
        );
      },
    );

    if (result == true) {
      _fetchBatchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.rackName} / ${widget.shelfName} / ${widget.cellName}'),
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
      body: ListView.builder(
        itemCount: _batchData.length,
        itemBuilder: (context, index) {
          final batch = _batchData[index];
          return Dismissible(
            key: ValueKey(batch['id']),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.lightBlue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.arrow_circle_right_outlined, color: Colors.white),
            ),
            onDismissed: (direction) {
              _detachBatch(batch['id']);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.inventory, color: Colors.indigo),
                title: Text(
                  'Партия: ${batch['batch']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Лот: ${batch['lot']}'),
                    Row(
                      children: [
                        const Icon(Icons.layers, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Рулоны: ${batch['rolls_count']}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Вес: ${batch['rolls_weight']} кг'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBatch(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        tooltip: 'Добавить партию',
      ),
    );
  }
}

class AddBatchForm extends StatefulWidget {
  final int? cellId;
  final Function(String, Color, IconData) showSnackbar;

  const AddBatchForm({Key? key, this.cellId, required this.showSnackbar}) : super(key: key);

  @override
  _AddBatchFormState createState() => _AddBatchFormState();
}

class _AddBatchFormState extends State<AddBatchForm> {
  final TextEditingController batchController = TextEditingController();
  final TextEditingController lotController = TextEditingController();
  final TextEditingController rollsCountController = TextEditingController();
  final TextEditingController rollsWeightController = TextEditingController();

  Future<void> _addBatch(BuildContext context) async {
    if (widget.cellId == null) {
      widget.showSnackbar('Не удалось добавить партию: идентификатор ячейки отсутствует', Colors.red, Icons.error);
      return;
    }

    final url = Uri.parse('http://192.168.11.14:8000/warehouse/batches/create/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          "batch": batchController.text,
          "lot": lotController.text,
          "rolls_count": double.tryParse(rollsCountController.text) ?? 0.0,
          "rolls_weight": double.tryParse(rollsWeightController.text) ?? 0.0,
          "cells": [widget.cellId],
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        widget.showSnackbar('Ошибка при добавлении партии', Colors.orange, Icons.warning);
      }
    } catch (e) {
      widget.showSnackbar('Ошибка сети', Colors.red, Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Добавить новую партию',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: batchController,
          label: 'Название партии',
          icon: Icons.label_outline,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: lotController,
          label: 'Лот',
          icon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: rollsCountController,
          label: 'Количество рулонов',
          icon: Icons.stacked_bar_chart,
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: rollsWeightController,
          label: 'Вес рулонов',
          icon: Icons.line_weight,
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _addBatch(context),
          icon: const Icon(Icons.save_alt, color: Colors.white),
          label: const Text(
            'Сохранить',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
