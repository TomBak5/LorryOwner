import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Api_Provider/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LinkDriverScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialDrivers;
  final Function(List<Map<String, dynamic>>) onDriversSelected;
  const LinkDriverScreen({Key? key, required this.initialDrivers, required this.onDriversSelected}) : super(key: key);

  @override
  State<LinkDriverScreen> createState() => _LinkDriverScreenState();
}

class _LinkDriverScreenState extends State<LinkDriverScreen> {
  List<Map<String, dynamic>> linkedDrivers = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> suggestions = [];
  bool isLoading = false;
  String notFoundMsg = '';

  @override
  void initState() {
    super.initState();
    linkedDrivers = List.from(widget.initialDrivers);
  }

  void searchDrivers(String query) async {
    setState(() {
      isLoading = true;
      notFoundMsg = '';
    });
    final results = await ApiProvider().searchDriversByEmail(query);
    setState(() {
      isLoading = false;
      suggestions = results;
      if (results.isEmpty) {
        notFoundMsg = 'No driver found';
      }
    });
  }

  void addDriver(Map<String, dynamic> driver) {
    if (!linkedDrivers.any((d) => d['id'] == driver['id'])) {
      setState(() {
        linkedDrivers.add(driver);
      });
    }
    searchController.clear();
    suggestions = [];
  }

  void removeDriver(int index) {
    setState(() {
      linkedDrivers.removeAt(index);
    });
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString("userData");
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      return int.tryParse(userData["id"].toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link a driver'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onDriversSelected(linkedDrivers);
              Navigator.of(context).pop();
            },
            child: Text('Done'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select or Assign a Driver', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Driver email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      if (value.length > 2) searchDrivers(value);
                      else setState(() { suggestions = []; notFoundMsg = ''; });
                    },
                  ),
                ),
                SizedBox(width: 8),
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      setState(() { suggestions = []; notFoundMsg = ''; });
                    },
                  ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  if (isLoading) ...[
                    SizedBox(height: 12),
                    Center(child: CircularProgressIndicator()),
                  ],
                  if (suggestions.isNotEmpty)
                    ...suggestions.map((driver) => ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text(driver['email'] ?? ''),
                      subtitle: Text(driver['mobile'] ?? ''),
                      onTap: () => addDriver(driver),
                    )),
                  if (notFoundMsg.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(notFoundMsg, style: TextStyle(color: Colors.red)),
                    ),
                  SizedBox(height: 16),
                  if (linkedDrivers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Linked Drivers:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...linkedDrivers.asMap().entries.map((entry) => ListTile(
                          leading: Icon(Icons.person),
                          title: Text(entry.value['email'] ?? ''),
                          subtitle: Text(entry.value['mobile'] ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => removeDriver(entry.key),
                          ),
                        )),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  int? dispatcherId = await getCurrentUserId();
                  if (dispatcherId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not determine dispatcher ID.')),
                    );
                    return;
                  }
                  if (linkedDrivers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select at least one driver.')),
                    );
                    return;
                  }
                  setState(() { isLoading = true; });
                  final driverIds = linkedDrivers.map((d) => int.tryParse(d['id'].toString()) ?? 0).where((id) => id > 0).toList();
                  final result = await ApiProvider().assignDriversToDispatcher(
                    dispatcherId: dispatcherId,
                    driverIds: driverIds,
                  );
                  setState(() { isLoading = false; });
                  if (result['success'] == true) {
                    Navigator.of(context).pushReplacementNamed('/CongratulationsScreen');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Failed to assign drivers.')),
                    );
                  }
                },
                child: Text('Assign'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  widget.onDriversSelected(linkedDrivers);
                  Navigator.of(context).pop();
                },
                child: Text('Skip now', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 