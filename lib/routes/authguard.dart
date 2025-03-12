import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class AuthGuard extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onProtectedAction;

  const AuthGuard({super.key, this.child, this.onProtectedAction});

  @override
  _AuthGuardState createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final box = GetStorage();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    isLoggedIn = box.hasData('jwt_token'); // Initial check

    // Listen for token changes
    box.listen(() {
      setState(() {
        isLoggedIn = box.hasData('jwt_token');
      });
    });
  }

  void _handleAction() {
    if (isLoggedIn) {
      widget.onProtectedAction?.call();
    } else {
      _showNotAllowedDialog();
    }
  }

  void _showNotAllowedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Access Denied"),
        content: const Text("You are not allowed to use this function. Please log in."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return isLoggedIn
          ? widget.child!
          : Scaffold(
        body: Center(
          child: AlertDialog(
            title: const Text("Access Denied"),
            content: const Text("You are not allowed to access this page."),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      );
    } else if (widget.onProtectedAction != null) {
      return GestureDetector(
        onTap: _handleAction,
        child: Container(),
      );
    }

    return Container();
  }
}
