import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeToReplyWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;
  final bool isCurrentUser;

  const SwipeToReplyWrapper({
    Key? key,
    required this.child,
    required this.onReply,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  _SwipeToReplyWrapperState createState() => _SwipeToReplyWrapperState();
}

class _SwipeToReplyWrapperState extends State<SwipeToReplyWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragExtent = 0;
  bool _dragUnderway = false;
  final double _maxDragDistance = 100.0;
  final double _replyThreshold = 60.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    _animationController.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;

    final delta = details.primaryDelta ?? 0;

    // For current user messages, swipe from right to left (negative direction)
    // For other user messages, swipe from left to right (positive direction)
    if (widget.isCurrentUser) {
      // Current user: allow left swipe (negative delta)
      if (delta < 0) {
        _dragExtent = (_dragExtent + delta).clamp(-_maxDragDistance, 0.0);
      }
    } else {
      // Other user: allow right swipe (positive delta)
      if (delta > 0) {
        _dragExtent = (_dragExtent + delta).clamp(0.0, _maxDragDistance);
      }
    }

    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;

    _dragUnderway = false;

    // Check if we've reached the reply threshold
    final shouldReply = _dragExtent.abs() >= _replyThreshold;

    if (shouldReply) {
      // Trigger haptic feedback
      _triggerHapticFeedback();
      // Trigger reply callback
      widget.onReply();
    }

    // Reset the position with animation
    _resetPosition();
  }

  void _resetPosition() {
    final startValue = _dragExtent;

    final animation = Tween<double>(
      begin: startValue,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    animation.addListener(() {
      setState(() {
        _dragExtent = animation.value;
      });
    });

    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {
        _dragExtent = 0;
      });
    });
  }

  void _triggerHapticFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Handle error silently
    }
  }

  double get _iconScale {
    final progress = (_dragExtent.abs() / _maxDragDistance).clamp(0.0, 1.0);
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Reply icon background
          if (_dragExtent != 0)
            Positioned.fill(
              child: Container(
                alignment: widget.isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Transform.scale(
                  scale: _iconScale,
                  child: Container(
                    width: width * 0.08,
                    height: width * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                    child: Icon(
                      Icons.reply,
                      color: Colors.white,
                      size: width * 0.04,
                    ),
                  ),
                ),
              ),
            ),
          // Message content
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}