import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/base_scaffold.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _tab = 1; // 0 = Emergency, 1 = Report
  final _formKey = GlobalKey<FormState>();
  String? _violenceType;
  String? _supportType;
  String? _incidentDesc;
  String? _incidentDate;
  String? _incidentLocation;
  String? _who;
  String? _firstTime = 'Yes';
  String? _safe = 'Yes';
  String? _contact = 'Yes';
  bool _confidential = false;

  final List<String> violenceTypes = [
    'Physical',
    'Emotional',
    'Sexual',
    'Economic',
    'Other',
  ];
  final List<String> supportTypes = [
    'Medical',
    'Legal',
    'Counseling',
    'Shelter',
    'Other',
  ];

  // Mock API data for contacts
  final List<Map<String, String>> contacts = [
    {
      'title': 'Police station',
      'desc':
          'Local police station providing 24/7 assistance for emergencies, crime reporting and public safety concerns.',
      'phone': '0782200300',
    },
    {
      'title': 'Local Hospital',
      'desc':
          'Nearest hospital offering 24/7 medical services, emergency care and health consultations.',
      'phone': '0782200300',
    },
    {
      'title': 'LP Cyber Helpline',
      'desc':
          'Call us for guidance on what steps to take after experiencing online violence, Psychological support and counseling from mental health professionals and Legal assistance.',
      'phone': '0752200305',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      currentIndex: 2,
      onTab: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (i == 1) {
          Navigator.pushReplacementNamed(context, '/learn');
        } else if (i == 2) {
          // Already on report
        } else if (i == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Color(0xFF7C3AED), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Report',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _tab == 0
                            ? Color(0xFF7C3AED)
                            : Colors.white,
                        foregroundColor: _tab == 0
                            ? Colors.white
                            : Colors.black,
                        side: BorderSide(color: Color(0xFF7C3AED)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => setState(() => _tab = 0),
                      child: Text('Emergency Contacts'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _tab == 1
                            ? Color(0xFF7C3AED)
                            : Colors.white,
                        foregroundColor: _tab == 1
                            ? Colors.white
                            : Colors.black,
                        side: BorderSide(color: Color(0xFF7C3AED)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => setState(() => _tab = 1),
                      child: Text('Report Incident'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tab == 0 ? _buildEmergencyTab() : _buildReportTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: contacts
          .map(
            (c) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 18),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      c['desc']!,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              final phone = c['phone']!;
                              final uri = Uri.parse('tel:$phone');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            child: Text(
                              'Call: ${c['phone']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.open_in_new, color: Color(0xFF7C3AED)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Use this form to report an incident of gender-based violence. Your report will be treated confidentially and sent to our support team.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            SizedBox(height: 18),
            Text('Type of Violence Experienced'),
            SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _violenceType,
              items: violenceTypes
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _violenceType = v),
              decoration: InputDecoration(
                hintText: 'Select all that relate...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            SizedBox(height: 18),
            Text('Describe the incident'),
            SizedBox(height: 6),
            TextFormField(
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Please provide details about what happened...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (v) => _incidentDesc = v,
            ),
            SizedBox(height: 18),
            Text('Date and Time of Incident ( If known)'),
            SizedBox(height: 6),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: _incidentDate),
              decoration: InputDecoration(
                hintText: 'DD/MM/YYYY',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(
                    () => _incidentDate =
                        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}",
                  );
                }
              },
            ),
            SizedBox(height: 18),
            Text('Where did it happen (Location)'),
            SizedBox(height: 6),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (v) => _incidentLocation = v,
            ),
            SizedBox(height: 18),
            Text('Who did it? (stranger, partner, teacher,...)'),
            SizedBox(height: 6),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (v) => _who = v,
            ),
            SizedBox(height: 18),
            Text('Was this the first time?'),
            Row(
              children: [
                _radio(
                  'Yes',
                  _firstTime,
                  (v) => setState(() => _firstTime = v),
                ),
                _radio('No', _firstTime, (v) => setState(() => _firstTime = v)),
                _radio(
                  'Not Sure',
                  _firstTime,
                  (v) => setState(() => _firstTime = v),
                ),
              ],
            ),
            SizedBox(height: 18),
            Text('Do you feel safe right now?'),
            Row(
              children: [
                _radio('Yes', _safe, (v) => setState(() => _safe = v)),
                _radio('No', _safe, (v) => setState(() => _safe = v)),
                _radio('Not Sure', _safe, (v) => setState(() => _safe = v)),
              ],
            ),
            SizedBox(height: 18),
            Text('What Support do you require?'),
            SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _supportType,
              items: supportTypes
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _supportType = v),
              decoration: InputDecoration(
                hintText: 'Select all that relate...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            SizedBox(height: 18),
            Text('Would you like us to contact you?'),
            Row(
              children: [
                _radio('Yes', _contact, (v) => setState(() => _contact = v)),
                _radio('No', _contact, (v) => setState(() => _contact = v)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _confidential,
                  onChanged: (v) => setState(() => _confidential = v ?? false),
                ),
                Expanded(
                  child: Text(
                    'I understand that this report will be handled confidentially.',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radio(String label, String? group, void Function(String?) onChanged) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: group,
          onChanged: onChanged,
          activeColor: Color(0xFF7C3AED),
        ),
        Text(label),
        SizedBox(width: 8),
      ],
    );
  }
}
