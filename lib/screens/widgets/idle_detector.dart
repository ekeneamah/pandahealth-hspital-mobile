import 'dart:async';

import 'package:flutter/material.dart';

class IdleDetector extends StatefulWidget {
  final Widget child;
  final Duration idleTime;
  final VoidCallback onIdle;

  const IdleDetector({
    super.key,
    required this.child,
    required this.idleTime,
    required this.onIdle,
  });

  @override
  State<IdleDetector> createState() => _IdleDetectorState();
}

class _IdleDetectorState extends State<IdleDetector>
    with WidgetsBindingObserver {
  Timer? _idleTimer;
  DateTime? _minimizedTime;

  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(widget.idleTime, widget.onIdle);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is minimized
      _minimizedTime = DateTime.now();
      _idleTimer?.cancel();
      print('App is minimized at ${DateTime.now().toIso8601String()}');
    } else if (state == AppLifecycleState.resumed) {
      // App is resumed
      print('App is resumed at ${DateTime.now().toIso8601String()}');
      if (_minimizedTime != null) {
        final minimizedDuration = DateTime.now().difference(_minimizedTime!);
        print('Minimized duration: $minimizedDuration');
        if (minimizedDuration >= widget.idleTime) {
          widget.onIdle();
        } else {
          print('App is resumed but has not been minimized for 5 minutes');
        }
      }
      _resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
