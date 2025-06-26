import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/base_scaffold.dart';
import '../../models/incident.dart';
import '../../models/incident_type.dart';
import '../../models/incident_support.dart';
import '../../models/emergency_contact.dart';
import '../../providers/incident_provider.dart';
import '../../providers/emergency_contact_provider.dart';
import '../../utils/permission_handler.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _tab = 1; // 0 = Emergency, 1 = Report
  final _formKey = GlobalKey<FormState>();
  String? _incidentTypeId;
  String? _incidentSupportId;
  String? _description;
  DateTime? _incidentDate;
  String? _isFirstTime = 'yes';
  String? _feelSafeNow = 'yes';
  bool _likeToBeContacted = true;
  String? _evidenceFilePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incidentProvider = context.read<IncidentProvider>();
      final emergencyProvider = context.read<EmergencyContactProvider>();
      
      incidentProvider.loadIncidentTypes();
      incidentProvider.loadIncidentSupports();
      emergencyProvider.loadNearbyContacts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('tab')) {
      setState(() {
        _tab = args['tab'] ?? 1;
      });
    }
  }

  Future<void> _pickEvidence() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _evidenceFilePath = image.path;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select incident date')),
      );
      return;
    }

    try {
      final incident = Incident(
        incidentTypeId: _incidentTypeId!,
        description: _description!,
        incidentDate: _incidentDate!,
        isFirstTime: _isFirstTime,
        feelSafeNow: _feelSafeNow,
        incidentSupportId: _incidentSupportId,
        likeToBeContacted: _likeToBeContacted,
      );

      final provider = context.read<IncidentProvider>();
      await provider.reportIncident(incident, _evidenceFilePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted successfully')),
      );

      Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: $e')),
      );
    }
  }

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
                        backgroundColor: _tab == 0 ? Color(0xFF7C3AED) : Colors.white,
                        foregroundColor: _tab == 0 ? Colors.white : Colors.black,
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
                        backgroundColor: _tab == 1 ? Color(0xFF7C3AED) : Colors.white,
                        foregroundColor: _tab == 1 ? Colors.white : Colors.black,
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
    return Consumer<EmergencyContactProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                ElevatedButton(
                  onPressed: () => provider.loadNearbyContacts(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final contacts = provider.contacts;
        if (contacts.isEmpty) {
          return Center(
            child: Text('No emergency contacts found in your area'),
          );
        }

        return ListView.builder(
      padding: const EdgeInsets.all(20),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return Card(
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
                      contact.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (contact.description != null) ...[
                    SizedBox(height: 6),
                    Text(
                        contact.description!,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    ],
                    if (contact.distanceKm != null) ...[
                      SizedBox(height: 6),
                      Text(
                        '${contact.distanceKm!.toStringAsFixed(1)} km away',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
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
                              final hasPermission = await PermissionUtil.checkAndRequestPhonePermission();
                              if (hasPermission) {
                                await PermissionUtil.makePhoneCall(contact.phoneNumber);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Phone permission denied')),
                                );
                              }
                            },
                            child: Text(
                              'Call: ${contact.phoneNumber}',
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
            );
          },
        );
      },
    );
  }

  Widget _buildReportTab() {
    return Consumer<IncidentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

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
                    style: TextStyle(fontSize: 14),
              ),
            ),
                SizedBox(height: 20),
            DropdownButtonFormField<String>(
                  value: _incidentTypeId,
              decoration: InputDecoration(
                    labelText: 'Type of Violence',
                border: OutlineInputBorder(),
                  ),
                  items: provider.incidentTypes.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _incidentTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select type of violence';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
            TextFormField(
                  maxLines: 5,
              decoration: InputDecoration(
                    labelText: 'Description',
                border: OutlineInputBorder(),
                    hintText: 'Please describe what happened...',
                  ),
                  onSaved: (value) {
                    _description = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                InkWell(
              onTap: () async {
                    final date = await showDatePicker(
                  context: context,
                      initialDate: _incidentDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _incidentDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
              decoration: InputDecoration(
                      labelText: 'Incident Date',
                border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _incidentDate != null
                          ? '${_incidentDate!.day}/${_incidentDate!.month}/${_incidentDate!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _incidentSupportId,
              decoration: InputDecoration(
                    labelText: 'Type of Support Needed',
                border: OutlineInputBorder(),
                  ),
                  items: provider.incidentSupports.map((support) {
                    return DropdownMenuItem(
                      value: support.id,
                      child: Text(support.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _incidentSupportId = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text('Is this the first time this has happened?'),
            Row(
              children: [
                    Radio(
                      value: 'yes',
                      groupValue: _isFirstTime,
                      onChanged: (value) {
                        setState(() {
                          _isFirstTime = value as String?;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio(
                      value: 'no',
                      groupValue: _isFirstTime,
                      onChanged: (value) {
                        setState(() {
                          _isFirstTime = value as String?;
                        });
                      },
                    ),
                    Text('No'),
                    Radio(
                      value: 'not_sure',
                      groupValue: _isFirstTime,
                      onChanged: (value) {
                        setState(() {
                          _isFirstTime = value as String?;
                        });
                      },
                    ),
                    Text('Not Sure'),
                  ],
                ),
                SizedBox(height: 16),
                Text('Do you feel safe now?'),
            Row(
              children: [
                    Radio(
                      value: 'yes',
                      groupValue: _feelSafeNow,
                      onChanged: (value) {
                        setState(() {
                          _feelSafeNow = value as String?;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio(
                      value: 'no',
                      groupValue: _feelSafeNow,
                      onChanged: (value) {
                        setState(() {
                          _feelSafeNow = value as String?;
                        });
                      },
                    ),
                    Text('No'),
                    Radio(
                      value: 'not_sure',
                      groupValue: _feelSafeNow,
                      onChanged: (value) {
                        setState(() {
                          _feelSafeNow = value as String?;
                        });
                      },
                    ),
                    Text('Not Sure'),
                  ],
                ),
                SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                      value: _likeToBeContacted,
                      onChanged: (value) {
                        setState(() {
                          _likeToBeContacted = value ?? false;
                        });
                      },
                ),
                Expanded(
                  child: Text(
                        'Would you like to be contacted by our support team?',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickEvidence,
                  icon: Icon(Icons.attach_file),
                  label: Text(_evidenceFilePath != null ? 'Change Evidence' : 'Attach Evidence'),
                ),
                if (_evidenceFilePath != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Evidence file selected',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
                SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitReport,
                    child: Text(
                      'Submit Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
