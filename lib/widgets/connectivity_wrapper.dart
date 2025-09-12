import 'package:flutter/material.dart';
import 'package:seify_app/pages/no_internet_page.dart';
import 'package:seify_app/services/connectivity_service.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();
    return StreamBuilder(
      stream: connectivityService.connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && !snapshot.data!) {
          return const NoInternetPage();
        }

        return child;
      },
    );
  }
}
