import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/network_request.dart';
import '../controllers/mock_controller.dart';

class ResponseEditor extends StatefulWidget {
  final MockController controller;

  const ResponseEditor({super.key, required this.controller});

  @override
  State<ResponseEditor> createState() => _ResponseEditorState();
}

class _ResponseEditorState extends State<ResponseEditor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _responseController;
  late TextEditingController _delayController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _responseController = TextEditingController();
    _delayController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _responseController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final request = widget.controller.selectedRequest;

        if (request == null) {
          return const Center(child: Text('Select a request to view details'));
        }

        // Update controller text when selection changes
        _responseController.text = _formatJson(
          request.mockedResponseBody ?? request.responseBody ?? '',
        );

        return Column(
          children: [
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Response'),
                Tab(text: 'Headers'),
                Tab(text: 'Mock Settings'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Response Tab
                  _buildResponseTab(request),

                  // Headers Tab
                  _buildHeadersTab(request),

                  // Mock Settings Tab
                  _buildMockSettingsTab(request),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponseTab(NetworkRequest request) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Response Body'),
              const Spacer(),
              if (widget.controller.isMockingEnabled)
                ElevatedButton(
                  onPressed: () {
                    widget.controller.updateMockedResponse(
                      request,
                      _responseController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mock updated')),
                    );
                  },
                  child: const Text('Save Mock'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _responseController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Response body...',
              ),
              readOnly: !widget.controller.isMockingEnabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadersTab(NetworkRequest request) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Response Headers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...request.responseHeaders.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMockSettingsTab(NetworkRequest request) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Code
          Row(
            children: [
              const Text('Status Code:'),
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: request.statusCode.toString(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Delay
          Row(
            children: [
              const Text('Response Delay (ms):'),
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _delayController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mock Enable for this request
          Row(
            children: [
              Checkbox(
                value: request.isMocked,
                onChanged: (value) {
                  // TODO(mastersam07): Update individual request mock status
                },
              ),
              const Text('Enable mocking for this request'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatJson(String input) {
    try {
      final decoded = json.decode(input);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return input;
    }
  }
}
