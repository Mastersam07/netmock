import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'src/netmock_screen.dart';

void main() => runApp(const NetmockDevToolsExtension());

class NetmockDevToolsExtension extends StatelessWidget {
  const NetmockDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) =>
      DevToolsExtension(child: const NetmockScreen());
}
