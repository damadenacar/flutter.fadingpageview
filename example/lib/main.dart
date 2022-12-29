import 'package:flutter/material.dart';
import 'package:fadingpageview/fadingpageview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FadingPageView demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const FadingPageViewDemo(),
    );
  }
}

class FadingPageViewDemo extends StatefulWidget {
  const FadingPageViewDemo({super.key});

  @override
  State<FadingPageViewDemo> createState() => _FadingPageViewDemoState();
}

class _FadingPageViewDemoState extends State<FadingPageViewDemo> {
  FadingPageViewController pageController = FadingPageViewController();

  List<Color> colors = [Colors.amber, Colors.lightGreenAccent, Colors.green, Colors.blue];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                pageController.currentPage = 0;
              },
              child: const Icon(Icons.first_page),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: () {
                pageController.previous();
              },
              child: const Icon(Icons.navigate_before),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: () {
                pageController.next();
              },
              child: const Icon(Icons.navigate_next),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: () {
                pageController.currentPage = pageController.currentPage + 5;
              },
              child: const Icon(Icons.skip_next),
            ),
          ],
        ),
        body: FadingPageView(
          controller: pageController,
          disableWhileAnimating: true,
          itemBuilder: (context, itemIndex) {
            return Container(
              color: colors[itemIndex % colors.length],
              child: SizedBox.expand(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("This is the content for page: $itemIndex"),
                      const SizedBox(
                        height: 16,
                      ),
                    ]),
              ),
            );
          },
        ));
  }
}
