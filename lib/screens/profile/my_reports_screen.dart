import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/incident_provider.dart';
import '../../models/incident.dart';
import '../../widgets/base_scaffold.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().loadUserIncidents(refresh: true);
    });
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'in_progress':
        return '#1E90FF'; // Blue
      case 'resolved':
        return '#32CD32'; // Green
      case 'rejected':
        return '#FF0000'; // Red
      default:
        return '#808080'; // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      currentIndex: 3,
      onTab: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (i == 1) {
          Navigator.pushReplacementNamed(context, '/learn');
        } else if (i == 2) {
          Navigator.pushReplacementNamed(context, '/report');
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
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Icon(Icons.report_outlined, color: Color(0xFF7C3AED), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'My Reports',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<IncidentProvider>(
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
                            onPressed: () => provider.loadUserIncidents(refresh: true),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.userIncidents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.report_off_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reports yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your reported incidents will appear here',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/report',
                                arguments: {'tab': 1},
                              );
                            },
                            child: Text('Report an Incident'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadUserIncidents(refresh: true),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: provider.userIncidents.length + (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.userIncidents.length) {
                          if (provider.hasMore) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!provider.isLoading) {
                                provider.loadUserIncidents();
                              }
                            });
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        }

                        final incident = provider.userIncidents[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          int.parse(
                                            _getStatusColor(incident.status).substring(1),
                                            radix: 16,
                                          ) | 0xFF000000,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        incident.status.toUpperCase(),
                                        style: TextStyle(
                                          color: Color(
                                            int.parse(
                                              _getStatusColor(incident.status).substring(1),
                                              radix: 16,
                                            ) | 0xFF000000,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      incident.incidentDate.toString().split(' ')[0],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                if (incident.incidentType != null)
                                  Text(
                                    incident.incidentType!.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                SizedBox(height: 8),
                                Text(
                                  incident.description,
                                  style: TextStyle(color: Colors.black87),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (incident.adminNotes != null) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Admin Notes:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          incident.adminNotes!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 