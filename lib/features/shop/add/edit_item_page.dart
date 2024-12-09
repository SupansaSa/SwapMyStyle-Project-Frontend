import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EditItemPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditItemPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  List<File> _selectedImages = []; // เปลี่ยนเป็น List<File> สำหรับเก็บรูปภาพใหม่
  List<dynamic> _existingPhotos = []; // เก็บรูปภาพที่มีอยู่
  List<String> _photosToDelete = []; // เก็บรายการรูปที่ต้องการลบ
  late MyIP myIP; // ประกาศ MyIP ที่นี่
  late String imageUrl; // ประกาศ URL ที่ใช้เชื่อมต่อกับรูปภาพ

  @override
  void initState() {
    super.initState();
    // กำหนดค่า TextEditingController
    _nameController = TextEditingController(text: widget.item['item_name']);
    _typeController = TextEditingController(text: widget.item['item_type']);
    _priceController = TextEditingController(text: widget.item['item_price'].toString());
    _descriptionController = TextEditingController(text: widget.item['item_description']);

    // กำหนดค่า imageUrl
    myIP = MyIP(); // ให้แน่ใจว่าได้สร้าง MyIP ที่นี่
    imageUrl = '${myIP.domain}:3000/uploads/items/'; // ตั้งค่าให้กับ imageUrl

    // ดึงรูปภาพที่มีอยู่
    if (widget.item['item_photo'] != null && widget.item['item_photo'].isNotEmpty) {
      _existingPhotos = jsonDecode(widget.item['item_photo']);
    }
  }

  // ฟังก์ชันเลือกภาพ
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path)); // เพิ่มรูปใหม่เข้าไปในลิสต์
      });
    }
  }

  // ฟังก์ชันบันทึกสินค้า
  Future<void> saveItem() async {
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');

  if (userId == null) {
    _showErrorDialog('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาล็อกอินอีกครั้ง');
    return;
  }

  var request = http.MultipartRequest(
    'PUT',
    Uri.parse('${myIP.domain}:3000/updateItem/${widget.item['id']}'),
  );
  request.headers['Content-Type'] = 'multipart/form-data';

  request.fields['userId'] = userId; // ส่งค่า userId
  request.fields['item_name'] = _nameController.text;
  request.fields['item_type'] = _typeController.text;
  request.fields['item_price'] = _priceController.text;
  request.fields['item_description'] = _descriptionController.text;

  // ส่งรูปภาพที่ต้องการลบ
  if (_photosToDelete.isNotEmpty) {
    request.fields['delete_photos'] = jsonEncode(_photosToDelete);
  }

  // ส่งรูปภาพที่มีอยู่
  for (var photo in _existingPhotos) {
    request.fields['existing_photos'] = photo; 
  }

  // ส่งรูปภาพใหม่
  for (var image in _selectedImages) {
    request.files.add(await http.MultipartFile.fromPath(
        'item_photo', image.path)); 
  }

  var response = await request.send();
  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    var data = jsonDecode(responseData);
    if (data['success']) {
      Navigator.pop(context, data['item']);
    } else {
      print('Error: ${data['message']}');
    }
  } else {
    print('Failed to save item');
  }
}

void _showErrorDialog(String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('ตกลง'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขรายละเอียดสินค้า'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  Wrap(
                    spacing: 10,
                    children: [
                      ..._existingPhotos.map((photo) {
                        return Stack(
                          children: [
                            Image.network(
                              '$imageUrl$photo',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                return Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300], // สีพื้นหลังเมื่อเกิดข้อผิดพลาด
                                  child: const Icon(Icons.broken_image, color: Colors.red), // แสดงไอคอนเมื่อไม่สามารถโหลดภาพได้
                                );
                              },
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photosToDelete.add(photo);
                                    _existingPhotos.remove(photo);
                                  });
                                },
                                child: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 20), 
                 
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.pink, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.pink, size: 40),
                            SizedBox(height: 8),
                            Text(
                              "เลือกภาพ",
                              style: TextStyle(color: Colors.pink),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    children: _selectedImages.map((image) {
                      return Stack(
                        children: [
                          Image.file(
                            image,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.remove(image);
                                });
                              },
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              CustomTextField(
                title: 'Name',
                hintText: 'Item name...',
                textEditingController: _nameController,
              ),
              
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Type',
                hintText: 'Select item type...',
                textEditingController: _typeController,
                suffixIcon: DropdownButton<String>(
                  value: _typeController.text.isNotEmpty
                      ? _typeController.text
                      : null,
                  onChanged: (newValue) {
                    setState(() {
                      _typeController.text = newValue!;
                    });
                  },
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
                ),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Price',
                hintText: 'Item price...',
                textEditingController: _priceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Description',
                hintText: 'Item description...',
                maxLines: 5,
                textEditingController: _descriptionController,
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: CustomButton(
                        title: 'บันทึก',
                        onPressed: (BuildContext context) {
                          saveItem();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
