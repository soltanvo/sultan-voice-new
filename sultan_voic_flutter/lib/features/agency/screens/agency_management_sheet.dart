import 'package:flutter/material.dart';

class AgencyManagementSheet extends StatefulWidget {
  const AgencyManagementSheet({super.key});

  @override
  State<AgencyManagementSheet> createState() => _AgencyManagementSheetState();
}

class _AgencyManagementSheetState extends State<AgencyManagementSheet> {
  final TextEditingController _memberIdCtrl = TextEditingController();
  final List<String> _supervisors = ['أحمد المشرف (ID: 1042)', 'سارة المشرفة (ID: 1088)'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF140D2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'لوحة الوكالة وتفويض المشرفين',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('المشرفون المفوضون حالياً:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ..._supervisors.map((s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.verified_user, color: Colors.lightGreenAccent, size: 20),
            title: Text(s, style: const TextStyle(fontSize: 13)),
            trailing: const Text('صلاحية تسجيل', style: TextStyle(color: Colors.amber, fontSize: 11)),
          )),
          const Divider(color: Colors.white24, height: 24),
          const Text('تفويض مشرف جديد برقم الـ ID:', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _memberIdCtrl,
                  decoration: InputDecoration(
                    hintText: 'أدخل User ID الخاص بالعضو...',
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onPressed: () {
                  if (_memberIdCtrl.text.isNotEmpty) {
                    setState(() {
                      _supervisors.add('مشرف جديد (ID: ${_memberIdCtrl.text})');
                      _memberIdCtrl.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تفويض المشرف بنجاح ومنحه صلاحية تسجيل الأعضاء!')),
                    );
                  }
                },
                child: const Text('تفويض'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
