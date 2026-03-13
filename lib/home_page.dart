import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:stopwatch/parse_locale_tag.dart';
import 'package:stopwatch/setting_page.dart';
import 'package:stopwatch/theme_color.dart';
import 'package:stopwatch/theme_mode_number.dart';
import 'package:stopwatch/ad_manager.dart';
import 'package:stopwatch/loading_screen.dart';
import 'package:stopwatch/model.dart';
import 'package:stopwatch/main.dart';
import 'package:stopwatch/ad_banner_widget.dart';
import 'package:stopwatch/format_duration.dart';
import 'package:stopwatch/lap_list_page.dart';


class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> with TickerProviderStateMixin {
  late AdManager _adManager;
  late ThemeColor _themeColor;
  bool _isReady = false;
  bool _isFirst = true;
  //
  late AnimationController _controllerBlack;
  late AnimationController _controllerRed;
  //
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  final List<Duration> _laps = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    _wakelock();
    _controllerBlack = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    );
    _controllerRed = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );
    //
    if (Model.vibrateEnabled && await Vibration.hasVibrator()) {
    }
    //
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _controllerBlack.dispose();
    _controllerRed.dispose();
    _adManager.dispose();
    super.dispose();
  }

  void _wakelock() {
    if (Model.wakelockEnabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  double _safeWidth() {
    final MediaQueryData mq = MediaQuery.of(context);
    final double safeWidth = mq.size.width - mq.viewPadding.left - mq.viewPadding.right;
    return safeWidth;
  }

  void _onStart() async {
    if (_timer != null) {
      return;
    }
    if (_isRunning) {
      return;
    }
    _controllerBlack.reset();
    _controllerRed.reset();
    _controllerBlack.repeat();
    _controllerRed.repeat();
    _isRunning = true;
    setState(() {
      _elapsed = Duration.zero;
      _laps.clear();
    });
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
    if (Model.vibrateEnabled && await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20);
    }
  }

  void _onLap() async {
    if (!_isRunning) {
      return;
    }
    if (_laps.length >= 99) {
      return;
    }
    final current = _elapsed;
    setState(() {
      _laps.add(current);
    });
    if (Model.vibrateEnabled && await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20);
    }
  }

  void _onStop() async {
    _onLap();
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _controllerBlack.stop();
    _controllerRed.stop();
  }

  void _onClear() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    setState(() {
      _elapsed = Duration.zero;
      _laps.clear();
    });
    _controllerBlack.stop();
    _controllerRed.stop();
    _controllerBlack.reset();
    _controllerRed.reset();
    if (Model.vibrateEnabled && await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _openSetting() async {
    final updatedSettings = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingPage(),
      ),
    );
    if (updatedSettings != null) {
      if (mounted) {
        final mainState = context.findAncestorStateOfType<MainAppState>();
        if (mainState != null) {
          mainState
            ..locale = parseLocaleTag(Model.languageCode)
            ..themeMode = ThemeModeNumber.numberToThemeMode(Model.themeNumber)
            ..setState(() {});
        }
        _wakelock();
      }
      if (mounted) {
        setState(() {
          _isFirst = true;
        });
      }
    }
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
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _themeColor.mainBackColor,
      body: Stack(children:[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_themeColor.mainBack2Color, _themeColor.mainBackColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            image: DecorationImage(
              image: AssetImage('assets/image/tile.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.1,
            ),
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(formatDuration(_elapsed), style: t.titleLarge?.copyWith(color: _themeColor.mainForeColor)),
                  ],
                )
              ),
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAnimatedWidget(),
                      const SizedBox(height: 8),
                      _buildButtonWidget(),
                    ],
                  ),
                ),
              ),
            ]
          ),
        ),
      ]),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _buildAnimatedWidget() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Stack(children:[
        AspectRatio(
          aspectRatio: 1024/(1024 + 428),
          child: Column(children:[
            Stack(
              children: [
                Image.asset(_themeColor.mainStopwatchHead),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(_themeColor.mainStopwatchBody),
                AnimatedBuilder(
                  animation: _controllerRed,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: _controllerRed.value * 2 * 3.1415926535,
                      child: child,
                    );
                  },
                  child: Image.asset(_themeColor.mainStopwatchNeedleRed),
                ),
                AnimatedBuilder(
                  animation: _controllerBlack,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: _controllerBlack.value * 2 * 3.1415926535,
                      child: child,
                    );
                  },
                  child: Image.asset(_themeColor.mainStopwatchNeedleBlack),
                ),
              ],
            )
          ])
        ),
        Positioned(top: 50, bottom: 0, left: 0, right: 0,
          child: SingleChildScrollView(
            child: _buildLapList(),
          ),
        ),
        Positioned(top: 50, right: 0,
          child: _buildCircleButton("CLEAR", _onClear, _safeWidth() / 4),
        ),
        Positioned(top: 0,
          left: isRTL ? 0 : null,
          right: isRTL ? null : 0,
          child: Row(children:[
            IconButton(
              icon: Icon(Icons.list,color: _themeColor.mainForeColor.withValues(alpha: 0.8)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LapListPage(laps: _laps)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings,color: _themeColor.mainForeColor.withValues(alpha: 0.8)),
              onPressed: _openSetting,
            ),
          ])
        )
      ]),
    );
  }

  Widget _buildButtonWidget() {
    final double size = (_safeWidth() / 3) - 12;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton("START", _onStart, size),
          _buildCircleButton("LAP", _onLap, size),
          _buildCircleButton("STOP", _onStop, size),
        ],
      ),
    );
  }

  Widget _buildCircleButton(String label, VoidCallback onPressed, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: Colors.black26,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildLapList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _laps.length,
      itemBuilder: (context, index) {
        final lapTime = _laps[index];
        final diff = (index == 0) ? lapTime : lapTime - _laps[index - 1];
        BorderRadius radius;
        if (_laps.length == 1) {
          radius = BorderRadius.circular(8);
        } else if (index == 0) {
          radius = const BorderRadius.vertical(top: Radius.circular(8));
        } else if (index == _laps.length - 1) {
          radius = const BorderRadius.vertical(bottom: Radius.circular(8));
        } else {
          radius = BorderRadius.zero;
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: radius,
            ),
            child: Text(
              "${(index + 1).toString().padLeft(2,'0')}: ${formatDuration(lapTime)} (+${formatDuration(diff)})",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

}
