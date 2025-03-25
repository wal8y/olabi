import 'dart:convert';
import 'dart:io';

import 'package:esyria/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/date_picker.dart';

class AddRecordPage extends StatefulWidget {
  final Map<String, dynamic>? record;

  const AddRecordPage({super.key, this.record});

  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _recordData = {};

  // الصور الرئيسية والصور الإضافية.
  File? _mainImage;
  File? _idFrontImage;
  File? _idBackImage;
  List<File> _extraDocs = [];

  String? _maritalStatus;
  String? _gender;
  DateTime? _birthDate;
  String? _regimeRelativeAnswer; 
  String? _isisRelativeAnswer;
  String? _prisonRelativeAnswer;

  // تعليم ومهنة
  String? _educationLevel;
  String? _major; // للتخصص
  String? _works; // "نعم" أو "لا"
  String? _previousJobAnswer; // "نعم" أو "لا"

  // Controllers للحقول التي تحتاج لتاريخ.
  final TextEditingController _birthDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _recordData = Map<String, dynamic>.from(widget.record!);
      
      if (_recordData['mainImage'] != null) {
        _mainImage = File(_recordData['mainImage']);
      }
      if (_recordData['idFront'] != null) {
        _idFrontImage = File(_recordData['idFront']);
      }
      if (_recordData['idBack'] != null) {
        _idBackImage = File(_recordData['idBack']);
      }
      
      if (_recordData['extraDocs'] != null) {
        final docs = List<String>.from(jsonDecode(_recordData['extraDocs']));
        _extraDocs = docs.map((path) => File(path)).toList();
      }
      
      _maritalStatus = _recordData['maritalStatus'];
      _educationLevel = _recordData['educationLevel'];
      _major = _recordData['major'];
      _works = _recordData['works'];
      _previousJobAnswer = _recordData['previousJobAnswer'];
      _gender = _recordData['gender'];
      _birthDate = _recordData['birthDate'] != null ? DateTime.parse(_recordData['birthDate']) : null;
      if (_birthDate != null) {
        _birthDateController.text = "${_birthDate!.toLocal()}".split(' ')[0];
      }
    }
  }

  Future<void> _pickMainImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickIdFrontImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _idFrontImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickIdBackImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _idBackImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickExtraDocImage() async {
    if (_extraDocs.length >= 20) return;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _extraDocs.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final pickedDate = await showCustomDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
        _birthDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة سجل جديد'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.black,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // منتقي الصورة الرئيسية.
                  _buildSection('الصورة الرئيسية', [
                    GestureDetector(
                      onTap: _pickMainImage,
                      child: _buildConstrainedContainer(
                        child: _mainImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_mainImage!, fit: BoxFit.cover),
                              )
                            : const Center(
                                child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
                              ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('المعلومات الشخصية', [
                    _buildTextField('الاسم الأول', 'name'),
                    _buildTextField('الاسم الأخير', 'surname'),
                    _buildTextField('اسم الأب', 'fatherName'),
                    _buildTextField('اسم الأم', 'motherName'),
                    _buildTextField('محل الميلاد', 'birthPlace'),
                    _buildEducationDropdown(),
                    _buildDateField('تاريخ الميلاد', _birthDateController, _selectBirthDate),
                    _buildTextField('الرقم الوطني', 'nationalId'),
                  ]),
                  _buildSection('المعلومات الإدارية', [
                    _buildTextField('الأمانة', 'registryOffice'),
                    _buildTextField('القيد', 'registrationNumber'),
                    _buildTextField('الجنس', 'gender'),
                    _buildTextField('لون الوجه', 'faceColor'),
                    _buildTextField('لون العينين', 'eyeColor'),
                  ]),
                  _buildSection('المعلومات العامة', [
                    _buildTextField('العنوان', 'address'),
                    _buildTextField('العلامات المميزة', 'distinctiveMarks'),
                    _buildTextField('وسيلة التواصل', 'contactInfo'),
                  ]),
                  _buildSection('الحالة الاجتماعية', [
                    _buildMaritalStatusDropdown(),
                    if (_maritalStatus == 'متزوج')
                      _buildTextField('اسماء الزوجات', 'spouseName'),
                    if (_maritalStatus != 'أعزب')
                      _buildTextField('عدد الأولاد', 'childrenCount', keyboardType: TextInputType.number),
                  ]),
                  _buildSection('المعلومات السكنية', [
                    _buildTextField('السكن الحالي', 'currentResidence'),
                    _buildTextField('السكن السابق', 'previousResidence'),
                    _buildTextField('اسم المنطقة', 'areaName'),
                    _buildTextField('اسم الحي', 'neighborhood'),
                    _buildTextField('أقرب معلم بارز', 'nearestLandmark'),
                  ]),
                  _buildSection('المعلومات التعليمية', [
                    _buildEducationDropdown(),
                    if (_educationLevel != null &&
                        (_educationLevel == 'بكالوريوس' ||
                         _educationLevel == 'ماجستير' ||
                         _educationLevel == 'دكتوراه' ||
                         _educationLevel == 'أستاذ'))
                      _buildTextField('التخصص', 'major'),
                  ]),
                  // قسم المعلومات المهنية الذكية.
                  _buildSection('المعلومات المهنية', [
                    _buildWorkQuestion(),
                    if (_works == 'نعم') _buildTextField('العمل الحالي', 'currentJob'),
                    _buildPreviousJobQuestion(),
                    if (_previousJobAnswer == 'نعم') _buildTextField('العمل السابق', 'previousJob'),
                  ]),
                  _buildSection('المعلومات المالية', [
                    _buildTextField('الوضع المادي', 'financialStatus'),
                  ]),
                  _buildSection('المعلومات الأخلاقية', [
                    _buildTextField('الناحية الأخلاقية', 'ethicalConduct'),
                  ]),
                  _buildSection('الخدمة العسكرية', [
                    _buildTextField('الخدمة الإلزامية', 'militaryService'),
                  ]),
                  _buildSection('الانتماءات', [
                    _buildTextField('الفصائل المنضمة', 'joinedFactions'),
                    _buildTextField('موقفه من الثورة', 'revolutionStance'),
                  ]),
                  _buildSection('علاقات الأقارب', [
                    _buildRelativeQuestion('أقارب مع النظام السابق', 'relativesWithRegime', (value) {
                      setState(() {
                        _regimeRelativeAnswer = value;
                      });
                    }),
                    if (_regimeRelativeAnswer == 'نعم') ...[
                      _buildTextField('صلة القرابة (مع النظام)', 'regimeRelation'),
                      _buildTextField('مدى التأثر بهم (مع النظام)', 'regimeInfluence'),
                    ],
                    _buildRelativeQuestion('أقارب مع تنظيم الدولة', 'relativesWithISIS', (value) {
                      setState(() {
                        _isisRelativeAnswer = value;
                      });
                    }),
                    if (_isisRelativeAnswer == 'نعم') ...[
                      _buildTextField('صلة القرابة (مع تنظيم الدولة)', 'isisRelation'),
                      _buildTextField('مدى التأثر بهم (مع تنظيم الدولة)', 'isisInfluence'),
                    ],
                    _buildRelativeQuestion('أقارب تم سجنهم', 'imprisonedRelatives', (value) {
                      setState(() {
                        _prisonRelativeAnswer = value;
                      });
                    }),
                    if (_prisonRelativeAnswer == 'نعم') ...[
                      _buildTextField('سبب السجن', 'imprisonmentReason'),
                      _buildTextField('مكان السجن', 'prisonLocation'),
                      _buildTextField('صلة القرابة (مع المسجون)', 'prisonRelation'),
                      _buildTextField('مدى التأثر بهم (مع المسجون)', 'prisonInfluence'),
                    ],
                  ]),
                  _buildSection('المعلومات الدينية والثقافية', [
                    _buildTextField('الالتزام الديني', 'religiousCommitment'),
                    _buildTextField('التوجه الفكري', 'intellectualOrientation'),
                    _buildTextField('مدى التأثر بالمجتمع', 'societyInfluence'),
                    _buildTextField('الصفات الشخصية', 'personalTraits'),
                    _buildTextField('موجز عن حياته', 'lifeSummary'),
                  ]),
                  _buildSection('المعلومات الأمنية', [
                    _buildTextField('تقرير أمني', 'securityReport'),
                    _buildTextField('الأنشطة السابقة', 'pastActivities'),
                    _buildTextField('السوابق الجنائية', 'criminalRecord'),
                    _buildTextField('علاقاته بشخصيات مؤثرة', 'influentialRelations'),
                    _buildTextField('مستوى الثقة به', 'trustLevel'),
                    _buildTextField('تحركاته السابقة', 'pastMovements'),
                    _buildTextField('حيازة الأسلحة', 'weaponPossession'),
                  ]),
                  _buildSection('المعلومات الثقافية', [
                    _buildTextField('الكتب المقروءة', 'booksRead'),
                    _buildTextField('النشاطات الدينية', 'religiousActivities'),
                  ]),
                  _buildSection('الممتلكات والمعاملات', [
                    _buildTextField('الممتلكات والعقارات', 'assets'),
                    _buildTextField('المعاملات المالية', 'suspiciousTransactions'),
                  ]),
                  _buildSection('الشبكات الاجتماعية', [
                    _buildTextField('الشبكات الاجتماعية', 'socialNetworks'),
                  ]),
                  _buildSection('صور الهوية', [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الوجه الأمامي للهوية:', style: TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickIdFrontImage,
                          child: _buildConstrainedContainer(
                            child: _idFrontImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(_idFrontImage!, fit: BoxFit.cover),
                                  )
                                : const Center(
                                    child: Icon(Icons.image, color: Colors.white, size: 40),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الوجه الخلفي للهوية:', style: TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickIdBackImage,
                          child: _buildConstrainedContainer(
                            child: _idBackImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(_idBackImage!, fit: BoxFit.cover),
                                  )
                                : const Center(
                                    child: Icon(Icons.image, color: Colors.white, size: 40),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('الوثائق الإضافية', [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _extraDocs.map((file) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(file, fit: BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: _pickExtraDocImage,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text('أضف وثيقة', style: TextStyle(color: Colors.black)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _saveRecord,
                    child: const Text('حفظ السجل', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConstrainedContainer({required Widget child}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 150),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
          color: Colors.grey[800],
        ),
        child: child,
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 10),
            ...children.map((child) => ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String fieldName,
      {TextInputType keyboardType = TextInputType.text}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: TextFormField(
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(),
            ),
            onSaved: (value) {
              _recordData[fieldName] = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label مطلوب';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, Function() onTap) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(),
            ),
            onTap: onTap,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label مطلوب';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }


  Widget _buildGenderDropdown(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'الجنس',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            value: _gender,
            items: const [
              DropdownMenuItem(value: 'ذكر', child: Text('ذكر', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'انثى', child: Text('انثى', style: TextStyle(color: Colors.white)))
            ],
            onChanged: (value) {
              setState(() {
                _gender = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الجنس مطلوب';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMaritalStatusDropdown() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'الحالة الاجتماعية',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            value: _maritalStatus,
            items: const [
              DropdownMenuItem(value: 'أعزب', child: Text('أعزب', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'متزوج', child: Text('متزوج', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'مطلق', child: Text('مطلق', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'أرمل', child: Text('أرمل', style: TextStyle(color: Colors.white))),
            ],
            onChanged: (value) {
              setState(() {
                _maritalStatus = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الحالة الاجتماعية مطلوبة';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEducationDropdown() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'المستوى التعليمي',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            value: _educationLevel,
            items: const [
              DropdownMenuItem(value: 'غير متعلم', child: Text('غير متعلم', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'مدرسة', child: Text('مدرسة', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'بكالوريوس', child: Text('بكالوريوس', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'ماجستير', child: Text('ماجستير', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'دكتوراه', child: Text('دكتوراه', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'أستاذ', child: Text('أستاذ', style: TextStyle(color: Colors.white))),
            ],
            onChanged: (value) {
              setState(() {
                _educationLevel = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'المستوى التعليمي مطلوب';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorkQuestion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('عمل', style: TextStyle(color: Colors.white)),
              Row(
                children: [
                  Radio<String>(
                    value: 'نعم',
                    groupValue: _works,
                    onChanged: (value) {
                      setState(() {
                        _works = value;
                      });
                    },
                    activeColor: Colors.white,
                  ),
                  const Text('نعم', style: TextStyle(color: Colors.white)),
                  Radio<String>(
                    value: 'لا',
                    groupValue: _works,
                    onChanged: (value) {
                      setState(() {
                        _works = value;
                      });
                    },
                    activeColor: Colors.white,
                  ),
                  const Text('لا', style: TextStyle(color: Colors.white)),
                ],
              ),
              if (_works == 'نعم')
                _buildTextField('تفاصيل العمل الحالي', 'currentJob'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousJobQuestion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('عمل سابق', style: TextStyle(color: Colors.white)),
              Row(
                children: [
                  Radio<String>(
                    value: 'نعم',
                    groupValue: _previousJobAnswer,
                    onChanged: (value) {
                      setState(() {
                        _previousJobAnswer = value;
                      });
                    },
                    activeColor: Colors.white,
                  ),
                  const Text('نعم', style: TextStyle(color: Colors.white)),
                  Radio<String>(
                    value: 'لا',
                    groupValue: _previousJobAnswer,
                    onChanged: (value) {
                      setState(() {
                        _previousJobAnswer = value;
                      });
                    },
                    activeColor: Colors.white,
                  ),
                  const Text('لا', style: TextStyle(color: Colors.white)),
                ],
              ),
              if (_previousJobAnswer == 'نعم')
                _buildTextField('تفاصيل العمل السابق', 'previousJob'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelativeQuestion(String question, String fieldName, Function(String) onChanged) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: question,
              labelStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(),
            ),
            value: _recordData[fieldName],
            items: const [
              DropdownMenuItem(value: 'نعم', child: Text('نعم', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'لا', child: Text('لا', style: TextStyle(color: Colors.white))),
            ],
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
                _recordData[fieldName] = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$question مطلوب';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  void _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (widget.record == null) {
        _recordData['createdAt'] = DateTime.now().toIso8601String();
      }
      
      _recordData['mainImage'] = _mainImage?.path;
      _recordData['idFront'] = _idFrontImage?.path;
      _recordData['idBack'] = _idBackImage?.path;
      _recordData['extraDocs'] = jsonEncode(_extraDocs.map((f) => f.path).toList());
      _recordData['educationLevel'] = _educationLevel;
      _recordData['major'] = _major;
      _recordData['works'] = _works;
      _recordData['currentJob'] = _works == 'نعم' ? _recordData['currentJob'] : null;
      _recordData['previousJob'] = _previousJobAnswer;
      _recordData['previousJob'] = _previousJobAnswer == 'نعم' ? _recordData['previousJob'] : null;

      try {
        final dbHelper = DatabaseHelper();
        if (widget.record == null) {
          await dbHelper.insertRecord(_recordData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ السجل بنجاح')),
          );
        } else {
          await dbHelper.updateRecord(_recordData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث السجل بنجاح')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
        );
      }
    }
  }

  void _addAddress(String address) {
    setState(() {
      final addresses = List<String>.from(jsonDecode(_recordData['addresses'] ?? '[]'));
      addresses.add(address);
      _recordData['addresses'] = jsonEncode(addresses);
    });
  }

  void _addWife(Map<String, dynamic> wife) {
    setState(() {
      final wives = List<Map<String, dynamic>>.from(jsonDecode(_recordData['wives'] ?? '[]'));
      if (wives.length < 4) {
        wives.add(wife);
        _recordData['wives'] = jsonEncode(wives);
      }
    });
  }

  void _addChild(Map<String, dynamic> child) {
    setState(() {
      final children = List<Map<String, dynamic>>.from(jsonDecode(_recordData['children'] ?? '[]'));
      if (children.length < 40) {
        children.add(child);
        _recordData['children'] = jsonEncode(children);
      }
    });
  }

  Widget _buildAddressField() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'إضافة عنوان جديد',
            labelStyle: const TextStyle(color: Colors.white),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addAddress(value);
            }
          },
        ),
        if (_recordData['addresses'] != null)
          ...List<String>.from(jsonDecode(_recordData['addresses'])).map((address) => 
            ListTile(
              title: Text(address, style: const TextStyle(color: Colors.white)),
            )
          ).toList(),
      ],
    );
  }
}
