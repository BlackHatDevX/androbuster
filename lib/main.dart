import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

import 'models/scan_result.dart';

import 'services/scanning_service.dart';
import 'services/file_service.dart';
import 'services/update_service.dart';
import 'services/background_service.dart';

import 'widgets/directory_tab.dart';
import 'widgets/subdomain_tab.dart';
import 'widgets/results_tab.dart';
import 'widgets/dialogs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AndroBuster',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AndroBusterScreen(),
    );
  }
}

class AndroBusterScreen extends StatefulWidget {
  const AndroBusterScreen({super.key});

  @override
  State<AndroBusterScreen> createState() => _AndroBusterScreenState();
}

class _AndroBusterScreenState extends State<AndroBusterScreen> with WidgetsBindingObserver {

  String _wordlistContent = '';
  String _subdomainWordlistContent = '';

  final BackgroundService _backgroundService = BackgroundService();

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _statusCodesController = TextEditingController(text: '404');
  final TextEditingController _pageSizesController = TextEditingController(text: '0');
  final TextEditingController _wordlistController = TextEditingController();
  final TextEditingController _threadsController = TextEditingController(text: '10');
  final TextEditingController _timeoutController = TextEditingController(text: '5000');

  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _subdomainWordlistController = TextEditingController();
  final TextEditingController _subdomainThreadsController = TextEditingController(text: '10');
  final TextEditingController _subdomainTimeoutController = TextEditingController(text: '5000');
  final TextEditingController _subdomainStatusCodesController = TextEditingController(text: '404');
  final TextEditingController _subdomainPageSizesController = TextEditingController(text: '0');

  bool _isScanning = false;
  bool _isSubdomainScanning = false;
  double _progress = 0.0;
  double _subdomainProgress = 0.0;
  final List<ScanResult> _results = [];
  final List<ScanResult> _subdomainResults = [];
  int _totalWords = 0;
  int _currentWord = 0;
  int _totalSubdomains = 0;
  int _currentSubdomain = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundService.dispose();
    _urlController.dispose();
    _statusCodesController.dispose();
    _pageSizesController.dispose();
    _wordlistController.dispose();
    _threadsController.dispose();
    _timeoutController.dispose();
    _domainController.dispose();
    _subdomainWordlistController.dispose();
    _subdomainThreadsController.dispose();
    _subdomainTimeoutController.dispose();
    _subdomainStatusCodesController.dispose();
    _subdomainPageSizesController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        if (_isScanning || _isSubdomainScanning) {
          print('App paused but scanning is active - keeping alive');
        }
        break;
      case AppLifecycleState.resumed:
        print('App resumed');
        break;
      default:
        break;
    }
  }

  void _startScan() async {
    if (_urlController.text.isEmpty || _wordlistController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      int threadCount = int.parse(_threadsController.text.trim());
      if (threadCount > 20) {
        AppDialogs.showThreadWarning(context, _executeScan);
        return;
      }
    } catch (e) {
      
    }

    _executeScan();
  }

  void _executeScan() async {
    setState(() {
      _isScanning = true;
      _progress = 0.0;
      _results.clear();
      _currentWord = 0;
    });

    await _backgroundService.startService();

    final String baseUrl = ScanningService.cleanUrl(_urlController.text);
    final List<int> negativeStatusCodes = ScanningService.parseIntegerList(_statusCodesController.text);
    final List<int> negativePageSizes = ScanningService.parseIntegerList(_pageSizesController.text);

    int threadCount = 10;
    int timeoutMs = 5000;
    try {
      threadCount = int.parse(_threadsController.text.trim());
      timeoutMs = int.parse(_timeoutController.text.trim());
    } catch (e) {

    }

    final String wordlistText = _wordlistContent.isNotEmpty ? _wordlistContent : _wordlistController.text;
    await _processWordlistStreaming(baseUrl, negativeStatusCodes, negativePageSizes, threadCount, timeoutMs, wordlistText);
  }

  Future<void> _processWordlistStreaming(
    String baseUrl,
    List<int> negativeStatusCodes,
    List<int> negativePageSizes,
    int threadCount,
    int timeoutMs,
    String wordlistText,
  ) async {
    final List<String> allWords = ScanningService.parseWordlist(wordlistText);
    _totalWords = allWords.length;

    if (_totalWords == 0) {
      setState(() {
        _isScanning = false;
      });
      return;
    }

    const int batchSize = 1000;

    for (int i = 0; i < allWords.length; i += batchSize) {
      if (!_isScanning) break;

      int endIndex = (i + batchSize < allWords.length) ? i + batchSize : allWords.length;
      List<String> batch = allWords.sublist(i, endIndex);

      await _processWordlistBatch(batch, baseUrl, negativeStatusCodes, negativePageSizes, threadCount, timeoutMs);

      setState(() {
        _currentWord = endIndex;
        _progress = endIndex / allWords.length;
      });

      await Future.delayed(const Duration(milliseconds: 10));
    }

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _processWordlistBatch(
    List<String> wordlist,
    String baseUrl,
    List<int> negativeStatusCodes,
    List<int> negativePageSizes,
    int threadCount,
    int timeoutMs,
  ) async {
    final List<List<String>> chunks = [];
    for (int i = 0; i < wordlist.length; i += threadCount) {
      chunks.add(wordlist.sublist(i, (i + threadCount > wordlist.length) ? wordlist.length : i + threadCount));
    }

    for (int chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
      if (!_isScanning) break;

      final List<String> chunk = chunks[chunkIndex];
      final List<Future<void>> futures = [];

      for (String path in chunk) {
        futures.add(_scanPath(path, baseUrl, negativeStatusCodes, negativePageSizes, timeoutMs));
      }

      await Future.wait(futures);
    }
  }

  Future<void> _scanPath(
    String path,
    String baseUrl,
    List<int> negativeStatusCodes,
    List<int> negativePageSizes,
    int timeoutMs,
  ) async {
    final ScanResult? result = await ScanningService.scanPath(
      path,
      baseUrl,
      negativeStatusCodes,
      negativePageSizes,
      timeoutMs,
    );

    if (result != null) {
      setState(() {
        _results.add(result);
      });
    }
  }

  void _stopScan() {
    setState(() {
      _isScanning = false;
    });

    _backgroundService.stopService();
  }

  void _startSubdomainScan() async {
    if (_domainController.text.isEmpty || _subdomainWordlistController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in domain and subdomain wordlist')),
      );
      return;
    }

    try {
      int threadCount = int.parse(_subdomainThreadsController.text.trim());
      if (threadCount > 20) {
        AppDialogs.showThreadWarning(context, _executeSubdomainScan);
        return;
      }
    } catch (e) {

    }

    _executeSubdomainScan();
  }

  void _executeSubdomainScan() async {
    setState(() {
      _isSubdomainScanning = true;
      _subdomainProgress = 0.0;
      _subdomainResults.clear();
      _currentSubdomain = 0;
    });

    await _backgroundService.startService();

    final String domain = ScanningService.cleanDomain(_domainController.text);
    final List<int> negativeStatusCodes = ScanningService.parseIntegerList(_subdomainStatusCodesController.text);
    final List<int> negativePageSizes = ScanningService.parseIntegerList(_subdomainPageSizesController.text);

    int threadCount = 10;
    int timeoutMs = 5000;
    try {
      threadCount = int.parse(_subdomainThreadsController.text.trim());
      timeoutMs = int.parse(_subdomainTimeoutController.text.trim());
    } catch (e) {

    }

    final String subdomainText = _subdomainWordlistContent.isNotEmpty ? _subdomainWordlistContent : _subdomainWordlistController.text;
    final List<String> subdomainList = ScanningService.parseSubdomainWordlist(subdomainText);

    _totalSubdomains = subdomainList.length;

    final int originalCount = ScanningService.parseWordlist(subdomainText).length;
    if (originalCount > subdomainList.length) {
      int filteredCount = originalCount - subdomainList.length;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filtered out $filteredCount invalid subdomain(s)'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    final List<List<String>> chunks = [];
    for (int i = 0; i < subdomainList.length; i += threadCount) {
      chunks.add(subdomainList.sublist(i, (i + threadCount > subdomainList.length) ? subdomainList.length : i + threadCount));
    }

    for (int chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
      if (!_isSubdomainScanning) break;

      final List<String> chunk = chunks[chunkIndex];
      final List<Future<void>> futures = [];

      for (String subdomain in chunk) {
        futures.add(_scanSubdomain(subdomain, domain, negativeStatusCodes, negativePageSizes, timeoutMs));
      }

      await Future.wait(futures);

      setState(() {
        _currentSubdomain = (chunkIndex + 1) * threadCount;
        if (_currentSubdomain > subdomainList.length) _currentSubdomain = subdomainList.length;
        _subdomainProgress = _currentSubdomain / subdomainList.length;
      });
    }

    setState(() {
      _isSubdomainScanning = false;
    });
  }

  Future<void> _scanSubdomain(
    String subdomain,
    String domain,
    List<int> negativeStatusCodes,
    List<int> negativePageSizes,
    int timeoutMs,
  ) async {
    final ScanResult? result = await ScanningService.scanSubdomain(
      subdomain,
      domain,
      negativeStatusCodes,
      negativePageSizes,
      timeoutMs,
    );

    if (result != null) {
      setState(() {
        _subdomainResults.add(result);
      });
    }
  }

  void _stopSubdomainScan() {
    setState(() {
      _isSubdomainScanning = false;
    });

    _backgroundService.stopService();
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FileService.pickTextFile();
      if (result != null) {
        final FileInfo fileInfo = await FileService.processFile(result);

        setState(() {
          _wordlistController.text = fileInfo.previewText;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${fileInfo.name} (${fileInfo.formattedSize})'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _wordlistContent = fileInfo.content;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickSubdomainFile() async {
    try {
      final FilePickerResult? result = await FileService.pickTextFile();
      if (result != null) {
        final FileInfo fileInfo = await FileService.processFile(result);

        setState(() {
          _subdomainWordlistController.text = fileInfo.previewText;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported subdomain wordlist: ${fileInfo.name} (${fileInfo.formattedSize})'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _subdomainWordlistContent = fileInfo.content;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing subdomain file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearAllResults() {
    setState(() {
      _results.clear();
      _subdomainResults.clear();
      _progress = 0.0;
      _subdomainProgress = 0.0;
      _currentWord = 0;
      _currentSubdomain = 0;
      _wordlistContent = '';
      _subdomainWordlistContent = '';
    });
  }

  void _copyResultsToClipboard() {
    final StringBuffer buffer = StringBuffer();

    if (_results.isNotEmpty) {
      buffer.writeln('=== AndroBuster Scan Results ===');
      for (var result in _results) {
        buffer.writeln('${result.path} - Status: ${result.statusCode} - Size: ${result.size} - ${result.url}');
      }
      buffer.writeln();
    }

    if (_subdomainResults.isNotEmpty) {
      buffer.writeln('=== AndroBuster Subdomain Scan Results ===');
      for (var result in _subdomainResults) {
        buffer.writeln('${result.path} - Status: ${result.statusCode} - Size: ${result.size} - ${result.url}');
      }
    }

    if (buffer.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: buffer.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Results copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No results to copy'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _checkForUpdates() async {
    AppDialogs.showUpdateLoadingDialog(context);

    try {
      final UpdateCheckResult result = await UpdateService.checkForUpdates();

      if (mounted) {
        Navigator.of(context).pop(); 

        switch (result.status) {
          case UpdateStatus.updateAvailable:
            AppDialogs.showUpdateAvailableDialog(context, result.latestVersion!);
            break;
          case UpdateStatus.upToDate:
            AppDialogs.showUpToDateDialog(context);
            break;
          case UpdateStatus.currentVersionNewer:
            AppDialogs.showUpToDateDialog(context);
            break;
          case UpdateStatus.error:
            AppDialogs.showErrorDialog(context, result.errorMessage!);
            break;
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        AppDialogs.showErrorDialog(context, 'Error checking for updates: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AndroBuster'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'about':
                    AppDialogs.showAboutDialog(context);
                    break;
                  case 'telegram':
                    AppDialogs.showTelegramDialog(context);
                    break;
                  case 'update':
                    _checkForUpdates();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('About'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'telegram',
                  child: Row(
                    children: [
                      Icon(Icons.telegram, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Telegram'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'update',
                  child: Row(
                    children: [
                      Icon(Icons.system_update, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Check for Updates'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.folder), text: 'Dir'),
              Tab(icon: Icon(Icons.language), text: 'Subdomain'),
              Tab(icon: Icon(Icons.list), text: 'Results'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DirectoryTab(
              urlController: _urlController,
              statusCodesController: _statusCodesController,
              pageSizesController: _pageSizesController,
              wordlistController: _wordlistController,
              threadsController: _threadsController,
              timeoutController: _timeoutController,
              onPickFile: _pickFile,
              onStartScan: _startScan,
              onStopScan: _stopScan,
              isScanning: _isScanning,
              progress: _progress,
              currentWord: _currentWord,
              totalWords: _totalWords,
            ),
            SubdomainTab(
              domainController: _domainController,
              subdomainWordlistController: _subdomainWordlistController,
              subdomainThreadsController: _subdomainThreadsController,
              subdomainTimeoutController: _subdomainTimeoutController,
              subdomainStatusCodesController: _subdomainStatusCodesController,
              subdomainPageSizesController: _subdomainPageSizesController,
              onPickFile: _pickSubdomainFile,
              onStartScan: _startSubdomainScan,
              onStopScan: _stopSubdomainScan,
              isScanning: _isSubdomainScanning,
              progress: _subdomainProgress,
              currentSubdomain: _currentSubdomain,
              totalSubdomains: _totalSubdomains,
            ),
            ResultsTab(
              directoryResults: _results,
              subdomainResults: _subdomainResults,
              onCopyResults: _copyResultsToClipboard,
              onClearResults: _clearAllResults,
            ),
          ],
        ),
      ),
    );
  }
}