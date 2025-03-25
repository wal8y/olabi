import 'package:esyria/pages/adding.dart';
import 'package:flutter/material.dart';
import 'package:esyria/database_helper.dart';
import 'package:esyria/pages/edit_record.dart';
import 'dart:io';
import 'dart:convert';

class RecordDetailsPage extends StatelessWidget {
  final Map<String, dynamic> record;

  const RecordDetailsPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('تفاصيل السجل'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecordPage(record: record),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('المعلومات الشخصية', [
                  _buildDetailItem('الاسم الأول', record['name']),
                  _buildDetailItem('الاسم الأخير', record['surname']),
                  _buildDetailItem('اسم الأب', record['fatherName']),
                  _buildDetailItem('اسم الأم', record['motherName']),
                  _buildDetailItem('محل الميلاد', record['birthPlace']),
                  _buildDetailItem('تاريخ الميلاد', record['birthDate'] ?? 'غير محدد'),
                  _buildDetailItem('الرقم الوطني', record['nationalId']),
                ]),
                _buildSection('المعلومات الإدارية', [
                  _buildDetailItem('الأمانة', record['registryOffice']),
                  _buildDetailItem('القيد', record['registrationNumber']),
                  _buildDetailItem('الجنس', record['gender']),
                  _buildDetailItem('لون الوجه', record['faceColor']),
                  _buildDetailItem('لون العينين', record['eyeColor']),
                ]),
                _buildSection('المعلومات العامة', [
                  _buildDetailItem('العنوان', record['address']),
                  _buildDetailItem('العلامات المميزة', record['distinctiveMarks']),
                  _buildDetailItem('وسيلة التواصل', record['contactInfo']),
                ]),
                _buildSection('الحالة الاجتماعية', [
                  _buildDetailItem('الجنس', record['gender']),
                  _buildDetailItem('الحالة الاجتماعية', record['maritalStatus']),
                  if (record['gender'] == 'أنثى' && record['maritalStatus'] == 'متزوجة') ...[
                    _buildDetailItem('اسم الزوج', record['husbandName']),
                  ],
                  if (record['gender'] == 'ذكر' && 
                      (record['maritalStatus'] == 'متزوج' || 
                       record['maritalStatus'] == 'مطلق' || 
                       record['maritalStatus'] == 'أرمل')) ...[
                    _buildDetailItem('عدد الأولاد', record['childrenCount']),
                  ],
                  if (record['gender'] == 'ذكر' && record['maritalStatus'] == 'متزوج') ...[
                    _buildDetailItem('عدد الزوجات', record['wivesCount']),
                    if (record['wives'] != null)
                      for (final wife in jsonDecode(record['wives']))
                        Column(
                          children: [
                            _buildDetailItem('اسم الزوجة', wife['name']),
                            _buildDetailItem('عمر الزوجة', wife['age']),
                            _buildDetailItem('مهنة الزوجة', wife['job']),
                          ],
                        ),
                  ],
                  if (record['children'] != null && record['children'].isNotEmpty) ...[
                    _buildDetailItem('عدد الأطفال', record['childrenCount']),
                    for (final child in jsonDecode(record['children']))
                      Column(
                        children: [
                          _buildDetailItem('اسم الطفل', child['name']),
                          _buildDetailItem('عمر الطفل', child['age']),
                        ],
                      ),
                  ],
                ]),
                _buildSection('المعلومات السكنية', [
                  _buildDetailItem('السكن الحالي', record['currentResidence']),
                  _buildDetailItem('السكن السابق', record['previousResidence']),
                  _buildDetailItem('اسم المنطقة', record['areaName']),
                  _buildDetailItem('اسم الحي', record['neighborhood']),
                  _buildDetailItem('أقرب معلم بارز', record['nearestLandmark']),
                ]),
                _buildSection('المعلومات التعليمية', [
                  _buildDetailItem('المستوى التعليمي', record['educationLevel']),
                  _buildDetailItem('التخصص', record['major']),
                ]),
                _buildSection('المعلومات المهنية', [
                  _buildDetailItem('العمل الحالي', record['currentJob']),
                  _buildDetailItem('العمل السابق', record['previousJob']),
                ]),
                _buildSection('المعلومات المالية', [
                  _buildDetailItem('الوضع المادي', record['financialStatus']),
                ]),
                _buildSection('المعلومات الأخلاقية', [
                  _buildDetailItem('الناحية الأخلاقية', record['ethicalConduct']),
                ]),
                _buildSection('الخدمة العسكرية', [
                  _buildDetailItem('الخدمة الإلزامية', record['militaryService']),
                ]),
                _buildSection('الانتماءات', [
                  _buildDetailItem('الفصائل المنضمة', record['joinedFactions']),
                  _buildDetailItem('موقفه من الثورة', record['revolutionStance']),
                ]),
                _buildSection('علاقات الأقارب', [
                  _buildDetailItem('أقارب مع النظام السابق', record['relativesWithRegime']),
                  _buildDetailItem('صلة القرابة (مع النظام)', record['regimeRelation']),
                  _buildDetailItem('مدى التأثر بهم (مع النظام)', record['regimeInfluence']),
                  _buildDetailItem('أقارب مع تنظيم الدولة', record['relativesWithISIS']),
                  _buildDetailItem('صلة القرابة (مع تنظيم الدولة)', record['isisRelation']),
                  _buildDetailItem('مدى التأثر بهم (مع تنظيم الدولة)', record['isisInfluence']),
                  _buildDetailItem('أقارب تم سجنهم', record['imprisonedRelatives']),
                  _buildDetailItem('سبب السجن', record['imprisonmentReason']),
                  _buildDetailItem('مكان السجن', record['prisonLocation']),
                  _buildDetailItem('صلة القرابة (مع المسجون)', record['prisonRelation']),
                  _buildDetailItem('مدى التأثر بهم (مع المسجون)', record['prisonInfluence']),
                ]),
                _buildSection('المعلومات الدينية والثقافية', [
                  _buildDetailItem('الالتزام الديني', record['religiousCommitment']),
                  _buildDetailItem('التوجه الفكري', record['intellectualOrientation']),
                  _buildDetailItem('مدى التأثر بالمجتمع', record['societyInfluence']),
                  _buildDetailItem('الصفات الشخصية', record['personalTraits']),
                  _buildDetailItem('موجز عن حياته', record['lifeSummary']),
                ]),
                _buildSection('المعلومات الأمنية', [
                  _buildDetailItem('تقرير أمني', record['securityReport']),
                  _buildDetailItem('الأنشطة السابقة', record['pastActivities']),
                  _buildDetailItem('السوابق الجنائية', record['criminalRecord']),
                  _buildDetailItem('علاقاته بشخصيات مؤثرة', record['influentialRelations']),
                  _buildDetailItem('مستوى الثقة به', record['trustLevel']),
                  _buildDetailItem('تحركاته السابقة', record['pastMovements']),
                  _buildDetailItem('حيازة الأسلحة', record['weaponPossession']),
                ]),
                _buildSection('المعلومات الثقافية', [
                  _buildDetailItem('الكتب المقروءة', record['booksRead']),
                  _buildDetailItem('النشاطات الدينية', record['religiousActivities']),
                ]),
                _buildSection('الممتلكات والمعاملات', [
                  _buildDetailItem('الممتلكات والعقارات', record['assets']),
                  _buildDetailItem('المعاملات المالية', record['suspiciousTransactions']),
                ]),
                _buildSection('الشبكات الاجتماعية', [
                  _buildDetailItem('الشبكات الاجتماعية', record['socialNetworks']),
                ]),
                _buildImageSection('الصورة الرئيسية', record['mainImage'], context),
                _buildImageSection('صورة الهوية الأمامية', record['idFront'], context),
                _buildImageSection('صورة الهوية الخلفية', record['idBack'], context),
                _buildSection('الوثائق الإضافية', [
                  if (record['extraDocs'] != null)
                    for (final doc in jsonDecode(record['extraDocs']))
                      _buildImageSection('وثيقة إضافية', doc, context),
                ]),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    onPressed: () {
                      _printRecord(record);
                    },
                    child: const Text('طباعة السجل'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'غير محدد',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _printRecord(Map<String, dynamic> record) {
    // Implement your printing logic here
    // This could be sending to a printer or generating a PDF
    print('Printing Record:');
    record.forEach((key, value) {
      print('$key: $value');
    });
  }

  Widget _buildImageSection(String title, String? imagePath, BuildContext context) {
    if (imagePath == null) return const SizedBox.shrink();
    
    return _buildSection(title, [
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
    ]);
  }
} 