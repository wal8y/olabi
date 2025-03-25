import 'package:esyria/pages/adding.dart';
import 'package:flutter/material.dart';
import 'package:esyria/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/date_picker.dart';

class EditRecordPage extends StatefulWidget {
  final Map<String, dynamic> record;

  const EditRecordPage({super.key, required this.record});

  @override
  _EditRecordPageState createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _recordData;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _recordData = Map<String, dynamic>.from(widget.record);
  }

  Future<void> _updateRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.updateRecord(_recordData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث السجل بنجاح')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التحديث: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل السجل'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRecordPage(record: widget.record),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Add form fields similar to AddRecordPage
                // Example for name field:
                TextFormField(
                  initialValue: _recordData['name'],
                  decoration: const InputDecoration(
                    labelText: 'الاسم الأول',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  onSaved: (value) => _recordData['name'] = value,
                ),
                // Add other fields following the same pattern
                _buildEditableImage(
                  'الصورة الرئيسية',
                  _recordData['mainImage'],
                  () async {
                    final image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _recordData['mainImage'] = image.path;
                      });
                    }
                  },
                ),
                // Add similar fields for idFront and idBack
                _buildDateField('تاريخ الميلاد', _recordData['birthDate'], (date) {
                  setState(() {
                    _recordData['birthDate'] = "${date.year}-${date.month}-${date.day}";
                  });
                }),
                // Marital status section
                TextFormField(
                  initialValue: _recordData['maritalStatus'],
                  decoration: const InputDecoration(
                    labelText: 'الحالة الاجتماعية',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  onSaved: (value) => _recordData['maritalStatus'] = value,
                ),
                if (_recordData['maritalStatus'] == 'متزوج') ...[
                  TextFormField(
                    initialValue: _recordData['wivesCount'],
                    decoration: const InputDecoration(
                      labelText: 'عدد الزوجات',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    onSaved: (value) => _recordData['wivesCount'] = value,
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    initialValue: _recordData['childrenCount'],
                    decoration: const InputDecoration(
                      labelText: 'عدد الأولاد',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    onSaved: (value) => _recordData['childrenCount'] = value,
                    keyboardType: TextInputType.number,
                  ),
                ],
                // Wives section
                if (_recordData['maritalStatus'] == 'متزوج') 
                  for (int i = 1; i <= (_recordData['wivesCount'] ?? 0); i++)
                    Column(
                      children: [
                        TextFormField(
                          initialValue: _recordData['wife${i}Name'],
                          decoration: InputDecoration(
                            labelText: 'اسم الزوجة $i',
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          onSaved: (value) => _recordData['wife${i}Name'] = value,
                        ),
                        TextFormField(
                          initialValue: _recordData['wife${i}Age'],
                          decoration: InputDecoration(
                            labelText: 'عمر الزوجة $i',
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          onSaved: (value) => _recordData['wife${i}Age'] = value,
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          initialValue: _recordData['wife${i}Occupation'],
                          decoration: InputDecoration(
                            labelText: 'مهنة الزوجة $i',
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          onSaved: (value) => _recordData['wife${i}Occupation'] = value,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableImage(String title, String? imagePath, Function() onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (imagePath != null)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(title),
                      backgroundColor: Colors.black,
                    ),
                    body: Center(
                      child: Image.file(File(imagePath)),
                    ),
                  ),
                ),
              );
            },
            child: Image.file(
              File(imagePath),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onTap,
          child: Text(imagePath == null ? 'إضافة صورة' : 'تغيير الصورة'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField(String label, String? initialValue, Function(DateTime) onDateSelected) {
    final controller = TextEditingController(text: initialValue);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showCustomDatePicker(context);
        if (date != null) {
          onDateSelected(date);
          controller.text = "${date.year}-${date.month}-${date.day}";
        }
      },
    );
  }
} 