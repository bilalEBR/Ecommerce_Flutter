import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'client-state.dart';

Future<bool> checkLoginAndRedirect(BuildContext context, {String? redirect}) async {
  final clientState = Provider.of<ClientState>(context, listen: false);
  if (clientState.token == null || clientState.token!.isEmpty) {
    Navigator.pushNamed(
      context,
      '/login',
      arguments: redirect != null ? {'redirect': redirect} : null,
    );
    return false;
  }
  return true;
}