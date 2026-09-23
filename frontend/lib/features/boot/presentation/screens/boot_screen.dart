import 'dart:async';
import 'dart:math' as math;

import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/features/boot/presentation/boot_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  final _statusMessages = const [
    'Connecting to server…',
    'Waking up backend…',
    'Loading your space…',
    'Almost there…',
  ];
  int _statusIndex = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _statusTimer = Timer.periodic(
      const Duration(milliseconds: 900),
      (_) => setState(() =>
          _statusIndex = (_statusIndex + 1) % _statusMessages.length),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BootCubit>().start();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pulse.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _Backdrop(),
            BlocBuilder<BootCubit, BootState>(
              builder: (context, state) {
                switch (state.status) {
                  case BootStatus.connecting:
                    return _buildConnecting();
                  case BootStatus.ready:
                    return _buildReady();
                  case BootStatus.failed:
                    return _buildFailed(state);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnecting() {
    return _AnimatedEntrance(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LogoOrb(pulse: _pulse, glow: _glow),
          const SizedBox(height: 40),
          const Text(
            'Paisa Book',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 28),
          _StatusDots(color: AppColors.primary),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            child: Text(
              _statusMessages[_statusIndex],
              key: ValueKey(_statusIndex),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReady() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.buttonGradient,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailed(BootState state) {
    return _AnimatedEntrance(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.expense,
                size: 44,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "Can't reach server",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.failure?.message ??
                  'Make sure you are connected to the internet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 30),
            GradientButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              expanded: false,
              onPressed: () => context.read<BootCubit>().start(),
            ),
            const SizedBox(height: 12),
            Text(
              'Attempt ${state.attempts}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.background,
                  AppColors.accent.withValues(alpha: 0.06),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _Blob(
            size: 260,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -90,
          child: _Blob(
            size: 300,
            color: AppColors.accent.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatefulWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_Blob> createState() => _BlobState();
}

class _BlobState extends State<_Blob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 6000),
  )..repeat(reverse: true);

  late final Animation<double> _dx = Tween(begin: -20.0, end: 24.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  late final Animation<double> _dy = Tween(begin: 0.0, end: -30.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Transform.translate(
        offset: Offset(_dx.value, _dy.value),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color,
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoOrb extends StatelessWidget {
  const _LogoOrb({required this.pulse, required this.glow});

  final AnimationController pulse;
  final AnimationController glow;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, _) {
        final g = math.sin(glow.value * 2 * math.pi).abs();
        return Container(
          width: 148,
          height: 148,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + g * 0.25,
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35 - g * 0.2),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8 + g * 0.3,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 26 + g * 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: pulse,
                builder: (context, _) => Transform.scale(
                  scale: 0.92 + pulse.value * 0.1,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.buttonGradient,
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusDots extends StatefulWidget {
  const _StatusDots({required this.color});

  final Color color;

  @override
  State<_StatusDots> createState() => _StatusDotsState();
}

class _StatusDotsState extends State<_StatusDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value * 3 - index).clamp(0.0, 1.0);
            return Opacity(
              opacity: 1 - phase * 0.6,
              child: Transform.scale(
                scale: 1 - phase * 0.4,
                child: Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _AnimatedEntrance extends StatelessWidget {
  const _AnimatedEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: child,
    );
  }
}