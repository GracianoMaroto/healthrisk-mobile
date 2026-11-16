import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class CofrePin {
  Future<void> salvar(String pin);
  Future<bool> temPin();
  Future<bool> conferir(String pin);
  Future<void> apagar();
}

String hashPin(String pin) => sha256.convert(utf8.encode('healthrisk|$pin')).toString();

class CofreMemoria implements CofrePin {
  String? _hash;

  @override
  Future<void> salvar(String pin) async => _hash = hashPin(pin);

  @override
  Future<bool> temPin() async => _hash != null;

  @override
  Future<bool> conferir(String pin) async => _hash != null && _hash == hashPin(pin);

  @override
  Future<void> apagar() async => _hash = null;
}

class CofreSeguro implements CofrePin {
  CofreSeguro([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _chave = 'healthrisk_pin_hash';

  @override
  Future<void> salvar(String pin) async => _storage.write(key: _chave, value: hashPin(pin));

  @override
  Future<bool> temPin() async => (await _storage.read(key: _chave)) != null;

  @override
  Future<bool> conferir(String pin) async {
    final salvo = await _storage.read(key: _chave);
    return salvo != null && salvo == hashPin(pin);
  }

  @override
  Future<void> apagar() async => _storage.delete(key: _chave);
}
