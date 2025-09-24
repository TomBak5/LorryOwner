import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_dimensions.dart';

class SafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool includeTop;
  final bool includeBottom;
  final EdgeInsets? additionalPadding;

  const SafeAreaWrapper({
    Key? key,
    required this.child,
    this.includeTop = true,
    this.includeBottom = true,
    this.additionalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: includeTop,
      bottom: includeBottom,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: includeBottom ? MediaQuery.of(context).padding.bottom : 0,
          top: includeTop ? MediaQuery.of(context).padding.top : 0,
        ).add(additionalPadding ?? EdgeInsets.zero),
        child: child,
      ),
    );
  }
}

class BottomNavigationSafeArea extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;

  const BottomNavigationSafeArea({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.only(
          topLeft: Radius.circular(8.0.r),
          topRight: Radius.circular(8.0.r),
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: child,
        ),
      ),
    );
  }
}

class BottomSheetSafeArea extends StatelessWidget {
  final Widget child;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const BottomSheetSafeArea({
    Key? key,
    required this.child,
    this.isScrollControlled = true,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: child,
        ),
      ),
    );
  }
}
