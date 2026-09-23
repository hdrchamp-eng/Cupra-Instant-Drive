import 'package:flutter/material.dart';

abstract final class AppRouter {
  static Future<T?> push<T>(BuildContext context, Widget page) =>
      Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
  static void replace(BuildContext context, Widget page) =>
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => page));
}
