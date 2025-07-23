import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/server_health_provider.dart';
import '../providers/auth_provider.dart';
import '../views/connections/no_internet.dart';
import '../views/connections/server_down.dart';


class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  @override
  void initState() {
    super.initState();
    // Check connectivity and server health immediately when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectivity = Provider.of<ConnectivityProvider>(context, listen: false);
      // final serverHealth = Provider.of<ServerHealthProvider>(context, listen: false);
      final auth = Provider.of<UserAuthProvider>(context, listen: false);

      // Check internet connectivity first
      connectivity.checkConnection();

      // Only check server health if user is logged in
      if (auth.isLoggedIn) {
        // serverHealth.checkServerHealth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ConnectivityProvider, ServerHealthProvider, UserAuthProvider>(
      builder: (context, connectivity, serverHealth, auth, _) {
        debugPrint('Connectivity: ${connectivity.isConnected}, Server: ${serverHealth.isServerHealthy}, Auth: ${auth.isLoggedIn}');

        // Only show screens if user is logged in
        if (auth.isLoggedIn) {
          // Priority 1: No internet connection
          if (!connectivity.isConnected) {
            return const NoInternetScreen();
          }

          // Priority 2: Server is down (only check if connected to internet)
          // if (!serverHealth.isServerHealthy) {
          //   return const ServerDownScreen();
          // }
        }

        // If everything is fine or user is not logged in, show the main app
        return widget.child;
      },
    );
  }
}