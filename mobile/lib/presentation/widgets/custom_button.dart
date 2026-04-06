import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.primaryColor;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: widget.isOutlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDisabled ? Colors.grey : buttonColor,
                    width: 2,
                  ),
                  color: Colors.transparent,
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isDisabled
                      ? null
                      : LinearGradient(
                          colors: [buttonColor, buttonColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isDisabled ? Colors.grey.shade400 : buttonColor,
                  boxShadow: isDisabled || widget.isOutlined
                      ? []
                      : [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isDisabled ? null : widget.onPressed,
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.transparent,
              child: Center(
                child: _buildChild(
                  widget.isOutlined
                      ? (isDisabled ? Colors.grey : buttonColor)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color contentColor) {
    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(color: contentColor, strokeWidth: 3),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: contentColor, size: 22),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: contentColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: contentColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
