import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserRequest {
  final String batch;
  final String createdAt;
  final double requestedRollsCount;
  final double requestedRollsWeight;
  final String rack;
  final String shelf;
  final String cell;
  final bool isUnlinked;
  final bool isPartiallyUnlinked;

  UserRequest({
    required this.batch,
    required this.createdAt,
    required this.requestedRollsCount,
    required this.requestedRollsWeight,
    required this.rack,
    required this.shelf,
    required this.cell,
    required this.isUnlinked,
    required this.isPartiallyUnlinked,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      batch: json['batch'].toString(),
      createdAt: json['created_at'],
      requestedRollsCount: json['requested_rolls_count']?.toDouble() ?? 0.0,
      requestedRollsWeight: json['requested_rolls_weight']?.toDouble() ?? 0.0,
      rack: json['rack'],
      shelf: json['shelf'],
      cell: json['cell'],
      isUnlinked: json['is_unlinked'] ?? false,
      isPartiallyUnlinked: json['is_partially_unlinked'] ?? false,
    );
  }
}

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  late Future<Map<String, dynamic>> futureUserRequests;

  @override
  void initState() {
    super.initState();
    futureUserRequests = fetchUserRequests();
  }

  Future<Map<String, dynamic>> fetchUserRequests() async {
    final response = await http.get(
        Uri.parse('http://192.168.11.14:8000/warehouse_temp/user_requests/'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final activeBatches = (jsonResponse['active']['batches'] as List)
          .map((data) => UserRequest.fromJson(data))
          .toList();

      return {
        "active": {
          "batches": activeBatches,
          "total_rolls": jsonResponse['active']['total_rolls'],
          "total_weight": jsonResponse['active']['total_weight'],
        },
        "partially_unlinked": (jsonResponse['partially_unlinked']['batches'] as List)
            .map((data) => UserRequest.fromJson(data))
            .toList(),
        "fully_unlinked": (jsonResponse['fully_unlinked']['batches'] as List)
            .map((data) => UserRequest.fromJson(data))
            .toList(),
      };
    } else {
      throw Exception('Failed to load user requests');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      futureUserRequests = fetchUserRequests();
    });
    await futureUserRequests;
  }

  Future<void> _sendData() async {
    final response = await http.get(
      Uri.parse('http://192.168.11.14:8000/warehouse_temp/user-requests/pdf/'),
    );

    if (response.statusCode == 200) {
      print("Data sent successfully.");
    } else {
      print("Failed to send data.");
    }
  }

  Widget buildDataBlock(UserRequest batch) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              batch.batch,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory, color: Colors.orange, size: 12),
                  const SizedBox(width: 4),
                  Text('Рулоны: ${batch.requestedRollsCount}',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.line_weight, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text('Вес: ${batch.requestedRollsWeight} кг',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warehouse, color: Colors.purple, size: 12),
                  const SizedBox(width: 4),
                  Text('Стеллаж: ${batch.rack}',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shelves, color: Colors.teal, size: 12),
                  const SizedBox(width: 4),
                  Text('Полка: ${batch.shelf}',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.grid_view, color: Colors.deepOrange, size: 12),
                  const SizedBox(width: 4),
                  Text('Ячейка: ${batch.cell}',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSimpleDataBlock(UserRequest batch) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              batch.batch,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory, color: Colors.orange, size: 12),
              const SizedBox(width: 4),
              Text('Рулоны: ${batch.requestedRollsCount}',
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.line_weight, color: Colors.green, size: 12),
              const SizedBox(width: 4),
              Text('Вес: ${batch.requestedRollsWeight} кг',
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSummary(double totalRolls, double totalWeight) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Итоги',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
          const SizedBox(height: 5),
          Text(
            'Рулоны: $totalRolls, Вес: $totalWeight кг',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Запросы',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _sendData,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
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
            colors: [Colors.blueGrey, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<Map<String, dynamic>>(
            future: futureUserRequests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Нет данных'));
              } else {
                final activeBatches = snapshot.data!['active']["batches"];
                final activeTotalRolls = snapshot.data!['active']['total_rolls'];
                final activeTotalWeight = snapshot.data!['active']['total_weight'];
                final partiallyUnlinkedBatches = snapshot.data!['partially_unlinked'];
                final fullyUnlinkedBatches = snapshot.data!['fully_unlinked'];

                return ListView(
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'ЗАПРОС',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                            const SizedBox(height: 10),
                            ...activeBatches.map((batch) => buildDataBlock(batch)),
                            buildSummary(activeTotalRolls, activeTotalWeight),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'ЧАСТИЧНО ОТКРЕПЛЕННЫЕ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent),
                            ),
                            const SizedBox(height: 10),
                            ...partiallyUnlinkedBatches.map((batch) => buildSimpleDataBlock(batch)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'ГОТОВО',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 10),
                            ...fullyUnlinkedBatches.map((batch) => buildSimpleDataBlock(batch)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
