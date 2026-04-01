import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

/// Global error handler untuk menampilkan error snackbar atau dialog
class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Widget wrapper untuk handle errors dari providers
class AsyncErrorWidget extends ConsumerWidget {
  final String? fallbackMessage;
  final VoidCallback? onRetry;

  const AsyncErrorWidget({super.key, this.fallbackMessage, this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Contoh penggunaan dengan AsyncValue:
    // final asyncValue = ref.watch(someProvider);
    // return asyncValue.when(
    //   loading: () => const Center(child: CircularProgressIndicator()),
    //   error: (err, stack) => AsyncErrorWidget(
    //     fallbackMessage: err.toString(),
    //     onRetry: () => ref.refresh(someProvider),
    //   ),
    //   data: (data) => ...,
    // );

    // Widget ini hanya container untuk contoh. Digunakan di dalam .when()
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            fallbackMessage ?? "Terjadi kesalahan",
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            ),
          ],
        ],
      ),
    );
  }
}
