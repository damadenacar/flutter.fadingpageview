# FadingPageView

This package provides a widget similar to PageView that makes the transition between pages by fading out the current one and fading in the next one.

## Features

The animation shows an example of walking from one page to the next one.

![Examples](https://github.com/damadenacar/flutter.fadingpageview/raw/main/img/demo.gif)

Some features are:

- control the page to show, go to next, go to previous, etc. from the parent widget (by using the `FadingPageViewController`).
- enable an `onShown` callback, called whenever the current page has faded in completely.
- control whether to disable or not the pointer while fading.
- custom fade-in and fade-out duration.

## Getting started

To start using this package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
    linear_timer:
```

Then get the dependencies (e.g. `flutter pub get`) and import them into your application:

```dart
import 'package:fadingpageview/fadingpageview.dart';
```

## Usage

In the most simple case, use the widget in your application:

```dart
class _FadingPageViewDemoState extends State<FadingPageViewDemo> {
  FadingPageViewController pageController = FadingPageViewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: 
          FloatingActionButton(
            onPressed: () {
              pageController.next();
            },
            child: const Icon(Icons.navigate_next),
          ),
        body: FadingPageView(
          controller: pageController,
          disableWhileAnimating: true,
          itemBuilder: (context, itemIndex) {
            return Center(
              child: Text("This is the content for page: $itemIndex")
            );
          }
        )
    );
  }
}
```

Have in mind that the controller `FadingPageViewController` is mandatory because the only way to control when to change the page is by using this controller.

## Additional information

### FadingPageView
The constructor for the widget is the next:

```dart
FadingPageView(
  {required this.itemBuilder,
  required this.controller,
  this.onShown,
  this.fadeInDuration = const Duration(milliseconds: 300),
  this.fadeOutDuration = const Duration(milliseconds: 300),
  this.disableWhileAnimating = false,
  super.key});
```

The basic information is:

- __itemBuilder__: is the generator for the content for each page. Is a function that is used to build the page Widget Function(BuildContext context, int itemIndex)
- __controller__: is the controller of the pages being shown. It is mandatory to include this controller, because is the only mechanism to change from one page to another.
- __fadeInDuration and fadeOutDuration__: are duration of the transitions.
- __disableWhileAnimating__: if set to `true`, the content is disabled while it is being faded in or out.
- __onShown__: is a callback, called whenever the page is visible after being faded in.

### FadingPageViewController

This is the controller used to define the number of pages, the current page, etc.

The constructor is the next:

`FadingPageViewController([int startingPage = 0, int? pageCount])`, and initializes the values for the `startingPage` that is shown in first place, and the `pageCount` that will be considered; if set to 0, it means _infinite_ pages.

Then it exports the following attributes:

- __currentPage__: used to __get__ the current page and to __go to a page__ (it means that the viewer will fade-out the current page and will fade-in the new one).
- __isAnimating__: returns whether the page view is being faded in or out at this moment.
- __pageCount__: used to __get__ the total number of pages considered, and to __set__ the number of possible pages.
- __isAtEnd__: Gets whether it is at the end or not
- __isAtBeginning__: Gets whether it is at the beginning or not.
- __hasMorePages__: Gets whether there are more pages or not.

It also exports the next two methods:

- __next()__: transitions to the next page (if there are more pages). If the controller is at the last page, it does nothing.
- __previous()__: transitions to the previous page (if there are more pages). If the controller is at the first page, it does nothing.

