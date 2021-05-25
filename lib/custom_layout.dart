part of 'swiper2.dart';

abstract class _CustomLayoutStateBase<T extends _SubSwiper> extends State<T>
    with SingleTickerProviderStateMixin {
  double _swiperWidth;
  Animation<double> _animation;
  AnimationController _animationController;
  int _startIndex;
  int _animationCount;
  int numberItem;

  @override
  void initState() {
    if (widget.itemWidth == null) {
      throw Exception(
          '==============\n\nwidget.itemWith must not be null when use stack layout.\n========\n');
    }

    _createAnimationController();
    numberItem = widget.itemCount;
    widget.controller.addListener(_onController);
    super.initState();
  }

  void _createAnimationController() {
    _animationController = AnimationController(vsync: this, value: 0.5);
    final Tween<double> tween = Tween(begin: 0.0, end: 1.0);
    _animation = tween.animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_getSize);
    super.didChangeDependencies();
  }

  void _getSize(_) {
    afterRender();
  }

  @mustCallSuper
  void afterRender() {
    if (context == null) {
      return;
    }
    final RenderObject renderObject = context.findRenderObject();
    final Size size = renderObject.paintBounds.size;
    _swiperWidth = size.width;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _animationController?.dispose();
    super.dispose();
  }

  Widget _buildItem(int i, int realIndex, double animationValue);

  Widget _buildContainer(List<Widget> list) {
    return Stack(
      children: list,
      overflow: Overflow.visible,
      fit: StackFit.expand,
    );
  }

  Widget _buildAnimation(BuildContext context, Widget w) {
    final List<Widget> list = [];

    final double animationValue = _animation.value;

    if(_animationCount ~/2 !=0){
      final halfCount = _animationCount ~/2;
      int realIndex = _currentIndex + halfCount + _startIndex;
      realIndex = realIndex % widget.itemCount;
      if (realIndex < 0) {
        realIndex += widget.itemCount;
      }

      list.add(_buildItem(halfCount, realIndex, animationValue));

      for(int i = 1; i <= halfCount; ++i){
        realIndex = _currentIndex + halfCount + i + _startIndex;
        realIndex = realIndex % widget.itemCount;
        if (realIndex < 0) {
          realIndex += widget.itemCount;
        }

        list.add(_buildItem(halfCount + i, realIndex, animationValue));
        realIndex = _currentIndex + halfCount - i + _startIndex;
        realIndex = realIndex % widget.itemCount;
        if (realIndex < 0) {
          realIndex += widget.itemCount;
        }

        list.add(_buildItem(halfCount - i, realIndex, animationValue));
      }
    }
    else {
      final halfCount = _animationCount ~/2;


      for(int i = 1; i <= halfCount; ++i){
        int realIndex = _currentIndex + halfCount + i + _startIndex;
        realIndex = realIndex % widget.itemCount;
        if (realIndex < 0) {
          realIndex += widget.itemCount;
        }

        list.add(_buildItem(halfCount + i, realIndex, animationValue));
        realIndex = _currentIndex + halfCount - i -1 + _startIndex;
        realIndex = realIndex % widget.itemCount;
        if (realIndex < 0) {
          realIndex += widget.itemCount;
        }

        list.add(_buildItem(halfCount - i, realIndex, animationValue));
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onPanUpdate: _onPanUpdate,
      child: ClipRect(
        child: Center(
          child: _buildContainer(list.reversed.toList()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCount == null) {
      return Container();
    }
    return AnimatedBuilder(
        animation: _animationController, builder: _buildAnimation);
  }

  double _currentValue;
  double _currentPos;

  bool _lockScroll = false;

  Future _move(double position, {int nextIndex}) async {
    if (_lockScroll) {
      return;
    }
    try {
      _lockScroll = true;

      await _animationController.animateTo(position,
          duration: Duration(milliseconds: widget.duration),
          curve: widget.curve);
      if (nextIndex != null) {
        widget.onIndexChanged(widget.getCorrectIndex(nextIndex));
      }
    } catch (e) {
      //print(e);
    } finally {
      if (nextIndex != null) {
        try {
          _animationController.value = 0.5;
        } catch (e) {
          //print(e);
        }

        _currentIndex = nextIndex;
      }
      _lockScroll = false;
    }
  }

  Future _moveToIndex(int index) async {
    if (_currentIndex > widget.itemCount - 1) {
      _currentIndex = _currentIndex % widget.itemCount;
    }
    if (_lockScroll) {
      return;
    }
    try {
      _lockScroll = true;

      int forwardSteps = _currentIndex - index;
      int backwardSteps = widget.itemCount - forwardSteps.abs();
      if (forwardSteps > 0) {
        final int temp = forwardSteps;
        forwardSteps = backwardSteps.abs();
        backwardSteps = temp.abs();
      }
      forwardSteps = forwardSteps.abs();

      if (forwardSteps > backwardSteps) {
        for (int i = 0; i < backwardSteps; ++i) {
          await _animationController.animateTo(1.0,
              duration: const Duration(milliseconds: 400), curve: widget.curve);
//          widget.onIndexChanged(widget.getCorrectIndex(index));
          _animationController.value = 0.5;
          _currentIndex = _prevIndex();
        }
      } else {
        for (int i = 0; i < forwardSteps; ++i) {
          await _animationController.animateTo(0.0,
              duration: const Duration(milliseconds: 400), curve: widget.curve);
//          widget.onIndexChanged(widget.getCorrectIndex(index));
          _animationController.value = 0.5;
          _currentIndex = _nextIndex();
        }
      }

      widget.onIndexChanged(widget.getCorrectIndex(index));
    } catch (e) {
      // print(e);
    } finally {
      try {
        _animationController.value = 0.5;
      } catch (e) {
        // print(e);
      }
      _lockScroll = false;
      _currentIndex = index;
    }
  }

  Future _moveToIndexWithoutAnimation(int index) async {
    if (_currentIndex > widget.itemCount - 1) {
      _currentIndex = _currentIndex % widget.itemCount;
    }
    if (_lockScroll) {
      return;
    }
    try {
      _lockScroll = true;
      _currentIndex = index;

      widget.onIndexChanged(widget.getCorrectIndex(index));
    } catch (e) {
      // print(e);
    } finally {
      try {
        _animationController.value = 0.5;
      } catch (e) {
        // print(e);
      }
      _lockScroll = false;
      _currentIndex = index;
    }
  }

  int _nextIndex() {
    final int index = _currentIndex + 1;

    return index;
  }

  int _prevIndex() {
    final int index = _currentIndex - 1;

    return index;
  }

  void _onController() {
    switch (widget.controller.event) {
      case IndexController.PREVIOUS:
        final int prevIndex = _prevIndex();
        if (prevIndex == _currentIndex) {
          return;
        }
        _move(1.0, nextIndex: prevIndex);
        break;
      case IndexController.NEXT:
        final int nextIndex = _nextIndex();
        if (nextIndex == _currentIndex) {
          return;
        }
        _move(0.0, nextIndex: nextIndex);
        break;
      case IndexController.MOVE:
        if(widget.controller.animation){
          final int nextIndex = _nextIndex();
          if (nextIndex == _currentIndex) {
            return;
          }
          _moveToIndex(widget.controller.index);
        }
        else {
          final int nextIndex = _nextIndex();
          if (nextIndex == _currentIndex) {
            return;
          }
          _moveToIndexWithoutAnimation(widget.controller.index);

        }
        break;
      case SwiperController.STOP_AUTOPLAY:
      case SwiperController.START_AUTOPLAY:
        break;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_lockScroll) {
      return;
    }

    final double velocity = widget.scrollDirection == Axis.horizontal
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;

    if (_animationController.value >= 0.75 || velocity > 500.0) {
      _move(1.0, nextIndex: _currentIndex - 1);
    } else if (_animationController.value < 0.25 || velocity < -500.0) {
      _move(0.0, nextIndex: _currentIndex + 1);
    } else {
      _move(0.5);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_lockScroll) {
      return;
    }
    _currentValue = _animationController.value;
    _currentPos = widget.scrollDirection == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lockScroll) {
      return;
    }
    final double value = _currentValue +
        ((widget.scrollDirection == Axis.horizontal
            ? details.globalPosition.dx
            : details.globalPosition.dy) -
            _currentPos) /
            _swiperWidth /
            2;

    _animationController.value = (value - 0.5) * 5 + 0.5;
    if (_animationController.value >= 1.0) {
      _move(1.0, nextIndex: _currentIndex - 1);
      _currentValue = 0.5;
      _currentPos = widget.scrollDirection == Axis.horizontal
          ? details.globalPosition.dx
          : details.globalPosition.dy;
    } else if (_animation.value <= 0.0) {
      _move(0.0, nextIndex: _currentIndex + 1);

      _currentValue = 0.5;
      _currentPos = widget.scrollDirection == Axis.horizontal
          ? details.globalPosition.dx
          : details.globalPosition.dy;
    }
  }

  int _currentIndex = 0;
}

double _getValue(List<double> values, double animationValue, int index) {
  double s = values[index];
  if (animationValue >= 0.5) {
    if (index < values.length - 1) {
      s = s + (values[index + 1] - s) * (animationValue - 0.5) * 2.0;
    }
  } else {
    if (index != 0) {
      s = s - (s - values[index - 1]) * (0.5 - animationValue) * 2.0;
    }
  }
  return s;
}

Offset _getOffsetValue(List<Offset> values, double animationValue, int index) {
  final Offset s = values[index];
  double dx = s.dx;
  double dy = s.dy;
  if (animationValue >= 0.5) {
    if (index < values.length - 1) {
      dx = dx + (values[index + 1].dx - dx) * (animationValue - 0.5) * 2.0;
      dy = dy + (values[index + 1].dy - dy) * (animationValue - 0.5) * 2.0;
    }
  } else {
    if (index != 0) {
      dx = dx - (dx - values[index - 1].dx) * (0.5 - animationValue) * 2.0;
      dy = dy - (dy - values[index - 1].dy) * (0.5 - animationValue) * 2.0;
    }
  }
  return Offset(dx, dy);
}

abstract class TransformBuilder<T> {
  TransformBuilder({this.values});

  List<T> values;

  Widget build(int i, double animationValue, Widget widget);
}

class ScaleTransformBuilder extends TransformBuilder<double> {
  ScaleTransformBuilder(
      {List<double> values, this.alignment = Alignment.center})
      : super(values: values);

  final Alignment alignment;

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final double s = _getValue(values, animationValue, i);
    return Transform.scale(scale: s, child: widget);
  }
}

class OpacityTransformBuilder extends TransformBuilder<double> {
  OpacityTransformBuilder({List<double> values}) : super(values: values);

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final double v = _getValue(values, animationValue, i);
    return Opacity(
      opacity: v,
      child: widget,
    );
  }
}

class RotateTransformBuilder extends TransformBuilder<double> {
  RotateTransformBuilder({List<double> values}) : super(values: values);

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final double v = _getValue(values, animationValue, i);
    return Transform.rotate(
      angle: v,
      child: widget,
    );
  }
}

class TranslateTransformBuilder extends TransformBuilder<Offset> {
  TranslateTransformBuilder({List<Offset> values}) : super(values: values);

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final Offset s = _getOffsetValue(values, animationValue, i);
    return Transform.translate(
      offset: s,
      child: widget,
    );
  }
}

class CustomLayoutOption {
  CustomLayoutOption({this.stateCount, @required this.startIndex})
      : assert(startIndex != null, stateCount != null);

  final List<TransformBuilder> builders = [];
  final int startIndex;
  final int stateCount;

  CustomLayoutOption addOpacity(List<double> values) {
    builders.add(OpacityTransformBuilder(values: values));
    return this;
  }

  CustomLayoutOption addTranslate(List<Offset> values) {
    builders.add(TranslateTransformBuilder(values: values));
    return this;
  }

  CustomLayoutOption addScale(List<double> values, Alignment alignment) {
    builders.add(ScaleTransformBuilder(values: values, alignment: alignment));
    return this;
  }

  CustomLayoutOption addRotate(List<double> values) {
    builders.add(RotateTransformBuilder(values: values));
    return this;
  }
}

class _CustomLayoutSwiper extends _SubSwiper {
  const _CustomLayoutSwiper(
      {@required this.option,
        double itemWidth,
        double itemHeight,
        ValueChanged<int> onIndexChanged,
        Key key,
        IndexedWidgetBuilder itemBuilder,
        Curve curve,
        int duration,
        int index,
        int itemCount,
        Axis scrollDirection,
        SwiperController controller})
      : assert(option != null),
        super(
          onIndexChanged: onIndexChanged,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          key: key,
          itemBuilder: itemBuilder,
          curve: curve,
          duration: duration,
          index: index,
          itemCount: itemCount,
          controller: controller,
          scrollDirection: scrollDirection);

  final CustomLayoutOption option;

  @override
  State<StatefulWidget> createState() {
    return _CustomLayoutState();
  }
}

class _CustomLayoutState extends _CustomLayoutStateBase<_CustomLayoutSwiper> {
  @override
  void didChangeDependencies() {
    _currentIndex = widget.index;
    super.didChangeDependencies();
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
  }

  @override
  void didUpdateWidget(_CustomLayoutSwiper oldWidget) {
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget _buildItem(int index, int realIndex, double animationValue) {
    final List<TransformBuilder> builders = widget.option.builders;


    Widget child = SizedBox(
        width: widget.itemWidth ?? double.infinity,
        height: widget.itemHeight ?? double.infinity,
        child: widget.itemBuilder(context, realIndex));

    for (int i = builders.length - 1; i >= 0; --i) {
      final TransformBuilder builder = builders[i];
      child = builder.build(index, animationValue, child);
    }

    return child;
  }
}
