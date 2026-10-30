import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/memo_cubit.dart';
import '../models/memo.dart';

bool isMemoAuthor(Memo m) =>
    m.authorId == FirebaseAuth.instance.currentUser?.uid;

/// Mengembalikan true kalau memo benar-benar dihapus.
Future<bool> confirmDeleteMemo(BuildContext context, Memo memo) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus memo?'),
      content: Text('"${memo.title.isEmpty ? 'Tanpa judul' : memo.title}" '
          'akan dihapus untuk semua anggota. Tindakan ini tidak bisa dibatalkan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;
  await context.read<MemoCubit>().delete(memo.workspaceId, memo.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Memo dihapus')));
  }
  return true;
}
