import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Api_Provider/api_provider.dart';

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
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onDriversSelected(linkedDrivers);
                    Navigator.of(context).pop();
                  },
                  child: Text('Skip now'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty && suggestions.isNotEmpty) {
                      addDriver(suggestions.first);
                    }
                  },
                  child: Text('Add another'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 