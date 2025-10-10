import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/env.dart';
import '../data/api_client.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _searchController = TextEditingController();
  final _apiClient = ApiClient().dio;
  bool _loading = false;
  List<Map<String, dynamic>> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;

    try {
      setState(() => _loading = true);

      final resp = await _apiClient.get('/users');

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final data = resp.data;
        if (data is List) {
          setState(() {
            _employees = List<Map<String, dynamic>>.from(data);
          });
        } else if (data is Map && data['data'] is List) {
          setState(() {
            _employees = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load employees: ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;

      print('Error loading employees: $e'); // Debug log

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error loading employees. Please check your connection and try again.',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadEmployees,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Mock data - replace with actual API calls
  final List<Map<String, dynamic>> _projects = [
    {
      'srNo': '01',
      'projectNo': '454545',
      'projectName': 'Mahindra abc',
      'status': 'Pending',
      'startDate': '14 Feb 2024',
      'endDate': '14 Feb 2024',
      'duration': '3 days',
    },
    {
      'srNo': '01',
      'projectNo': '454545',
      'projectName': 'Mahindra abc',
      'status': 'Completed',
      'startDate': '14 Feb 2024',
      'endDate': '14 Feb 2024',
      'duration': '3 days',
    },
  ];

  void _showAddEmployeeDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool dialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Employee'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    enabled: !dialogLoading,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    enabled: !dialogLoading,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Valid email required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    enabled: !dialogLoading,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.length < 6 ? 'Min 6 chars' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: dialogLoading
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: dialogLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      try {
                        setDialogState(() => dialogLoading = true);

                        final resp = await _apiClient.post(
                          '/users/register',
                          data: {
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'password': passwordController.text,
                            'role_name': 'Executor',
                          },
                        );

                        if (!context.mounted) return;

                        // Close dialog first
                        Navigator.pop(dialogContext);

                        if (resp.statusCode == 201) {
                          // Then refresh and show success
                          _loadEmployees();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Employee created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to create employee: ${resp.statusCode}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating employee: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setDialogState(() => dialogLoading = false);
                        }
                      }
                    },
              child: dialogLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top stats row
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _employees.length.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('All Employees'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '25',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('Overdue'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showAddEmployeeDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add employee'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Employees section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Employees',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: _employees.map((employee) {
                                final isActive = employee['status'] == 'active';
                                return DataRow(
                                  cells: [
                                    DataCell(Text(employee['name'] ?? '')),
                                    DataCell(Text(employee['email'] ?? '')),
                                    DataCell(
                                      Text(
                                        employee['role']?['role_name'] ?? '',
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          employee['status'] ?? 'unknown',
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Projects section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search bar and download button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for project',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement download functionality
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Projects table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Sr. No.')),
                          DataColumn(label: Text('Project No.')),
                          DataColumn(label: Text('Project name')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Start date')),
                          DataColumn(label: Text('End date')),
                          DataColumn(label: Text('Duration')),
                        ],
                        rows: _projects.map((project) {
                          final isCompleted = project['status'] == 'Completed';
                          return DataRow(
                            cells: [
                              DataCell(Text(project['srNo'])),
                              DataCell(Text(project['projectNo'])),
                              DataCell(Text(project['projectName'])),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.yellow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    project['status'],
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(project['startDate'])),
                              DataCell(Text(project['endDate'])),
                              DataCell(Text(project['duration'])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
