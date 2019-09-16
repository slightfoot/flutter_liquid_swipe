// MIT License
//
// Copyright (c) 2019 Simon Lightfoot
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'math.dart';

class LiquidSwipePager extends StatefulWidget {
  const LiquidSwipePager({
    Key key,
    this.itemCount,
    @required this.itemBuilder,
    this.controller,
  }) : super(key: key);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final PageController controller;

  @override
  _LiquidSwipePagerState createState() => _LiquidSwipePagerState();
}

class _LiquidSwipePagerState extends State<LiquidSwipePager> {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _LiquidSwipeScrollBehavior(),
      child: Scrollable(
        axisDirection: AxisDirection.right,
        controller: widget.controller,
        physics: const PageScrollPhysics(),
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return LiquidSwipeViewport(
            position: position,
            children: List.generate(widget.itemCount, (int index) {
              return widget.itemBuilder(context, index);
            }),
          );
        },
      ),
    );
  }
}

class _LiquidSwipeScrollBehavior extends ScrollBehavior {
  const _LiquidSwipeScrollBehavior();

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class LiquidSwipeViewport extends MultiChildRenderObjectWidget {
  LiquidSwipeViewport({
    Key key,
    @required this.position,
    @required List<Widget> children,
  }) : super(
          key: key,
          children: children,
        );

  final ViewportOffset position;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLiquidSwipeViewport(position: position);
  }

  @override
  void updateRenderObject(BuildContext context, RenderLiquidSwipeViewport renderObject) {
    renderObject.position = position;
  }
}

class RenderLiquidSwipeViewport extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ChildParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ChildParentData> {
  RenderLiquidSwipeViewport({
    ViewportOffset position,
  })  : assert(position != null),
        _position = position,
        super();

  ViewportOffset _position;

  ViewportOffset get position => _position;

  set position(ViewportOffset value) {
    assert(value != null);
    if (_position == value) {
      return;
    }
    if (attached) _position.removeListener(_updateChildren);
    _position = value;
    if (attached) _position.addListener(_updateChildren);
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _position.addListener(_updateChildren);
  }

  @override
  void detach() {
    _position.removeListener(_updateChildren);
    super.detach();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = _ChildParentData();
    }
  }

  void _updateChildren() {
    forEachChild((index, child, childParentData) {
      final start = ((childCount - 1 - index) * size.width);
      double progress = ((_position.pixels - start) / size.width);
      childParentData.progress = progress;
      if (progress >= 0.0 && progress <= 1.0) {
        if (_position.userScrollDirection == ScrollDirection.reverse) {
          childParentData.waveHorRadius = _LiquidSwipeMath.waveHorRadius(progress, size.width);
        } else {
          childParentData.waveHorRadius = _LiquidSwipeMath.waveHorRadiusBack(progress);
        }
        childParentData.waveVertRadius = _LiquidSwipeMath.waveVertRadius(progress, size.width);
        childParentData.sideWidth = (_position.pixels - start);
      } else {
        childParentData.waveHorRadius = 0.0;
        childParentData.waveVertRadius = 0.0;
        childParentData.sideWidth = 0.0;
      }
    });
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    if (childCount == 0) {
      _position.applyViewportDimension(0.0);
      _position.applyContentDimensions(0.0, 0.0);
      return;
    }

    size = constraints.biggest;
    final childConstraints = constraints.tighten();
    forEachChild((index, child, childParentData) {
      child.layout(childConstraints, parentUsesSize: true);
      childParentData.initLayout(index, size);
    });

    _position.applyViewportDimension(size.width);
    _position.applyContentDimensions(0.0, size.width * (childCount - 1));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    forEachChild((_, child, childParentData) {
      if (childParentData.progress <= 1.0) {
        final Path path = createPath(size, childParentData);
        context.pushClipPath(true, offset, offset & size, path, (PaintingContext context, Offset offset) {
          context.paintChild(child, offset);
        });
      }
    });
  }

  @override
  bool hitTest(HitTestResult result, {Offset position}) {
    bool hitTarget = false;
    if (size.contains(position)) {
      hitTarget = hitTestChildren(result, position: position) || hitTestSelf(position);
      result.add(BoxHitTestEntry(this, position));
    }
    return hitTarget;
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerMoveEvent) {
      forEachChild((_, child, childParentData) {
        childParentData.waveCenterY = event.position.dy;
      });
      markNeedsPaint();
    }
  }

  Path createPath(Size size, _ChildParentData childData) {
    final maskWidth = size.width - childData.sideWidth;

    final Path path = Path();
    path.lineTo(maskWidth, 0);
    path.lineTo(maskWidth, childData.waveCenterY - childData.waveVertRadius);
    path.cubicTo(
      maskWidth,
      childData.waveCenterY - childData.waveVertRadius * 0.475,
      maskWidth - childData.waveHorRadius,
      childData.waveCenterY - childData.waveVertRadius * 0.475,
      maskWidth - childData.waveHorRadius,
      childData.waveCenterY,
    );
    path.cubicTo(
      maskWidth - childData.waveHorRadius,
      childData.waveCenterY + childData.waveVertRadius * 0.465,
      maskWidth,
      childData.waveCenterY + childData.waveVertRadius * 0.465,
      maskWidth,
      childData.waveCenterY + childData.waveVertRadius,
    );
    path.lineTo(maskWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  void forEachChild(ForChildCallback callback) {
    int index = 0;
    for (RenderBox child = lastChild; child != null; child = childBefore(child)) {
      callback(index++, child, child.parentData as _ChildParentData);
    }
  }
}

typedef ForChildCallback = void Function(int index, RenderBox child, _ChildParentData data);

class _ChildParentData extends ContainerBoxParentData<RenderBox> {
  int index;
  double progress;
  double waveCenterY;
  double waveHorRadius;
  double waveVertRadius;
  double sideWidth;

  void initLayout(int index, Size size) {
    if (this.index == null) {
      this.offset = Offset.zero;
      this.index = index;
      this.progress = 0.0;
      this.waveCenterY = _LiquidSwipeMath.initialWaveCenter(size.height);
      this.waveHorRadius = _LiquidSwipeMath.waveHorRadius(0.0, size.width);
      this.waveVertRadius = _LiquidSwipeMath.waveVertRadius(0.0, size.width);
      this.sideWidth = _LiquidSwipeMath.sideWidth(0.0, size.width);
    }
  }

  @override
  String toString() {
    return '_ChildParentData{index: $index, waveCenterY: $waveCenterY, '
        'waveHorRadius: $waveHorRadius, waveVertRadius: $waveVertRadius, sideWidth: $sideWidth}';
  }
}
