part of 'flutter_painter.dart';

/// Flutter widget to detect user input and request drawing [FreeStyleDrawable]s.
class _FreeStyleWidget extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Creates a [_FreeStyleWidget] with the given [controller], [child] widget.
  const _FreeStyleWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _FreeStyleWidgetState createState() => _FreeStyleWidgetState();
}

/// State class
class _FreeStyleWidgetState extends State<_FreeStyleWidget> {
  /// The current drawable being drawn.
  PathDrawable? drawable;

  @override
  Widget build(BuildContext context) {
    if (settings.mode == FreeStyleMode.none || shapeSettings.factory != null) {
      return widget.child;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        _DragGestureDetector:
            GestureRecognizerFactoryWithHandlers<_DragGestureDetector>(
          () => _DragGestureDetector(
            onHorizontalDragDown: _handleHorizontalDragDown,
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            onHorizontalDragUp: _handleHorizontalDragUp,
            onScaling: _handleScaling,
          ),
          (_) {},
        ),
      },
      child: widget.child,
    );
  }

  /// Getter for [FreeStyleSettings] from `widget.controller.value` to make code more readable.
  FreeStyleSettings get settings =>
      PainterController.of(context).value.settings.freeStyle;

  /// Getter for [ShapeSettings] from `widget.controller.value` to make code more readable.
  ShapeSettings get shapeSettings =>
      PainterController.of(context).value.settings.shape;

  /// Callback when the user holds their pointer(s) down onto the widget.
  void _handleHorizontalDragDown(Offset globalPosition) {
    // If the user is already drawing, don't create a new drawing
    if (this.drawable != null) return;
    // Create a new free-style drawable representing the current drawing
    final PathDrawable drawable;
    switch (settings.mode) {
      case FreeStyleMode.draw:
      case FreeStyleMode.drawSmooth:
        // get ruler drawable if present
        final ruler = PainterController.of(context)
                .drawables
                .firstWhereOrNull((element) => element is RulerDrawable)
            as RulerDrawable?;
        if (ruler != null) {
          // get pointer position
          final localPosition = _globalToLocal(
            globalPosition,
            clipToRuler: false,
          );

          // check if pointer is inside ruler
          final rulerRect = Rect.fromCenter(
            center: ruler.position,
            width: ruler.getSize().width,
            height: ruler.getSize().height,
          );

          if (rulerRect.contains(localPosition)) {
            // switch to move mode
            PainterController.of(context).freeStyleMode = FreeStyleMode.none;
            PainterController.of(context).selectObjectDrawable(ruler);
            return;
          }

          ruler.setSide(
            localPosition.rotate(
              -ruler.rotationAngle,
              origin: ruler.position,
            ),
          );
        }

        // Create a new free-style drawable representing the current drawing
        if (settings.mode == FreeStyleMode.draw) {
          drawable = FreeStyleDrawable(
            path: [_globalToLocal(globalPosition)],
            strokeWidth: settings.strokeWidth,
            color: settings.color,
          );
        } else {
          drawable = SmoothStyleDrawable(
            path: [_globalToLocal(globalPosition)],
            color: settings.color,
          );
        }

        // Add the drawable to the controller's drawables
        PainterController.of(context).addDrawables([drawable]);
        break;
      case FreeStyleMode.erase:
        drawable = EraseDrawable(
          path: [_globalToLocal(globalPosition)],
          strokeWidth: settings.strokeWidth,
        );
        PainterController.of(context).groupDrawables();

        // Add the drawable to the controller's drawables
        PainterController.of(context)
            .addDrawables([drawable], newAction: false);
        break;
      case FreeStyleMode.none:
        return;
    }

    // Set the drawable as the current drawable
    this.drawable = drawable;
  }

  /// Callback when the user moves, rotates or scales the pointer(s).
  void _handleHorizontalDragUpdate(Offset globalPosition) {
    final drawable = this.drawable;
    // If there is no current drawable, ignore user input
    if (drawable == null) return;

    // Add the new point to a copy of the current drawable
    final newDrawable = drawable.copyWith(
      path: List<Offset>.from(drawable.path)
        ..add(_globalToLocal(globalPosition)),
    );
    // Replace the current drawable with the copy with the added point
    PainterController.of(context)
        .replaceDrawable(drawable, newDrawable, newAction: false);
    // Update the current drawable to be the new copy
    this.drawable = newDrawable;
  }

  /// Callback when the user removes all pointers from the widget.
  void _handleHorizontalDragUp() {
    DrawableCreatedNotification(drawable).dispatch(context);

    /// Reset the current drawable for the user to draw a new one next time
    drawable = null;
  }

  void _handleScaling() {
    PainterController.of(context).undo();
  }

  Offset _globalToLocal(
    Offset globalPosition, {
    bool clipToRuler = true,
  }) {
    final getBox = context.findRenderObject() as RenderBox;

    Offset position = getBox.globalToLocal(globalPosition);

    // check ruler position
    final ruler = PainterController.of(context)
            .drawables
            .firstWhereOrNull((element) => element is RulerDrawable)
        as RulerDrawable?;

    // limit position based on the offsets
    if (ruler != null && clipToRuler) {
      final rulerRect = Rect.fromCenter(
        center: ruler.position,
        width: ruler.getSize().width,
        height: ruler.getSize().height,
      );

      position = position.rotate(-ruler.rotationAngle, origin: ruler.position);

      switch (ruler.side) {
        case RulerSide.left:
          if (position.dx > rulerRect.left) {
            position = Offset(rulerRect.left, position.dy);
          }
          break;
        case RulerSide.right:
          if (position.dx < rulerRect.right) {
            position = Offset(rulerRect.right, position.dy);
          }
          break;
      }
      position = position.rotate(ruler.rotationAngle, origin: ruler.position);
    }

    return position;
  }
}

/// A custom recognizer that recognize at most only one gesture sequence.
class _DragGestureDetector extends OneSequenceGestureRecognizer {
  _DragGestureDetector({
    required this.onHorizontalDragDown,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragUp,
    required this.onScaling,
  });

  final ValueSetter<Offset> onHorizontalDragDown;
  final ValueSetter<Offset> onHorizontalDragUpdate;
  final VoidCallback onHorizontalDragUp;
  final VoidCallback onScaling;

  bool _isTrackingGesture = false;
  bool _isZooming = false;

  @override
  void addPointer(PointerEvent event) {
    if (!_isTrackingGesture) {
      resolve(GestureDisposition.accepted);
      startTrackingPointer(event.pointer);
      _isTrackingGesture = true;
      _isZooming = false;
    } else {
      onScaling();
      stopTrackingPointer(event.pointer);
      _isZooming = true;
      _isTrackingGesture = false;
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (_isZooming) {
      onHorizontalDragUp();
      stopTrackingPointer(event.pointer);
      _isTrackingGesture = false;
      return;
    }
    if (event is PointerDownEvent) {
      onHorizontalDragDown(event.position);
    } else if (event is PointerMoveEvent) {
      onHorizontalDragUpdate(event.position);
    } else if (event is PointerUpEvent) {
      onHorizontalDragUp();
      stopTrackingPointer(event.pointer);
      _isTrackingGesture = false;
      _isZooming = false;
    }
  }

  @override
  String get debugDescription => '_DragGestureDetector';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
