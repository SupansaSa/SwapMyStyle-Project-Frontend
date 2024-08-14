import 'package:flutter/material.dart';
import 'package:myapp/features/shop/add/add_home.dart';
import 'package:myapp/features/shop/add/edit_page.dart';
import 'package:myapp/features/shop/swap/swap_page.dart'; // เพิ่มการนำเข้า SwapPage
import 'package:myapp/widgets/custom_button.dart';
import 'package:http/http.dart' as http;

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final String currentUserId;

  const ItemDetailPage({Key? key, required this.item, required this.currentUserId}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  Future<bool> _deleteItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.54:3000/deleteItem/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  void _showDeleteDialog(bool isDeleted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isDeleted ? 'สำเร็จ' : 'ข้อผิดพลาด'),
          content: Text(isDeleted
              ? 'ลบรายการสำเร็จ'
              : 'ลบรายการล้มเหลว'),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop(); 
                if (isDeleted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AddHomePage()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _onActionButtonPressed(String action) async {
    print('Button pressed: $action'); // ข้อความสำหรับดีบัก
    if (action == 'swap') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SwapPage(item: widget.item), 
        ),
      );
    } else if (action == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPage(item: widget.item),
        ),
      );
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await _deleteItem(widget.item['id'].toString());
                _showDeleteDialog(success);
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.currentUserId == widget.item['user_id'].toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item['item_photo'] != null)
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  'http://192.168.1.54:3000/uploads/${widget.item['item_photo']}',
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16.0),
            Text('${widget.item['item_name']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: ' Type : ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text: '${widget.item['item_type']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: ' Price(baht) : ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text: '${widget.item['item_price'].toString()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: ' Detail : ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text: '${widget.item['item_detail']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: ' Description : ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text: '${widget.item['item_description']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isOwner) ...[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    child: IconButton(
                      icon: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited
                            ? Color(0xFFE966A0)
                            : Color(0xFFE966A0),
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ],
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: CustomButton(
                      title: isOwner ? 'Edit' : 'Swap',
                      onPressed: (BuildContext context) {
                        print('Button pressed: ${isOwner ? 'edit' : 'swap'}'); 
                        _onActionButtonPressed(isOwner ? 'edit' : 'swap');
                      },
                    ),
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.grey, 
                      size: 40,
                    ),
                    onPressed: () {
                      print('Button pressed: delete'); 
                      _onActionButtonPressed('delete');
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
