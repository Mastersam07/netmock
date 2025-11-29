import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'controllers/mock_controller.dart';
import 'ui/request_list_view.dart';
import 'ui/control_panel.dart';
import 'ui/response_editor.dart';

class NetmockScreen extends StatefulWidget {
  const NetmockScreen({super.key});

  @override
  State<NetmockScreen> createState() => _NetmockScreenState();
}

class _NetmockScreenState extends State<NetmockScreen> {
  final MockController controller = MockController();

  @override
  void initState() {
    super.initState();
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        ControlPanel(controller: controller),
        const Divider(height: 1),
        Expanded(
          child: SplitPane(
            axis: Axis.horizontal,
            initialFractions: const [0.5, 0.5],
            children: [
              RequestListView(controller: controller),
              ResponseEditor(controller: controller),
            ],
          ),
        ),
      ],
    ),
  );
}
