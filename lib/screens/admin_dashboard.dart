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
  String? _lastError; // store last error to show inline

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  /// Fetch employees from backend with verbose error handling and logging
  Future<void> _loadEmployees() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _lastError = null;
    });

    try {
      // build request options: include token from Env if present
      final headers = <String, String>{};

      // Print for debugging
      print('AdminDashboard: GET /users (headers: $headers)');

      final resp = await _apiClient.get(
        '/users',
        options: Options(
          headers: headers,
          // short timeout so failures show quickly
          sendTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
        ),
      );

      print('AdminDashboard: response.statusCode=${resp.statusCode}');
      print('AdminDashboard: response.data=${resp.data}');

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final data = resp.data;
        if (data is List) {
          setState(() => _employees = List<Map<String, dynamic>>.from(data));
        } else if (data is Map && data['data'] is List) {
          setState(
            () => _employees = List<Map<String, dynamic>>.from(data['data']),
          );
        } else {
          // Unexpected response shape
          final err = 'Invalid response format from /users';
          print('AdminDashboard: $err (data type: ${data.runtimeType})');
          setState(() => _lastError = err);
          _showErrorSnackBar(err);
          setState(() => _employees = []);
        }
      } else {
        final err = 'Failed to load employees: ${resp.statusCode}';
        print('AdminDashboard: $err');
        setState(() => _lastError = err);
        _showErrorSnackBar(err);
        setState(() => _employees = []);
      }
    } on DioError catch (dioErr) {
      // Dio-specific errors are very useful: check response, type, message
      final status = dioErr.response?.statusCode;
      final respData = dioErr.response?.data;
      final type = dioErr.type;
      final message = dioErr.message;

      final errMsg = StringBuffer('DioError: $type');
      if (status != null) errMsg.write(' status=$status;');
      errMsg.write(' message=$message;');
      if (respData != null) errMsg.write(' response=${respData.toString()}');

      print('AdminDashboard: ${errMsg.toString()}');

      // Show helpful snackbar (long) and set inline error
      setState(() => _lastError = errMsg.toString());
      _showErrorSnackBar(
        'Error loading employees: ${dioErr.message} (see console)',
      );
      setState(() => _employees = []);
    } catch (e, st) {
      print('AdminDashboard: Unexpected error: $e\n$st');
      setState(() => _lastError = e.toString());
      _showErrorSnackBar('Unexpected error: $e');
      setState(() => _employees = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadEmployees,
        ),
      ),
    );
  }

  // Mock projects - unchanged
  final List<Map<String, dynamic>> _projects = [
    {
      'srNo': '01',
      'projectNo': '454545',
      'projectName': 'Mahindra ABC',
      'status': 'Pending',
      'startDate': '14 Feb 2024',
      'endDate': '14 Feb 2024',
      'duration': '3 days',
    },
    {
      'srNo': '02',
      'projectNo': '987654',
      'projectName': 'Tata Motors XYZ',
      'status': 'Completed',
      'startDate': '10 Jan 2024',
      'endDate': '15 Jan 2024',
      'duration': '5 days',
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
      barrierDismissible: false,
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    enabled: !dialogLoading,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Valid email required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    enabled: !dialogLoading,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.length < 6 ? 'Min 6 characters' : null,
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

                        final headers = <String, String>{};

                        final resp = await _apiClient.post(
                          '/users/register',
                          data: {
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'password': passwordController.text,
                            'role_name': 'Executor',
                          },
                          options: Options(headers: headers),
                        );

                        if (!context.mounted) return;

                        Navigator.pop(dialogContext);

                        if (resp.statusCode == 201 || resp.statusCode == 200) {
                          await _loadEmployees();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Employee added successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          final err =
                              'Failed to create employee: ${resp.statusCode}';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } on DioError catch (dioErr) {
                        if (!context.mounted) return;
                        final msg =
                            'Error creating employee: ${dioErr.message}';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating employee: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted)
                          setDialogState(() => dialogLoading = false);
                      }
                    },
              child: dialogLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _employeesTable() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lastError != null) {
      // show inline error with retry
      return Column(
        children: [
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error loading employees: $_lastError')),
                  TextButton(
                    onPressed: _loadEmployees,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
        ],
        rows: _employees.map((employee) {
          final statusRaw = (employee['status'] ?? '').toString();
          final isActive = statusRaw.toLowerCase() == 'active';
          return DataRow(
            cells: [
              DataCell(Text(employee['name'] ?? '')),
              DataCell(Text(employee['email'] ?? '')),
              DataCell(Text(employee['role']?['role_name'] ?? '')),
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    employee['status'] ?? 'unknown',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
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
            // Top row
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
                  onPressed: _loading ? null : _showAddEmployeeDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Employee'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loading ? null : _loadEmployees,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reload Employees',
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
                    _employeesTable(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Projects
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                          onPressed: () {},
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Sr. No.')),
                          DataColumn(label: Text('Project No.')),
                          DataColumn(label: Text('Project Name')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('End Date')),
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
                                  child: Text(project['status']),
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
