// lib/widgets/custom_notification.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlideTransitionNotification extends StatefulWidget {
  final VoidCallback onRemove;
  final String title;
  final String message;
  const SlideTransitionNotification({
    super.key,
    required this.onRemove,
    required this.title,
    required this.message,
  });

  @override
  State<SlideTransitionNotification> createState() =>
      _SlideTransitionNotificationState();
}

class _SlideTransitionNotificationState
    extends State<SlideTransitionNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    // Ubah arah animasi di sini
    _slideAnimation =
        Tween(begin: const Offset(0, 2.0), end: const Offset(0, 0)).animate( 
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onRemove();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF2D3748);
    const Color accentColor = Color(0xFFF6C634);

    return SlideTransition(
      position: _slideAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: darkColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: accentColor, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: darkColor, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (widget.message.isNotEmpty)
                    Text(widget.message,
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}