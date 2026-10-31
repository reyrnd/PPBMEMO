import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart'; // Impor package Firebase Core wajib
import 'dart:async';
import 'firebase_options.dart'; // Impor opsi konfigurasi otomatis dari flutterfire
import 'core/app_theme.dart';
import 'features/memo/cubit/memo_cubit.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/workspace/cubit/workspace_cubit.dart';
import 'features/workspace/data/workspace_repository.dart';
import 'features/workspace/models/workspace.dart';

void main() async {
  // 1. Wajib memastikan inisialisasi binding Flutter selesai seutuhnya
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Wajib menginisialisasi Firebase sebelum menjalankan runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MemoSpaceApp());
}

class MemoSpaceApp extends StatefulWidget {
  const MemoSpaceApp({super.key});

  @override
  State<MemoSpaceApp> createState() => _MemoSpaceAppState();
}

class _MemoSpaceAppState extends State<MemoSpaceApp> {
  late final MemoCubit _memoCubit;
  late final WorkspaceCubit _workspaceCubit;
  late final StreamSubscription<List<Workspace>> _workspaceSubscription;

  @override
  void initState() {
    super.initState();
    // Inisialisasi instansi objek Cubit secara aman
    _memoCubit = MemoCubit();
    _workspaceCubit = WorkspaceCubit(WorkspaceRepository());

    _workspaceSubscription = _workspaceCubit.stream.listen((workspaces) {
      _memoCubit
          .streamMemos(workspaces.map((workspace) => workspace.id).toList());
    });
  }

  @override
  void dispose() {
    _workspaceSubscription.cancel();
    _memoCubit.close();
    _workspaceCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MemoCubit>.value(value: _memoCubit),
        BlocProvider<WorkspaceCubit>.value(value: _workspaceCubit),
      ],
      child: MaterialApp(
        title: 'MemoSpace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
