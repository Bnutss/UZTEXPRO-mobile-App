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
          ? 'http://127.0.0.1:8000/warehouse/api/racks/'
          : 'http://127.0.0.1:8000/warehouse/api/search/?query=$query';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          racks = data;
          searchResults = data;
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
          : searchResults.isEmpty
          ? Center(
        child: Text(
          'Партия "$searchQuery" не найдена',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
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
                    fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
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
    );
  }
}
