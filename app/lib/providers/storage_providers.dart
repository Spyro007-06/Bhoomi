import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/demo/demo_store.dart';
import '../core/storage/secure_storage.dart';
import '../core/storage/token_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return const SecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenStorage(storage: secureStorage);
});

/// Persistent state backing the local mock backend. It is never consulted by
/// production repositories.
final demoStoreProvider = Provider<DemoStore>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DemoStore(storage: secureStorage);
});
