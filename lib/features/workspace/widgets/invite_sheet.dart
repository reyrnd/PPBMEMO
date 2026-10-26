import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/validators.dart';
import 'package:memospace/core/widgets/app_bottom_sheet.dart';
import 'package:memospace/features/workspace/models/workspace_member.dart';

Future<void> showInviteSheet({
  required BuildContext context,
  required String inviteCode,
  required List<WorkspaceMember> members,
  required Future<void> Function(String email) onSendInvite,
  required Future<void> Function(String inviteCode) onShareInvite,
}) {
  return showAppBottomSheet<void>(
    context: context,
    title: 'Undang anggota',
    heightFactor:
        0.88, // Ditambahkan sedikit ruang tinggi agar daftar anggota muat lebih banyak
    child: InviteSheet(
      inviteCode: inviteCode,
      members: members,
      onSendInvite: onSendInvite,
      onShareInvite: onShareInvite,
    ),
  );
}

class InviteSheet extends StatefulWidget {
  final String inviteCode;
  final List<WorkspaceMember> members;
  final Future<void> Function(String email) onSendInvite;
  final Future<void> Function(String inviteCode) onShareInvite;

  const InviteSheet({
    super.key,
    required this.inviteCode,
    required this.members,
    required this.onSendInvite,
    required this.onShareInvite,
  });

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _copyInviteCode() async {
    await Clipboard.setData(ClipboardData(text: widget.inviteCode));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode undangan disalin.')),
    );
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate() || _isSending) return;

    setState(() => _isSending = true);
    try {
      await widget.onSendInvite(_emailController.text.trim());
      if (!mounted) return;
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undangan berhasil dikirim.')),
      );
    } catch (_) {
      // Handle error jika diperlukan
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _shareInvite() async {
    await widget.onShareInvite(widget.inviteCode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-deskripsi atas sesuai gambar referensi Anda
        const Text(
          'Kolaborasi langsung dalam workspace proyek',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // --- 1. SEKSI KODE UNDANGAN (CARD BOX) ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.link,
                                size: 16, color: AppTheme.textSecondary),
                            SizedBox(width: 6),
                            Text(
                              'KODE UNDANGAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black45,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(Icons.circle,
                                size: 6, color: Color(0xFF16A34A)),
                            SizedBox(width: 4),
                            Text(
                              'Berlaku',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(
                            widget.inviteCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Text(
                            'Exp. 7 hari',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tombol Aksi Split (Salin & Bagikan)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyInviteCode,
                            icon: const Icon(Icons.copy,
                                size: 14, color: AppTheme.textPrimary),
                            label: const Text(
                              'Salin',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              minimumSize: const Size(0, 44),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareInvite,
                            icon: const Icon(Icons.share_outlined,
                                size: 14, color: Colors.white),
                            label: const Text(
                              'Bagikan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.textPrimary,
                              minimumSize: const Size(0, 44),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. SEKSI UNDANG VIA EMAIL ---
              const Text(
                'Undang via Email Mahasiswa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.send,
                  validator: Validators.email,
                  onFieldSubmitted: (_) => _sendInvite(),
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'nama@mahasiswa.ac.id',
                    hintStyle:
                        const TextStyle(color: Colors.black38, fontSize: 14),
                    prefixIcon: const Icon(Icons.email_outlined,
                        size: 18, color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                      borderSide: const BorderSide(
                          color: AppTheme.textPrimary, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isSending ? null : _sendInvite,
                icon: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow_outlined, size: 16),
                label: const Text(
                  'Kirim undangan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 28),
// --- 3. DAFTAR ANGGOTA WORKSPACE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Anggota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.members.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Batas tim: 10',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
// Looping komponen baris anggota yang telah ditingkatkan detailnya
              ...widget.members.map((member) {
                final isOwner = member.role == MemberRole.owner;
// Simulasi pembuatan teks email dari data objek anggota jika model memiliki properti email
// (Ganti member.name.toLowerCase().replaceAll(' ', '.') dengan field dinamis jika tersedia)
                final emailSimulated =
                    '${member.name.toLowerCase().replaceAll(' ', '.')}@mahasiswa.ac.id';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.textPrimary,
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              emailSimulated,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(role: member.role),
                      if (!isOwner) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.more_vert,
                              size: 18, color: AppTheme.textSecondary),
                          onPressed: () {
                            // Fungsi aksi pengelolaan akses anggota tim
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final MemberRole role;
  const _RoleChip({required this.role});
  @override
  Widget build(BuildContext context) {
    final label = role == MemberRole.owner ? 'Pemilik' : 'Anggota';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}