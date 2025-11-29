import 'package:flutter/material.dart';
import '../controllers/mock_controller.dart';

class RequestListView extends StatelessWidget {
  final MockController controller;

  const RequestListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.requests.isEmpty) {
          return const Center(
            child: Text('No requests recorded yet'),
          );
        }

        return ListView.builder(
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final request = controller.requests[index];
            final isSelected = request == controller.selectedRequest;
            
            return ListTile(
              selected: isSelected,
              leading: _buildMethodChip(request.method),
              title: Text(
                request.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${request.statusCode} • ${request.duration.inMilliseconds}ms',
              ),
              trailing: request.isMocked 
                ? const Chip(
                    label: Text('MOCKED', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.orange,
                  )
                : null,
              onTap: () => controller.selectRequest(request),
            );
          },
        );
      },
    );
  }

  Widget _buildMethodChip(String method) {
    Color color;
    switch (method) {
      case 'GET':
        color = Colors.green;
        break;
      case 'POST':
        color = Colors.blue;
        break;
      case 'PUT':
        color = Colors.orange;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        method,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}