import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserRequest {
  final String batch;
  final String createdAt;

  UserRequest({required this.batch, required this.createdAt});

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      batch: json['batch'].toString(),
      createdAt: json['created_at'],
    );
  }
}

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  late Future<Map<String, List<UserRequest>>> futureUserRequests;

  @override
  void initState() {
    super.initState();
    futureUserRequests = fetchUserRequests();
  }

  Future<Map<String, List<UserRequest>>> fetchUserRequests() async {
    final response = await http.get(Uri.parse('http://192.168.11.14:8000/warehouse_temp/user_requests/'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final requestBatches = (jsonResponse['requests'] as List)
          .map((data) => UserRequest.fromJson(data))
          .toList();
      final completedBatches = (jsonResponse['completed'] as List)
          .map((data) => UserRequest.fromJson(data))
          .toList();

      return {
        "requests": requestBatches,
        "completed": completedBatches,
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
          child: FutureBuilder<Map<String, List<UserRequest>>>(
            future: futureUserRequests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Нет данных'));
              } else {
                final requestBatches = snapshot.data!['requests']!;
                final completedBatches = snapshot.data!['completed']!;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
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
                              Expanded(
                                child: ListView.builder(
                                  itemCount: requestBatches.length,
                                  itemBuilder: (context, index) {
                                    final batch = requestBatches[index];
                                    return ListTile(
                                      title: Text(
                                        batch.batch,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Card(
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
                              Expanded(
                                child: ListView.builder(
                                  itemCount: completedBatches.length,
                                  itemBuilder: (context, index) {
                                    final batch = completedBatches[index];
                                    return ListTile(
                                      title: Text(
                                        batch.batch,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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
