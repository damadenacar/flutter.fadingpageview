import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'fadeanimation.dart';

typedef _SetPageCallback = Function(int pageNumber);

/// Class that enables controlling the page that is being shown, from outside
///   the FadingPageView widget. It is possible to get to then next page,
///   previous, set the current page and set the total amount of pages.
class FadingPageViewController {
  /// Function that calls a list of handlers, in the same order
  void _callHandlers(List<_SetPageCallback> handlerList) {
    if (handlerList.isNotEmpty) {
      for (_SetPageCallback handler in handlerList) {
        handler.call(_currentPage);
      }
    }
  }

  /// Function to add a handler to a list
  void _addHandler(
      List<_SetPageCallback> handlerList, _SetPageCallback handler) {
    handlerList.add(handler);
  }

  // Functions to add the handlers
  void _addOnSetPageHandler(_SetPageCallback handler) =>
      _addHandler(_onSetPage, handler);
  void _addOnSetPageCountHandler(_SetPageCallback handler) =>
      _addHandler(_onSetPageCount, handler);
  void _addOnNextHandler(_SetPageCallback handler) =>
      _addHandler(_onNext, handler);
  void _addOnPreviousHandler(_SetPageCallback handler) =>
      _addHandler(_onPrevious, handler);

  /// Lists of handlers
  final List<_SetPageCallback> _onSetPage = [];
  final List<_SetPageCallback> _onSetPageCount = [];
  final List<_SetPageCallback> _onNext = [];
  final List<_SetPageCallback> _onPrevious = [];

  /// Initializes the values for the [startingPage] that is shown in first place,
  ///   and the [pageCount] that will be considered; if set to 0, it means _infinite_
  ///   pages.
  FadingPageViewController([int startingPage = 0, int? pageCount]) {
    _currentPage = startingPage;
    if (pageCount != null) {
      _pageCount = pageCount;
    } else {
      _pageCount = double.maxFinite.toInt();
    }
    if (_pageCount <= 0) {
      throw ("the number of pages must be greater than 0");
    }
    if (_currentPage > _pageCount - 1) {
      throw ("the number of pages cannot be less than the starting page");
    }
  }

  late int _currentPage;

  /// Get the current page
  int get currentPage => _currentPage;

  /// Set the current page and call the handlers, if needed
  set currentPage(int value) {
    if ((value < 0) || (value >= _pageCount)) {
      throw IndexError(value, this);
    }
    _currentPage = value;
    _callHandlers(_onSetPage);
  }

  bool _enabled = true;

  /// Returns whether the page view is being fading in or out at this moment
  bool get isAnimating => !_enabled;

  late int _pageCount;

  /// Retrieves the number of pages
  int get pageCount => _pageCount;

  /// Gets whether it is at the end or not
  bool get isAtEnd => _currentPage == _pageCount - 1;

  /// Gets whether it is at the beginning or not
  bool get isAtBeginning => _currentPage == 0;

  /// Gets whether there are more pages or not
  bool get hasMorePages => _currentPage < _pageCount - 1;

  /// Sets the number of pages, and call the handlers, if needed
  set pageCount(int value) {
    if (value <= 0) {
      throw RangeError("the number of pages cannot be zero or under 0");
    }
    _pageCount = value;

    // Update the current page
    int currentPage = min(_currentPage, _pageCount - 1);

    // We'll call the handlers only if the change changes the visible page
    if (currentPage != _currentPage) {
      _currentPage = currentPage;
      _callHandlers(_onSetPageCount);
    }
  }

  /// Sets the current page to the next one, if we are not at the end
  void next() {
    if (_currentPage < _pageCount - 1) {
      _currentPage++;
      _callHandlers(_onNext);
    }
  }

  /// Sets the current page to the previous one, if we are not at the beginning
  void previous() {
    if (_currentPage > 0) {
      _currentPage--;
      _callHandlers(_onPrevious);
    }
  }

  /// We move any logic from the widget to the controller, because the state is not in the widget anymore, but here
  FadingPageViewState _state = FadingPageViewState.visible;
  bool _pendingChanges = false;
  int _nextVisiblePageNumber = 0;
  int _visiblePageNumber = 0;
}

/// The possible states for the FadingPageView
enum FadingPageViewState { visible, fadeIn, fadeOut }

class FadingPageView extends StatefulWidget {
  /// The function that is used to build the page
  final Widget Function(BuildContext context, int itemIndex) itemBuilder;

  /// The controller of the pages being shown
  final FadingPageViewController controller;

  /// The duration of the transitions
  final Duration fadeInDuration;
  final Duration fadeOutDuration;

  /// If set to true, the content is disabled while it is being faded in or out
  final bool disableWhileAnimating;

  /// Function called when the current page has faded in completely
  final VoidCallback? onShown;

  /// Initializes the values for the widget. It is needed the [itemBuilder] that is being
  ///   called on demand, to generate the content of the page, and the [controller] to control
  ///   which page is being shown. It would have no sense to not to have a [controller] because
  ///   the page would not be ever changed.
  ///
  const FadingPageView(
      {required this.itemBuilder,
      required this.controller,
      this.onShown,
      this.fadeInDuration = const Duration(milliseconds: 300),
      this.fadeOutDuration = const Duration(milliseconds: 300),
      this.disableWhileAnimating = false,
      super.key});

  @override
  State<FadingPageView> createState() => _FadingPageViewState();
}

class _FadingPageViewState extends State<FadingPageView> {
  bool controllerInitialized = false;

  void _updateContent() {
    // If still mounted, we should update the state to update the content
    if (mounted) {
      setState(() {});
    }
  }

  void _changePage(int pageNumber) {
    widget.controller._state = FadingPageViewState.fadeOut;
    widget.controller._nextVisiblePageNumber = pageNumber;
    _updateContent();
  }

  void _changePageHandler(int pageNumber) {
    if (widget.controller._state == FadingPageViewState.fadeOut) {
      widget.controller._nextVisiblePageNumber = pageNumber;
    }
    if (widget.controller._state == FadingPageViewState.fadeIn) {
      widget.controller._pendingChanges = true;
      widget.controller._nextVisiblePageNumber = pageNumber;
    } else {
      _changePage(pageNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make sure that we have a controller, and initialize the values
    if (!controllerInitialized) {
      widget.controller._addOnNextHandler(_changePageHandler);
      widget.controller._addOnPreviousHandler(_changePageHandler);
      widget.controller._addOnSetPageCountHandler(_changePageHandler);
      widget.controller._addOnSetPageHandler(_changePageHandler);
      controllerInitialized = true;
    }

    // Get the item to show
    Widget child =
        widget.itemBuilder(context, widget.controller._visiblePageNumber);

    if ((widget.controller._state != FadingPageViewState.visible) &&
        (widget.disableWhileAnimating)) {
      child = IgnorePointer(
        child: child,
      );
    }

    switch (widget.controller._state) {
      case FadingPageViewState.visible:
        if (widget.controller._pendingChanges) {
          widget.controller._pendingChanges = false;
          widget.controller._state = FadingPageViewState.fadeOut;
          _updateContent();
        }
        break;
      case FadingPageViewState.fadeIn:
        widget.controller._enabled = false;
        child = FadeAnimation(
            duration: widget.fadeInDuration,
            onShown: () {
              widget.controller._state = FadingPageViewState.visible;
              widget.controller._enabled = true;
              if (widget.onShown != null) {
                widget.onShown!.call();
              }
              _updateContent();
            },
            child: child);
        break;
      case FadingPageViewState.fadeOut:
        widget.controller._enabled = false;
        child = FadeAnimation(
            duration: widget.fadeOutDuration,
            onHidden: () {
              widget.controller._state = FadingPageViewState.fadeIn;
              widget.controller._visiblePageNumber =
                  widget.controller._nextVisiblePageNumber;
              // Not enabled, because it will be faded in
              // widget.controller._enabled = true;

              SchedulerBinding.instance.addPostFrameCallback((timestamp) {
                _updateContent();
              });
            },
            fadeIn: false,
            child: child);
        break;
    }

    return child;
  }
}
