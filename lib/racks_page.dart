import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RacksPage extends StatefulWidget {
  const RacksPage({Key? key}) : super(key: key);

  @override
  _RacksPageState createState() => _RacksPageState();
}

class _RacksPageState extends State<RacksPage> {
  List<dynamic> racks = [];
  List<dynamic> searchResults = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  int totalRolls = 0;
  double totalWeight = 0.0;

  @override
  void initState() {
    super.initState();
    fetchRacksOrSearch();
  }

  Future<void> fetchRacksOrSearch({String? query}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = query == null || query.isEmpty
          ? 'http://192.168.11.14:8000/warehouse/api/racks/'
          : 'http://192.168.11.14:8000/warehouse/api/search/?query=$query';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          racks = data;
          searchResults = data;
          calculateTotals();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Ошибка загрузки данных: Код ошибки ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка сети: $e';
        isLoading = false;
      });
    }
  }

  void calculateTotals() {
    totalRolls = 0;
    totalWeight = 0.0;

    for (var rack in searchResults) {
      for (var shelf in rack['shelves'] ?? []) {
        for (var cell in shelf['cells'] ?? []) {
          for (var batch in cell['batches'] ?? []) {
            totalRolls += ((batch['rolls_count'] ?? 0) as num).toInt();
            totalWeight += (batch['rolls_weight'] ?? 0.0).toDouble();
          }
        }
      }
    }
  }

  void performSearch() {
    fetchRacksOrSearch(query: searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  searchQuery = value;
                },
                decoration: InputDecoration(
                  hintText: 'Поиск партии...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white),
                ),
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: performSearch,
            ),
          ],
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: Colors.redAccent, fontSize: 18),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stacked_bar_chart, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text(
                        'Рулонов: $totalRolls',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Вес: ${totalWeight.toStringAsFixed(2)} кг',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: searchResults.length,
              itemBuilder: (context, rackIndex) {
                final rack = searchResults[rackIndex];
                final rackCode = rack['rack']?['code'] ?? 'Неизвестный стеллаж';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.8),
                      child: Icon(Icons.inventory, color: Colors.white),
                    ),
                    title: Text(
                      rackCode,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    children: [
                      for (var shelf in rack['shelves'] ?? [])
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.withOpacity(0.8),
                              child: Icon(Icons.layers, color: Colors.white),
                            ),
                            title: Text(
                              'Полка ${shelf['shelf_code'] ?? 'Неизвестная полка'}',
                              style: TextStyle(fontSize: 18, color: Colors.black87),
                            ),
                            children: [
                              for (var cell in shelf['cells'] ?? [])
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
                                  ),
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange.withOpacity(0.8),
                                      child: Icon(Icons.grid_on, color: Colors.white),
                                    ),
                                    title: Text(
                                      'Ячейка ${cell['cell_code'] ?? 'Неизвестная ячейка'}',
                                      style: TextStyle(fontSize: 16, color: Colors.black87),
                                    ),
                                    children: [
                                      if (cell['batches'] != null && cell['batches'].isNotEmpty)
                                        for (var batch in cell['batches'])
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.green.withOpacity(0.8),
                                              child: Icon(Icons.local_shipping, color: Colors.white),
                                            ),
                                            title: Text(
                                              batch['batch'] ?? 'Неизвестная партия',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            subtitle: Text(
                                              'Лот: ${batch['lot'] ?? 'неизвестен'}, Рулоны: ${batch['rolls_count'] ?? 'неизвестно'}, Вес: ${batch['rolls_weight'] ?? 'неизвестен'}',
                                              style: TextStyle(fontSize: 14, color: Colors.black54),
                                            ),
                                          )
                                      else
                                        const ListTile(
                                          leading: Icon(Icons.block, color: Colors.redAccent),
                                          title: Text('Нет партий'),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
