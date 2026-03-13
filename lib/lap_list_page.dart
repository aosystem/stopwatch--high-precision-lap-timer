import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:stopwatch/ad_manager.dart';
import 'package:stopwatch/ad_banner_widget.dart';
import 'package:stopwatch/theme_color.dart';
import 'package:stopwatch/format_duration.dart';
import 'package:stopwatch/loading_screen.dart';

class LapListPage extends StatefulWidget {
  final List<Duration> laps;
  const LapListPage({super.key, required this.laps});

  @override
  State<LapListPage> createState() => _LapListPageState();
}

class _LapListPageState extends State<LapListPage> {
  late AdManager _adManager;
  late ThemeColor _themeColor;
  bool _isReady = false;
  bool _isFirst = true;
  //

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  String _buildShareText() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("Lap,Time,Split");
    for (int i = 0; i < widget.laps.length; i++) {
      final lap = widget.laps[i];
      final diff = i == 0 ? lap : lap - widget.laps[i - 1];
      buffer.writeln("${(i + 1).toString()},${formatDuration(lap)},${formatDuration(diff)}");
    }
    return buffer.toString();
  }

  void _shareLaps() {
    final String text = _buildShareText();
    SharePlus.instance.share(
      ShareParams(text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady == false) {
      return const LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(context: context);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Lap Results"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareLaps,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: widget.laps.length,
          itemBuilder: (context, index) {
            final lap = widget.laps[index];
            final diff = index == 0 ? lap : lap - widget.laps[index - 1];
            return _buildLapCard(index, lap, diff);
          },
        )
      ),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _buildLapCard(int index, Duration lap, Duration diff) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: _themeColor.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LAP ${(index + 1).toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${formatDuration(lap)} (+${formatDuration(diff)})",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

}