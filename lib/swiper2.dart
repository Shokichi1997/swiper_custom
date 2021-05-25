import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:async';

import 'package:transformer_page_view/transformer_page_view.dart';

part 'custom_layout.dart';

typedef void SwiperOnTap(int index);

typedef Widget SwiperDataBuilder(BuildContext context, dynamic data, int index);

/// default auto play delay
const int kDefaultAutoplayDelayMs = 3000;

///  Default auto play transition duration (in millisecond)
const int kDefaultAutoplayTransactionDuration = 300;

const int kMaxValue = 2000000000;
const int kMiddleValue = 1000000000;

enum SwiperLayout { DEFAULT, STACK, TINDER, CUSTOM }

class Swiper extends StatefulWidget {
  /// If set true , the pagination will display 'outer' of the 'content' container.
  final bool outer;

  /// Inner item height, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double itemHeight;

  /// Inner item width, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double itemWidth;

  // height of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double containerHeight;
  // width of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double containerWidth;

  /// Build item on index
  final IndexedWidgetBuilder itemBuilder;

  /// Support transform like Android PageView did
  /// `itemBuilder` and `transformItemBuilder` must have one not null
  final PageTransformer transformer;

  /// count of the display items
  final int itemCount;

  final ValueChanged<int> onIndexChanged;

  ///auto play config
  final bool autoplay;

  ///Duration of the animation between transactions (in millisecond).
  final int autoplayDelay;

  ///disable auto play when interaction
  final bool autoplayDisableOnInteraction;

  ///auto play transition duration (in millisecond)
  final int duration;

  ///horizontal/vertical
  final Axis scrollDirection;

  ///transition curve
  final Curve curve;

  /// Set to false to disable continuous loop mode.
  final bool loop;

  ///Index number of initial slide.
  ///If not set , the `Swiper` is 'uncontrolled', which means manage index by itself
  ///If set , the `Swiper` is 'controlled', which means the index is fully managed by parent widget.
  final int index;

  ///Called when tap
  final SwiperOnTap onTap;

  ///The swiper pagination plugin
  final SwiperPlugin pagination;

  ///the swiper control button plugin
  final SwiperPlugin control;

  ///other plugins, you can custom your own plugin
  final List<SwiperPlugin> plugins;

  ///
  final SwiperController controller;

  final ScrollPhysics physics;

  ///
  final double viewportFraction;

  /// Build in layouts
  final SwiperLayout layout;

  /// this value is valid when layout == SwiperLayout.CUSTOM
  final CustomLayoutOption customLayoutOption;

  // This value is valid when viewportFraction is set and < 1.0
  final double scale;

  // This value is valid when viewportFraction is set and < 1.0
  final double fade;

  final PageIndicatorLayout indicatorLayout;

  Swiper({
    this.itemBuilder,
    this.indicatorLayout: PageIndicatorLayout.NONE,

    ///
    this.transformer,
    @required this.itemCount,
    this.autoplay: false,
    this.layout: SwiperLayout.DEFAULT,
    this.autoplayDelay: kDefaultAutoplayDelayMs,
    this.autoplayDisableOnInteraction: true,
    this.duration: kDefaultAutoplayTransactionDuration,
    this.onIndexChanged,
    this.index,
    this.onTap,
    this.control,
    this.loop: true,
    this.curve: Curves.ease,
    this.scrollDirection: Axis.horizontal,
    this.pagination,
    this.plugins,
    this.physics,
    Key key,
    this.controller,
    this.customLayoutOption,

    /// since v1.0.0
    this.containerHeight,
    this.containerWidth,
    this.viewportFraction: 1.0,
    this.itemHeight,
    this.itemWidth,
    this.outer: false,
    this.scale,
    this.fade,
  })  : assert(itemBuilder != null || transformer != null,
  "itemBuilder and transformItemBuilder must not be both null"),
        assert(
        !loop ||
            ((loop &&
                layout == SwiperLayout.DEFAULT &&
                (indicatorLayout == PageIndicatorLayout.SCALE ||
                    indicatorLayout == PageIndicatorLayout.COLOR ||
                    indicatorLayout == PageIndicatorLayout.NONE)) ||
                (loop && layout != SwiperLayout.DEFAULT)),
        "Only support `PageIndicatorLayout.SCALE` and `PageIndicatorLayout.COLOR`when layout==SwiperLayout.DEFAULT in loop mode"),
        super(key: key);

  factory Swiper.children({
    List<Widget> children,
    bool autoplay: false,
    PageTransformer transformer,
    int autoplayDelay: kDefaultAutoplayDelayMs,
    bool reverse: false,
    bool autoplayDisableOnInteraction: true,
    int duration: kDefaultAutoplayTransactionDuration,
    ValueChanged<int> onIndexChanged,
    int index,
    SwiperOnTap onTap,
    bool loop: true,
    Curve curve: Curves.ease,
    Axis scrollDirection: Axis.horizontal,
    SwiperPlugin pagination,
    SwiperPlugin control,
    List<SwiperPlugin> plugins,
    SwiperController controller,
    Key key,
    CustomLayoutOption customLayoutOption,
    ScrollPhysics physics,
    double containerHeight,
    double containerWidth,
    double viewportFraction: 1.0,
    double itemHeight,
    double itemWidth,
    bool outer: false,
    double scale: 1.0,
  }) {
    assert(children != null, "children must not be null");

    return new Swiper(
        transformer: transformer,
        customLayoutOption: customLayoutOption,
        containerHeight: containerHeight,
        containerWidth: containerWidth,
        viewportFraction: viewportFraction,
        itemHeight: itemHeight,
        itemWidth: itemWidth,
        outer: outer,
        scale: scale,
        autoplay: autoplay,
        autoplayDelay: autoplayDelay,
        autoplayDisableOnInteraction: autoplayDisableOnInteraction,
        duration: duration,
        onIndexChanged: onIndexChanged,
        index: index,
        onTap: onTap,
        curve: curve,
        scrollDirection: scrollDirection,
        pagination: pagination,
        control: control,
        controller: controller,
        loop: loop,
        plugins: plugins,
        physics: physics,
        key: key,
        itemBuilder: (BuildContext context, int index) {
          return children[index];
        },
        itemCount: children.length);
  }

  factory Swiper.list({
    PageTransformer transformer,
    List list,
    CustomLayoutOption customLayoutOption,
    SwiperDataBuilder builder,
    bool autoplay: false,
    int autoplayDelay: kDefaultAutoplayDelayMs,
    bool reverse: false,
    bool autoplayDisableOnInteraction: true,
    int duration: kDefaultAutoplayTransactionDuration,
    ValueChanged<int> onIndexChanged,
    int index,
    SwiperOnTap onTap,
    bool loop: true,
    Curve curve: Curves.ease,
    Axis scrollDirection: Axis.horizontal,
    SwiperPlugin pagination,
    SwiperPlugin control,
    List<SwiperPlugin> plugins,
    SwiperController controller,
    Key key,
    ScrollPhysics physics,
    double containerHeight,
    double containerWidth,
    double viewportFraction: 1.0,
    double itemHeight,
    double itemWidth,
    bool outer: false,
    double scale: 1.0,
  }) {
    return new Swiper(
        transformer: transformer,
        customLayoutOption: customLayoutOption,
        containerHeight: containerHeight,
        containerWidth: containerWidth,
        viewportFraction: viewportFraction,
        itemHeight: itemHeight,
        itemWidth: itemWidth,
        outer: outer,
        scale: scale,
        autoplay: autoplay,
        autoplayDelay: autoplayDelay,
        autoplayDisableOnInteraction: autoplayDisableOnInteraction,
        duration: duration,
        onIndexChanged: onIndexChanged,
        index: index,
        onTap: onTap,
        curve: curve,
        key: key,
        scrollDirection: scrollDirection,
        pagination: pagination,
        control: control,
        controller: controller,
        loop: loop,
        plugins: plugins,
        physics: physics,
        itemBuilder: (BuildContext context, int index) {
          return builder(context, list[index], index);
        },
        itemCount: list.length);
  }

  @override
  State<StatefulWidget> createState() {
    return new _SwiperState();
  }
}

abstract class _SwiperTimerMixin extends State<Swiper> {
  Timer _timer;

  SwiperController _controller;

  @override
  void initState() {
    _controller = widget.controller;
    if (_controller == null) {
      _controller = new SwiperController();
    }
    _controller.addListener(_onController);
    _handleAutoplay();
    super.initState();
  }

  void _onController() {
    switch (_controller.event) {
      case SwiperController.START_AUTOPLAY:
        {
          if (_timer == null) {
            _startAutoplay();
          }
        }
        break;
      case SwiperController.STOP_AUTOPLAY:
        {
          if (_timer != null) {
            _stopAutoplay();
          }
        }
        break;
    }
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    if (_controller != oldWidget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller.removeListener(_onController);
        _controller = oldWidget.controller;
        _controller.addListener(_onController);
      }
    }
    _handleAutoplay();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.removeListener(_onController);
      //  _controller.dispose();
    }

    _stopAutoplay();
    super.dispose();
  }

  bool _autoplayEnabled() {
    return _controller.autoplay ?? widget.autoplay;
  }

  void _handleAutoplay() {
    if (_autoplayEnabled() && _timer != null) return;
    _stopAutoplay();
    if (_autoplayEnabled()) {
      _startAutoplay();
    }
  }

  void _startAutoplay() {
    assert(_timer == null, "Timer must be stopped before start!");
    _timer =
        Timer.periodic(Duration(milliseconds: widget.autoplayDelay), _onTimer);
  }

  void _onTimer(Timer timer) {
    _controller.next(animation: true);
  }

  void _stopAutoplay() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}

class _SwiperState extends _SwiperTimerMixin {
  int _activeIndex;

  TransformerPageController _pageController;

  Widget _wrapTap(BuildContext context, int index) {
    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        this.widget.onTap(index);
      },
      child: widget.itemBuilder(context, index),
    );
  }

  @override
  void initState() {
    _activeIndex = widget.index ?? 0;
    if (_isPageViewLayout()) {
      _pageController = new TransformerPageController(
          initialPage: widget.index,
          loop: widget.loop,
          itemCount: widget.itemCount,
          reverse:
          widget.transformer == null ? false : widget.transformer.reverse,
          viewportFraction: widget.viewportFraction);
    }
    super.initState();
  }

  bool _isPageViewLayout() {
    return widget.layout == null || widget.layout == SwiperLayout.DEFAULT;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool _getReverse(Swiper widget) =>
      widget.transformer == null ? false : widget.transformer.reverse;

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isPageViewLayout()) {
      if (_pageController == null ||
          (widget.index != oldWidget.index ||
              widget.loop != oldWidget.loop ||
              widget.itemCount != oldWidget.itemCount ||
              widget.viewportFraction != oldWidget.viewportFraction ||
              _getReverse(widget) != _getReverse(oldWidget))) {
        _pageController = new TransformerPageController(
            initialPage: widget.index,
            loop: widget.loop,
            itemCount: widget.itemCount,
            reverse: _getReverse(widget),
            viewportFraction: widget.viewportFraction);
      }
    } else {
      scheduleMicrotask(() {
        // So that we have a chance to do `removeListener` in child widgets.
        if (_pageController != null) {
          _pageController.dispose();
          _pageController = null;
        }
      });
    }
    if (widget.index != null && widget.index != _activeIndex) {
      _activeIndex = widget.index;
    }
  }

  void _onIndexChanged(int index) {
    setState(() {
      _activeIndex = index;
    });
    if (widget.onIndexChanged != null) {
      widget.onIndexChanged(index);
    }
  }

  Widget _buildSwiper() {
    IndexedWidgetBuilder itemBuilder;
    if (widget.onTap != null) {
      itemBuilder = _wrapTap;
    } else {
      itemBuilder = widget.itemBuilder;
    }

    return _CustomLayoutSwiper(
      option: widget.customLayoutOption,
      itemWidth: widget.itemWidth,
      itemHeight: widget.itemHeight,
      itemCount: widget.itemCount,
      itemBuilder: itemBuilder,
      index: _activeIndex,
      curve: widget.curve,
      duration: widget.duration,
      onIndexChanged: _onIndexChanged,
      controller: _controller,
      scrollDirection: widget.scrollDirection,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget swiper = _buildSwiper();
    return swiper;
  }
}

abstract class _SubSwiper extends StatefulWidget {
  const _SubSwiper(
      {Key key,
        this.itemHeight,
        this.itemWidth,
        this.duration,
        this.curve,
        this.itemBuilder,
        this.controller,
        this.index,
        this.itemCount,
        this.scrollDirection = Axis.horizontal,
        this.onIndexChanged})
      : super(key: key);
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int index;
  final ValueChanged<int> onIndexChanged;
  final SwiperController controller;
  final int duration;
  final Curve curve;
  final double itemWidth;
  final double itemHeight;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState();

  int getCorrectIndex(int indexNeedsFix) {
    if (itemCount == 0) return 0;
    int value = indexNeedsFix % itemCount;
    if (value < 0) {
      value += itemCount;
    }
    return value;
  }
}
