import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:myapp/thems/theme.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemPage extends StatefulWidget {
  static const double defaultMargin = 16.0;

  const AddItemPage({Key? key}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  File? _image;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemTypeController = TextEditingController();
  final TextEditingController _itemDetailController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  // ignore: unused_field
  int _itemPrice = 0; //เพิ่งแก้

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemTypeController.dispose();
    _itemDetailController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  //เพิ่งแก้
  void _updateItemPrice() {
    setState(() {
      _itemPrice = int.tryParse(_itemPriceController.text) ?? 0;
    });
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> addItem() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null) {
      _showErrorDialog('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาล็อกอินอีกครั้ง');
      return;
    }

    int itemPrice = int.tryParse(_itemPriceController.text) ?? 0;

    final url = Uri.parse('http://192.168.1.54:3000/addItem');
    final request = http.MultipartRequest('POST', url);

    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('item_photo', _image!.path));
    }
    request.fields['userId'] = userId;
    request.fields['item_name'] = _itemNameController.text;
    request.fields['item_type'] = _itemTypeController.text;
    request.fields['item_detail'] = _itemDetailController.text;
    request.fields['item_description'] = _itemDescriptionController.text;
    request.fields['item_price'] = itemPrice.toString();
    //แปลงเป็น stringเพื่อส่งไปยังเซิร์ฟเวอร์

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Navigator.pop(context, {
          'itemName': _itemNameController.text,
          'itemType': _itemTypeController.text,
          'itemDetail': _itemDetailController.text,
          'itemDescription': _itemDescriptionController.text,
          'itemPrice': _itemPriceController.text,
          'itemPhoto': _image != null ? _image!.path.split('/').last : null,
        });
      } else {
        _showErrorDialog(
            'ข้อผิดพลาด', 'เกิดข้อผิดพลาดขณะเพิ่มข้อมูลสินค้า: $responseBody');
      }
    } catch (error) {
      _showErrorDialog(
          'ข้อผิดพลาด', 'เกิดข้อผิดพลาดขณะสื่อสารกับเซิร์ฟเวอร์: $error');
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
              child: const Text('ตกลง', style: TextStyle(color: Colors.pink)),
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
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AddItemPage.defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const SizedBox(height: 15),
              Text(
                'Add Product',
                style: blackTextStyle.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE966A0), width: 4),
                  ),
                  child: _image == null
                      ? const Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      size: 50, color: Color(0xFFE966A0)),
                                  SizedBox(height: 10),
                                  Text(
                                    '+ เพิ่มรูปภาพ',
                                    style: TextStyle(
                                      color: Color(0xFFE966A0),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Name',
                hintText: 'Item name...',
                textEditingController: _itemNameController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Type',
                hintText: 'Select item type...',
                textEditingController: _itemTypeController,
                suffixIcon: DropdownButton<String>(
                  value: _itemTypeController.text.isNotEmpty
                      ? _itemTypeController.text
                      : null,
                  onChanged: (newValue) {
                    setState(() {
                      _itemTypeController.text = newValue!;
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
                title: 'Price(Bath)',
                hintText: 'Type your price...',
                textEditingController: _itemPriceController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Detail',
                hintText: 'Detail of item...',
                maxLines: 5,
                textEditingController: _itemDetailController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Description',
                hintText: 'Type your description...',
                maxLines: 5,
                textEditingController: _itemDescriptionController,
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 45,
                    width: 120,
                    child: CustomButton(
                      title: 'Cancel',
                      onPressed: (BuildContext context) {
                        Navigator.pop(context);
                      },
                      color: Colors.deepPurple[500],
                    ),
                  ),
                  SizedBox(
                    height: 45,
                    width: 120,
                    child: CustomButton(
                      title: 'Add product',
                      onPressed: (BuildContext context) {
                        addItem();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}