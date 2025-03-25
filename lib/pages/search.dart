import 'package:flutter/material.dart';
import 'package:esyria/database_helper.dart';
import 'package:esyria/pages/record_details.dart';

class SearchRecordPage extends StatefulWidget {
  const SearchRecordPage({super.key});

  @override
  _SearchRecordPageState createState() => _SearchRecordPageState();
}

class _SearchRecordPageState extends State<SearchRecordPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchRecords() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final results = await dbHelper.searchRecords(_searchController.text);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء البحث: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('بحث عن سجل'),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'ابحث بالاسم أو الرقم الوطني',
                      labelStyle: const TextStyle(color: Colors.green),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.green),
                        onPressed: _searchRecords,
                      ),
                    ),
                    onSubmitted: (_) => _searchRecords(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isSearching
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final record = _searchResults[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              '${record['name']} ${record['surname']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'الرقم الوطني: ${record['nationalId']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onTap: () async {
                              final updatedRecord = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecordDetailsPage(record: record),
                                ),
                              );
                              
                              if (updatedRecord != null) {
                                setState(() {
                                  _searchResults[_searchResults.indexOf(record)] = updatedRecord;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
