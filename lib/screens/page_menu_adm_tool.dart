// TODO Implement this library.
import 'package:flutter/material.dart';

class PageMenuAdmTool extends StatefulWidget {
  const PageMenuAdmTool({super.key});

  @override
  State<PageMenuAdmTool> createState() => _PageMenuAdmToolState();
}

class _PageMenuAdmToolState extends State<PageMenuAdmTool>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
