import 'package:arc_progress_bar/arc_progress_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ArcProgressBarApp(),
    );
  }
}

class ArcProgressBarApp extends StatefulWidget {
  const ArcProgressBarApp({super.key});

  @override
  State<ArcProgressBarApp> createState() => _ArcProgressBarAppState();
}

class _ArcProgressBarAppState extends State<ArcProgressBarApp> {
  double _progressPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arc Progress Bar Demo"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ArcProgressBar(
              percentage: _progressPercentage,
              arcThickness: 5,
              foregroundColor: Colors.blue,
              innerPadding: 64,
            ),
            ArcProgressBar(
              percentage: _progressPercentage,
              arcThickness: 15,
              innerPadding: 48,
              strokeCap: StrokeCap.round,
              handleSize: 50,
              handleWidget: Container(
                decoration: const BoxDecoration(color: Colors.red),
              ),
              foregroundColor: Colors.redAccent,
              backgroundColor: Colors.red.shade100,
            ),
            ArcProgressBar(
                percentage: _progressPercentage,
                bottomLeftWidget: const Text("Level 3"),
                bottomRightWidget: const Text("240/300"),
                bottomCenterWidget: const Text("RECRUIT"),
                centerWidget: Image.asset("assets/images/insignia.png",
                    height: 200, width: 200, fit: BoxFit.contain)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Divider(
                color: Colors.black38,
              ),
            ),
            Slider(
                value: _progressPercentage,
                min: 0,
                max: 100,
                onChanged: (val) {
                  setState(() {
                    _progressPercentage = val;
                  });
                }),
          ],
        ),
      ),
    );
  }
}
