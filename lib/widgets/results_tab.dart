import 'package:flutter/material.dart';
import '../models/scan_result.dart';

class ResultsTab extends StatelessWidget {
  final List<ScanResult> directoryResults;
  final List<ScanResult> subdomainResults;
  final VoidCallback onCopyResults;
  final VoidCallback onClearResults;

  const ResultsTab({
    super.key,
    required this.directoryResults,
    required this.subdomainResults,
    required this.onCopyResults,
    required this.onClearResults,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Scan Results',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dir: ${directoryResults.length} | Sub: ${subdomainResults.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: onCopyResults,
                  icon: const Icon(Icons.copy),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onClearResults,
                  icon: const Icon(Icons.clear_all),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    if (directoryResults.isEmpty && subdomainResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Start a scan from Dir Mode or Subdomain Mode to see results here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _getTotalResultCount(),
      itemBuilder: (context, index) {
        return _buildResultItem(index);
      },
    );
  }

  int _getTotalResultCount() {
    int total = 0;
    if (directoryResults.isNotEmpty) total += directoryResults.length + 1; 
    if (subdomainResults.isNotEmpty) total += subdomainResults.length + 1; 
    return total;
  }

  Widget _buildResultItem(int index) {
    int currentIndex = 0;

    if (directoryResults.isNotEmpty) {
      if (index == currentIndex) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Directory Scan Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        );
      }
      currentIndex++;

      if (index < currentIndex + directoryResults.length) {
        final result = directoryResults[index - currentIndex];
        return _buildResultCard(result);
      }
      currentIndex += directoryResults.length;
    }

    if (subdomainResults.isNotEmpty) {
      if (index == currentIndex) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Subdomain Scan Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        );
      }
      currentIndex++;

      if (index < currentIndex + subdomainResults.length) {
        final result = subdomainResults[index - currentIndex];
        return _buildResultCard(result);
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildResultCard(ScanResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: ListTile(
        title: Text(
          result.path,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(result.url),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(result.statusCode),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${result.statusCode}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${result.size}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 300 && statusCode < 400) return Colors.orange;
    if (statusCode >= 400 && statusCode < 500) return Colors.red;
    if (statusCode >= 500) return Colors.purple;
    return Colors.grey;
  }
}