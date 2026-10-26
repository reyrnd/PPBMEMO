import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/validators.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';

class CreateJoinWorkspaceScreen extends StatefulWidget {
  final ValueChanged<WorkspaceCreationData>? onCreate;
  final ValueChanged<String>? onJoin;

  const CreateJoinWorkspaceScreen({
    super.key,
    this.onCreate,
    this.onJoin,
  });

  @override
  State<CreateJoinWorkspaceScreen> createState() =>
      _CreateJoinWorkspaceScreenState();
}

class _CreateJoinWorkspaceScreenState extends State<CreateJoinWorkspaceScreen> {
  final _createFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _joinFormKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _codeDigits = List<String>.filled(6, '');
  final _codeFocusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  final _codeControllers =
      List<TextEditingController>.generate(6, (_) => TextEditingController());

  // Kategori disesuaikan dengan contoh gambar referensi Anda
  static const _categories = [
    'Kuliah',
    'Organisasi',
    'Robotika',
    'Pribadi',
  ];

  var _selectedCategory = 'Robotika'; // Default disesuaikan gambar referensi
  var _pinOnHome = true; // Default disesuaikan gambar referensi
  var _selectedTab = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    for (final focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _createWorkspace() {
    if (!_createFormKey.currentState!.validate()) return;
    widget.onCreate?.call(
      WorkspaceCreationData(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        pinOnHome: _pinOnHome,
      ),
    );
  }

  void _joinWorkspace() {
    if (!_joinFormKey.currentState!.validate()) return;
    widget.onJoin?.call(_codeController.text.toUpperCase());
  }

  void _onCodeChanged(
    int index,
    String value,
    FormFieldState<String> fieldState,
  ) {
    if (value.length > 1) {
      final digits = value.toUpperCase().replaceAll(RegExp(r'\s'), '');
      for (var i = 0; i < 6; i++) {
        _codeDigits[i] = i < digits.length ? digits[i] : '';
        _codeControllers[i].value = TextEditingValue(
          text: _codeDigits[i],
          selection: TextSelection.collapsed(offset: _codeDigits[i].length),
        );
      }
      _updateCode();
      fieldState.didChange(_codeController.text);
      FocusScope.of(context).unfocus();
      setState(() {});
      return;
    }

    final hadValue = _codeDigits[index].isNotEmpty;
    _codeDigits[index] = value.toUpperCase();
    _updateCode();
    fieldState.didChange(_codeController.text);
    if (value.isNotEmpty && index < _codeFocusNodes.length - 1) {
      _codeFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && hadValue && index > 0) {
      _codeFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _updateCode() {
    _codeController.text = _codeDigits.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Custom AppBar bawaan app yang memiliki leading back dan profile action
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Workspace Baru',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.textPrimary,
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildSegmentedControl(),
                  const SizedBox(height: 24),
                  if (_selectedTab == 0)
                    _buildCreateForm()
                  else
                    _buildJoinForm(),
                ],
              ),
            ),
            // Tombol Aksi Utama diletakkan kokoh di bagian bawah
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed:
                    _selectedTab == 0 ? _createWorkspace : _joinWorkspace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedTab == 0 ? 'Buat Workspace' : 'Gabung',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Latar belakang abu-abu terang halus
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: 'Buat Baru',
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _SegmentButton(
            label: 'Gabung',
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Form(
      key: _createFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Nama workspace'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => Validators.required(value, 'Nama workspace'),
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: _inputDecoration('Contoh: Tim Riset IoT & Otomasi'),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Deskripsi'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: _inputDecoration(
              'Dokumentasi arsitektur sensor, modul telemetri LoRa, serta sinkronisasi data cloud berkala...',
            ),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Kategori'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedCategory = category),
                selectedColor: AppTheme.textPrimary,
                backgroundColor: const Color(0xFFF3F4F6),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
                shape: const StadiumBorder(),
                side: BorderSide.none,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Boks pembungkus fitur Sematkan di Beranda sesuai gambar referensi Anda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sematkan di Beranda',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tampilkan langsung di halaman utama aplikasi',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _pinOnHome,
                  activeColor: Colors.white,
                  activeTrackColor: AppTheme.textPrimary,
                  inactiveTrackColor: Colors.black12,
                  onChanged: (value) => setState(() => _pinOnHome = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinForm() {
    return Form(
      key: _joinFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Masukkan kode undangan dari pemilik workspace',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FormField<String>(
            validator: (value) {
              if (value == null || value.length != 6) {
                return 'Masukkan kode undangan 6 karakter.';
              }
              return null;
            },
            builder: (fieldState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(6, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                        child: SizedBox(
                          height: 64,
                          child: TextField(
                            controller: _codeControllers[index],
                            focusNode: _codeFocusNodes[index],
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.text,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                              _UpperCaseTextFormatter(),
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppTheme.textPrimary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (value) =>
                                _onCodeChanged(index, value, fieldState),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (fieldState.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    fieldState.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Kode terdiri dari 6 digit kombinasi huruf dan angka',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor:
          const Color(0xFFF3F4F6), // Background abu-abu halus tanpa border kaku
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.textPrimary, width: 1),
      ),
    );
  }
}

class WorkspaceCreationData {
  final String name;
  final String description;
  final String category;
  final bool pinOnHome;
  const WorkspaceCreationData({
    required this.name,
    required this.description,
    required this.category,
    required this.pinOnHome,
  });
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
        fontSize: 14,
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
