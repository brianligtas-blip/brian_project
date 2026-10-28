
import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

enum ReportUiState { idle, loading, success, empty, error }

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReportUiState _uiState = ReportUiState.idle;
  bool _simulateFailure = true;
  bool _viewingList = false;
  final List<String> _reports = [];

  static const purple = Color(0xFF7052A0);
  static const background = Color(0xFFFFF7FF);

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value, String name, {int min = 3}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return '$name is required';
    if (text.length < min) {
      return '$name must be at least $min characters';
    }

    return null;
  }

  Future<void> _submitReport() async {
    if (_uiState == ReportUiState.loading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _uiState = ReportUiState.loading);

    try {
      await Future<void>.delayed(const Duration(seconds: 3));

      if (_simulateFailure) {
        throw Exception('Simulated failure');
      }

      if (!mounted) return;

      _reports.add(_titleController.text.trim());
      setState(() => _uiState = ReportUiState.success);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  void _newReport() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();

    setState(() {
      _viewingList = false;
      _uiState = ReportUiState.idle;
    });
  }

  void _backToForm() {
    setState(() {
      _viewingList = false;
      _uiState = ReportUiState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewingList
        ? (_reports.isEmpty
            ? ReportUiState.empty
            : ReportUiState.success)
        : _uiState;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Report Form'),
        backgroundColor: background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _viewingList
                  ? _buildList(state)
                  : _buildForState(state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForState(ReportUiState state) {
    switch (state) {
      case ReportUiState.idle:
      case ReportUiState.loading:
        return _buildForm(state == ReportUiState.loading);

      case ReportUiState.success:
        return _statusCard(
          icon: Icons.check_circle,
          color: Colors.green,
          title: 'Report submitted',
          message:
              'Your report was accepted (simulated, not saved to a database).',
          actions: [
            AppButton(
              label: 'Submit another report',
              onPressed: _newReport,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'View Reports',
              onPressed: () {
                setState(() => _viewingList = true);
              },
            ),
          ],
        );

      case ReportUiState.empty:
        return _statusCard(
          icon: Icons.inbox_outlined,
          color: Colors.grey,
          title: 'No reports yet',
          message: 'You have not submitted any reports.',
          actions: [
            AppButton(
              label: 'Create a report',
              onPressed: _newReport,
            ),
          ],
        );

      case ReportUiState.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildForm(false),
            const SizedBox(height: 24),
            const Icon(
              Icons.error_outline,
              size: 42,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            const Text(
              'Submission failed (simulated). Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton(
                onPressed: _submitReport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: purple,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildForm(bool loading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _titleController,
            label: 'Report Title',
            validator: (v) => _required(v, 'Title'),
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: _locationController,
            label: 'Location',
            validator: (v) => _required(v, 'Location'),
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            maxLines: 4,
            validator: (v) => _required(v, 'Description', min: 10),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Simulate failure (demo only)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Switch(
                value: _simulateFailure,
                activeTrackColor: purple,
                onChanged: loading
                    ? null
                    : (value) {
                        setState(() {
                          _simulateFailure = value;
                        });
                      },
              ),
            ],
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Submitting report (simulated)...',
                textAlign: TextAlign.center,
              ),
            ),

          AppButton(
            label: 'Submit Report',
            isLoading: loading,
            onPressed: _submitReport,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: loading
                  ? null
                  : () {
                      setState(() => _viewingList = true);
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: purple,
                backgroundColor: const Color(0xFFF5EFF8),
                shape: const StadiumBorder(),
                side: BorderSide.none,
              ),
              child: const Text('View Reports'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ReportUiState state) {
    if (state == ReportUiState.empty) {
      return _buildForState(ReportUiState.empty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'My Reports',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final report in _reports)
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(report),
          ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Create a report',
          onPressed: _newReport,
        ),
        TextButton(
          onPressed: _backToForm,
          child: const Text('Back to form'),
        ),
      ],
    );
  }

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Icon(icon, size: 64, color: color),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...actions,
      ],
    );
  }
}
