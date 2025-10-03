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
    print('🔗 LinkDriverScreen initialized with ${linkedDrivers.length} initial drivers');
    
    // Load all drivers when screen opens
    _loadAllDrivers();
  }
  
  // Load all available drivers when screen opens
  Future<void> _loadAllDrivers() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      print('📋 Loading all available drivers...');
      final apiProvider = ApiProvider();
      final allDrivers = await apiProvider.getAllAvailableDrivers();
      print('📋 Found ${allDrivers.length} total drivers from API');
      
      setState(() {
        suggestions = allDrivers;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading drivers: $e');
      setState(() {
        suggestions = [];
        isLoading = false;
      });
    }
  }

  void searchDrivers(String query) async {
    if (query.isEmpty) {
      // If query is empty, reload all drivers
      _loadAllDrivers();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('🔍 Searching drivers with query: "$query"');
      
      // First try to search using the API
      final apiProvider = ApiProvider();
      final searchResults = await apiProvider.searchDriversByEmail(query);
      print('🔍 API search returned ${searchResults.length} drivers');
      
      if (searchResults.isNotEmpty) {
        setState(() {
          suggestions = searchResults;
          isLoading = false;
        });
        return;
      }
      
      // If API search returns no results, try local filtering
      print('🔍 API search returned no results, trying local filtering...');
      final allDrivers = await apiProvider.getAllAvailableDrivers();
      
      // Filter drivers based on search query
      final filteredDrivers = allDrivers.where((driver) {
        final name = driver['name']?.toString().toLowerCase() ?? '';
        final email = driver['email']?.toString().toLowerCase() ?? '';
        final mobile = driver['mobile']?.toString().toLowerCase() ?? '';
        final queryLower = query.toLowerCase();
        
        return name.contains(queryLower) || 
               email.contains(queryLower) || 
               mobile.contains(queryLower);
      }).toList();

      print('🎯 Local filtering found ${filteredDrivers.length} drivers matching "$query"');
      setState(() {
        suggestions = filteredDrivers;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error searching drivers: $e');
      setState(() {
        suggestions = [];
        isLoading = false;
      });
    }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                children: [
                  Text('Select or Assign a Driver', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black)),
                  const Spacer(),
                  Text(
                    '2/3',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 2/3, // 2/3 = 66.7% complete
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
                minHeight: 3,
              ),
              const SizedBox(height: 32),
              
              // Custom header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select or Assign a Driver',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onDriversSelected(linkedDrivers);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
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
                    SizedBox(height: 8),
                    Center(child: Text('Loading drivers...')),
                  ],
                  if (!isLoading && suggestions.isEmpty && searchController.text.isEmpty) ...[
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No drivers found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try searching by email, name, or phone number',
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!isLoading && suggestions.isEmpty && searchController.text.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No drivers found for "${searchController.text}"',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (suggestions.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text('Available Drivers:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 8),
                    ...suggestions.map((driver) => Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(Icons.person, color: Colors.blue[700]),
                        ),
                        title: Text(driver['name'] ?? 'Unknown Driver', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver['email'] ?? 'No email'),
                            if (driver['mobile'] != null) Text(driver['mobile']),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => addDriver(driver),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text('Add'),
                        ),
                      ),
                    )),
                  ],
                  SizedBox(height: 16),
                  if (linkedDrivers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Linked Drivers:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...linkedDrivers.asMap().entries.map((entry) => ListTile(
                          leading: Icon(Icons.person),
                          title: Text(entry.value['email'] ?? ''),
                          subtitle: Text(entry.value['name'] ?? entry.value['mobile'] ?? ''),
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
                  
                  try {
                    final driverIds = linkedDrivers.map((d) => d['id'].toString()).toList();
                    print('=== Assigning drivers to dispatcher ===');
                    print('=== Dispatcher ID: $dispatcherId ===');
                    print('=== Driver IDs: $driverIds ===');
                    
                    final result = await ApiProvider().assignDriversToDispatcher(
                      dispatcherId: dispatcherId.toString(),
                      driverIds: driverIds,
                    );
                    
                    setState(() { isLoading = false; });
                    
                    if (result['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] ?? 'Drivers assigned successfully')),
                      );
                      Navigator.of(context).pushReplacementNamed('/CongratulationsScreen');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] ?? 'Failed to assign drivers.')),
                      );
                    }
                  } catch (e) {
                    print('Error assigning drivers: $e');
                    setState(() { isLoading = false; });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error assigning drivers: $e')),
                    );
                  }
                },
                child: Text('Assign'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  print('⏭️ Skipping driver selection');
                  widget.onDriversSelected(linkedDrivers);
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: Text(
                  'Skip - Continue without linking drivers',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
} 