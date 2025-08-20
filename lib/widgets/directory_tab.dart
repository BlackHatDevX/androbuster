import 'package:flutter/material.dart';

class DirectoryTab extends StatefulWidget {
  final TextEditingController urlController;
  final TextEditingController statusCodesController;
  final TextEditingController pageSizesController;
  final TextEditingController wordlistController;
  final TextEditingController threadsController;
  final TextEditingController timeoutController;
  final VoidCallback onPickFile;
  final VoidCallback onStartScan;
  final VoidCallback onStopScan;
  final bool isScanning;
  final double progress;
  final int currentWord;
  final int totalWords;

  const DirectoryTab({
    super.key,
    required this.urlController,
    required this.statusCodesController,
    required this.pageSizesController,
    required this.wordlistController,
    required this.threadsController,
    required this.timeoutController,
    required this.onPickFile,
    required this.onStartScan,
    required this.onStopScan,
    required this.isScanning,
    required this.progress,
    required this.currentWord,
    required this.totalWords,
  });

  @override
  State<DirectoryTab> createState() => _DirectoryTabState();
}

class _DirectoryTabState extends State<DirectoryTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildProgressSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Directory Enumeration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: widget.urlController,
              decoration: const InputDecoration(
                labelText: 'Target URL',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: widget.statusCodesController,
              decoration: const InputDecoration(
                labelText: 'Negative Status Codes',
                hintText: '404,403,500',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.block),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: widget.pageSizesController,
              decoration: const InputDecoration(
                labelText: 'Negative Page Sizes',
                hintText: '0,1234,5678',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.storage),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wordlist',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onPickFile,
                  icon: const Icon(Icons.file_open),
                  label: const Text('Import File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            TextField(
              controller: widget.wordlistController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Wordlist',
                hintText: 'Paste your wordlist here (one word per line) or import from file',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.threadsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Threads',
                      hintText: '10',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: widget.timeoutController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Timeout (ms)',
                      hintText: '5000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isScanning ? null : widget.onStartScan,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isScanning ? widget.onStopScan : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    if (!widget.isScanning && widget.progress == 0.0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${widget.currentWord}/${widget.totalWords}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${(widget.progress * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: widget.progress),
          ],
        ),
      ),
    );
  }
}