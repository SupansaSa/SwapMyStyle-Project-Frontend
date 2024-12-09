import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/features/shop/add/item_detail_page.dart';
import 'package:myapp/screen/MyIP.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _selectedItemType;
  RangeValues _selectedPriceRange = RangeValues(0, 3000);
  RangeValues _tempPriceRange =
      RangeValues(0, 3000); // Temporary value for slider
  
  MyIP myIP = MyIP();

  Future<void> _searchItems(String query) async {
    if (query.isEmpty &&
        _selectedItemType == null &&
        _selectedPriceRange == RangeValues(0, 3000)) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          '${myIP.domain}:3000/searchItems?q=$query&itemType=${_selectedItemType ?? ''}&minPrice=${_selectedPriceRange.start}&maxPrice=${_selectedPriceRange.end}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(data['items']);
          });
          _clearSearch();
          _clearFilters();
        } else {
          setState(() {
            _searchResults = [];
          });
        }
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
  }

  void _clearFilters() {
    _selectedItemType = null;
    _selectedPriceRange = RangeValues(0, 3000);
  }

  void _showFilterDialog() {
    _tempPriceRange = _selectedPriceRange; // Initialize with current range
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Item Type'),
                    value: _selectedItemType,
                    items: [
                      'เสื้อ',
                      'กางเกง',
                      'กระโปรง',
                      'เครื่องประดับ',
                      'กระเป๋า',
                      'รองเท้า'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedItemType = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Price Range', style: TextStyle(fontSize: 16)),
                  RangeSlider(
                    values: _tempPriceRange,
                    min: 0,
                    max: 3000,
                    divisions: 10,
                    labels: RangeLabels(
                      '${_tempPriceRange.start.round()}',
                      '${_tempPriceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _tempPriceRange = values;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPriceRange =
                      _tempPriceRange; // Update selected range
                });
                Navigator.of(context).pop();
                _searchItems(_searchController.text);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 150, // กำหนดความสูงของ header
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find a style that suits you best.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), // ปรับขนาดความสูงของ SizedBox นี้
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in Store',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFE966A0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFE966A0),
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onSubmitted: _searchItems,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_searchResults.isEmpty &&
                _searchController.text.isNotEmpty)
              Center(child: Text('No results found'))
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigating to item detail page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailPage(item: item, currentUserId: '',),
                          ),
                        );
                      },
                       child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['item_photo'] != null)
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Builder(
                                    builder: (context) {
                                      List<dynamic> itemPhotos = [];
                                      try {
                                        itemPhotos = json.decode(item['item_photo']);
                                      } catch (e) {
                                        print('Error decoding item photos: $e');
                                      }

                                      String imageUrl = itemPhotos.isNotEmpty
                                          ? '${myIP.domain}:3000/uploads/items/${itemPhotos[0]}'
                                          : '';

                                      return imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Error loading image: $error');
                                                return const Center(
                                                  child: Icon(Icons.image, size: 100),
                                                );
                                              },
                                            )
                                          : const Center(child: Icon(Icons.image, size: 100));
                                    },
                                  ),
                                ),
                              )
                            else
                              const Icon(Icons.image, size: 150),
                            const SizedBox(height: 8.0),
                            Text(
                              item['item_name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item['item_price'].toString()}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
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