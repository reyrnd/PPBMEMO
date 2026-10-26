Konteks: MemoSpace, aplikasi notes kolaboratif Flutter untuk tim mahasiswa.
Import memakai package:memospace/... . Semua teks UI berbahasa Indonesia.
Aturan:

- Struktur lib/features/<fitur>/{models,screens,widgets,data,cubit}. Widget lintas fitur di lib/core/widgets.
- Warna, radius, spacing memakai AppTheme (lib/core/app_theme.dart), jangan hardcode warna baru.
- Kartu radius 16, border 1px #E0E0E0, tanpa shadow. Search bar, chip, tombol radius 30. Bottom sheet radius atas 24 dengan drag handle.
- Waktu di model bertipe DateTime, ditampilkan lewat DateFormatter.getRelativeTimeText.
- State management: flutter_bloc (Cubit). Model immutable: const constructor dan copyWith.
- Data masih dummy. Jangan menambah package tanpa saya sebut.
