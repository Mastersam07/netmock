import 'package:flutter/material.dart';
import '../controllers/mock_controller.dart';

class ControlPanel extends StatelessWidget {
  final MockController controller;

  const ControlPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Row(
                children: [
                  const Text('Mock Mode'),
                  const SizedBox(width: 8),
                  Switch(
                    value: controller.isMockingEnabled,
                    onChanged: (_) => controller.toggleMocking(),
                  ),
                ],
              ),
              const VerticalDivider(),

              Row(
                children: [
                  const Text('Recording'),
                  const SizedBox(width: 8),
                  Switch(
                    value: controller.isRecording,
                    onChanged: (_) => controller.toggleRecording(),
                  ),
                ],
              ),
              const VerticalDivider(),

              Text('${controller.requests.length} requests'),

              const Spacer(),

              TextButton.icon(
                onPressed: controller.clearAll,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All'),
              ),

              TextButton.icon(
                onPressed: () {
                  // TODO(mastersam07): Implement export
                },
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),

              // Import Button
              TextButton.icon(
                onPressed: () {
                  // TODO(mastersam07): Implement import
                },
                icon: const Icon(Icons.upload),
                label: const Text('Import'),
              ),
            ],
          ),
        );
      },
    );
  }
}
