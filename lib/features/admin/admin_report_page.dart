import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';

class AdminReportPage extends StatefulWidget {
  @override
  _AdminReportPageState createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  List<dynamic> reports = [];
  bool isLoading = true;
  MyIP myIP = MyIP();

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final url = Uri.parse('${myIP.domain}:3000/getReports');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          reports = jsonDecode(response.body)['reports'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (error) {
      print('Error fetching reports: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Management'),
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Report ID')),
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Reason')),
                    DataColumn(label: Text('Reporter')),
                    DataColumn(label: Text('Owner')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: reports.map<DataRow>((report) {
                    return DataRow(
                      cells: [
                        DataCell(Text(report['report_id'].toString())),
                        DataCell(Text(report['item_name'] ?? 'N/A')),
                        DataCell(Text(report['reason'])),
                        DataCell(Text(report['reporter'] ?? 'N/A')),
                        DataCell(Text(report['owner'] ?? 'N/A')),
                        DataCell(Text(report['report_date'] ?? 'N/A')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
