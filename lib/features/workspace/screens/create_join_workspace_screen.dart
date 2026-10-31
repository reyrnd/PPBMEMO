import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../cubit/workspace_cubit.dart';
import 'workspace_list_screen.dart';

class CreateJoinWorkspaceScreen extends StatefulWidget {
  const CreateJoinWorkspaceScreen({super.key});

  @override
  State<CreateJoinWorkspaceScreen> createState() =>
      _CreateJoinWorkspaceScreenState();
}

class _CreateJoinWorkspaceScreenState extends State<CreateJoinWorkspaceScreen> {
  String _activeTab = 'Create'; // Pilihan: 'Create' atau 'Join'

  // Controller untuk Form Create
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Controller untuk Form Join
  final TextEditingController _codeController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createWorkspace() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await context.read<WorkspaceCubit>().create(
            name,
            _descController.text.trim(),
            'proyek',
            false,
          );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WorkspaceListScreen()),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _joinWorkspace() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await context.read<WorkspaceCubit>().join(code);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WorkspaceListScreen()),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Segmented Control Tab (Create vs Join)
              _buildSegmentedTab(),
              const SizedBox(height: 24),

              // 2. Conditional Form Content
              if (_activeTab == 'Create')
                _buildCreateForm()
              else
                _buildJoinForm(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-Widgets / Component Slicing
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.canvas,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _activeTab == 'Create' ? 'Buat ruang kerja' : 'Gabung ruang kerja',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
      ),
    );
  }

  Widget _buildSegmentedTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.soft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ['Create', 'Join'].map((tabName) {
          final isSelected = _activeTab == tabName;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _activeTab = tabName;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? const [AppTheme.shadowSoft] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabName == 'Create' ? 'Buat ruang' : 'Gabung ruang',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppTheme.ink : AppTheme.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Nama Workspace
        _buildInputField(
          label: 'Nama ruang kerja',
          hint: 'e.g. Product Launch',
          controller: _nameController,
        ),
        const SizedBox(height: 12),

        // Input Deskripsi Workspace
        _buildInputField(
          label: 'Deskripsi',
          hint: 'What will your team work on?',
          controller: _descController,
        ),
        const SizedBox(height: 16),

        // Info Box Penanda Owner (Mint Box Style)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.mint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.people_alt_rounded,
                    color: AppTheme.olive, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Kamu menjadi pemilik',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink)),
                    SizedBox(height: 2),
                    Text('Kode undangan dibuat otomatis.',
                        style: TextStyle(fontSize: 9, color: AppTheme.muted)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tombol Submit Akses Gelap
        if (_errorMessage != null) _buildErrorMessage(),
        _buildSubmitButton(
          label: 'Buat ruang kerja',
          onPressed: _isSubmitting ? null : _createWorkspace,
          isSubmitting: _isSubmitting,
        ),
      ],
    );
  }

  Widget _buildJoinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Kode Undangan
        _buildInputField(
          label: 'Kode undangan',
          hint: 'DESIGN-42',
          controller: _codeController,
          capitalize: true,
        ),
        const SizedBox(height: 12),

        const Center(
          child: Text(
            'Masukkan kode yang dibagikan oleh pemilik ruang kerja.',
            style: TextStyle(
                fontSize: 10,
                color: AppTheme.faint,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 24),

        // Tombol Submit Akses Gelap
        if (_errorMessage != null) _buildErrorMessage(),
        _buildSubmitButton(
          label: 'Gabung ruang kerja',
          onPressed: _isSubmitting ? null : _joinWorkspace,
          isSubmitting: _isSubmitting,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool capitalize = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.whiteBackgroundField,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.faint,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            textCapitalization: capitalize
                ? TextCapitalization.characters
                : TextCapitalization.none,
            style: TextStyle(
              fontSize: capitalize ? 16 : 13,
              fontWeight: capitalize ? FontWeight.w800 : FontWeight.w600,
              color: AppTheme.ink,
              letterSpacing: capitalize ? 1.5 : 0,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: AppTheme.faint, letterSpacing: capitalize ? 0 : 0),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.dangerSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          color: AppTheme.danger,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isSubmitting,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: isSubmitting
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
