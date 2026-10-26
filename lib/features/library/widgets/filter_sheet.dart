// filter_sheet.dart
import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  // State untuk menyimpan pilihan filter
  String _selectedJenis = 'Semua';
  String _selectedUrutan = 'Terbaru';
  bool _termasukArsip = false;

  // Daftar opsi untuk filter jenis
  final List<String> _daftarJenis = [
    'Semua',
    'Teks',
    'Foto',
    'Video',
    'Berkas'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Garis Indikator Atas
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Judul Utama
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 20),

          // 3. SEKSI KATEGORI: JENIS
          const Text(
            'Jenis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daftarJenis.map((jenis) {
              final isSelected = _selectedJenis == jenis;
              return ChoiceChip(
                label: Text(jenis),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() => _selectedJenis = jenis);
                  }
                },
                // Kustomisasi warna sesuai desain (Hitam jika terpilih, Abu jika tidak)
                selectedColor: const Color(0xFF1E1E1E),
                backgroundColor: const Color(0xFFF4F5F7),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
                showCheckmark: false, // Menghilangkan ikon centang default
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 4. SEKSI KATEGORI: URUTKAN
          const Text(
            'Urutan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildRadioOption('Terbaru'),
          _buildRadioOption('Terlama'),
          _buildRadioOption('Judul A-Z'),
          const SizedBox(height: 24),

          // 5. SEKSI KATEGORI: TAMPILKAN (SWITCH)
          const Text(
            'Tampilkan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Termasuk arsip',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Tampilkan catatan yang disembunyikan',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            value: _termasukArsip,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF1E1E1E),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black12,
            onChanged: (bool value) {
              setState(() => _termasukArsip = value);
            },
          ),
          const SizedBox(height: 32),

          // 6. TOMBOL AKSI (RESET & TERAPKAN)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      // Reset semua state ke default
                      setState(() {
                        _selectedJenis = 'Semua';
                        _selectedUrutan = 'Terbaru';
                        _termasukArsip = false;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF4F5F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Kirim data filter kembali ke halaman utama saat ditutup
                      Navigator.pop(context, {
                        'jenis': _selectedJenis,
                        'urutan': _selectedUrutan,
                        'termasukArsip': _termasukArsip,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper untuk membuat item radio button kustom berkulit hitam
  Widget _buildRadioOption(String value) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.black12,
      ),
      child: RadioListTile<String>(
        contentPadding: EdgeInsets.zero,
        title: Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        value: value,
        groupValue: _selectedUrutan,
        activeColor: const Color(0xFF1E1E1E),
        onChanged: (String? val) {
          if (val != null) {
            setState(() => _selectedUrutan = val);
          }
        },
      ),
    );
  }
}
