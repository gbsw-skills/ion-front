import 'package:flutter/material.dart';
import 'package:ion/store.dart';

sizew(context) => MediaQuery.of(context).size.width;
sizeh(context) => MediaQuery.of(context).size.height;

String initials(String name) {
  if (name.isEmpty) return '?';
  final trimmed = name.trim();
  if (trimmed.length >= 2) return trimmed.substring(0, 2);
  return trimmed;
}
