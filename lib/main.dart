import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await criarApp());
}
