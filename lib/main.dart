import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'permission/permission_handler.dart';
import 'Gallary/screen/home_screen.dart';
import 'package:flutter/scheduler.dart';

late Size mq;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const PermissionGate(),
    );
  }
}

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => PermissionGateState();
}

class PermissionGateState extends State<PermissionGate> {
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    // Defer permission check until first frame so context is ready.
    SchedulerBinding.instance.addPostFrameCallback((_) => checkPermission());
  }

  Future<void> checkPermission() async {
    setState(() {
      loading = true;
      error = null;
    });
    final granted = await PermissionHandler.requestPhotoPermission();
    if (granted) {
      if (!mounted) return;
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => const GallaryPage()),
      // );
      Get.off(() => const GallaryPage());
      return;
    }
    setState(() {
      loading = false;
      error = 'Permission denied. Please grant gallery access.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error ?? 'Permission required to continue'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: checkPermission,
                    child: const Text('Retry / Open Settings'),
                  ),
                ],
              ),
      ),
    );
  }
}
