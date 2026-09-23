import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'CUPRA Instant Drive, fiktiver Prototyp',
    container: true,
    excludeSemantics: true,
    child: compact
        ? SvgPicture.asset(
            'assets/branding/cupra-logo.svg',
            width: 88,
            height: 24,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppColors.copper,
              BlendMode.srcIn,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/branding/cupra-logo.svg',
                width: 130,
                height: 28,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.copper,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.muted),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'INSTANT DRIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
  );
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({
    super.key,
    this.text =
        'Sandbox · Keine echte Zahlung, Verifizierung oder Fahrzeugsteuerung',
  });
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.copper.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.copper.withValues(alpha: .45)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.science_outlined, size: 19, color: AppColors.copper),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: AppColors.cream,
            ),
          ),
        ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.kicker, this.action});
  final String title;
  final String? kicker;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kicker != null) ...[
              Text(
                kicker!.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.copper,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
      ),
      ?action,
    ],
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(
    this.label, {
    super.key,
    this.color = AppColors.success,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: .45)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class PageWidth extends StatelessWidget {
  const PageWidth({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 36),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1160),
      child: Padding(padding: padding, child: child),
    ),
  );
}

Future<void> showInfoDialog(
  BuildContext context,
  String title,
  String message,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Verstanden'),
      ),
    ],
  ),
);
