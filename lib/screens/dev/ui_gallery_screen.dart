import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../widgets/ui/ui.dart';

/// A temporary visual gallery for the shared UI primitives.
class UiGalleryScreen extends StatefulWidget {
  const UiGalleryScreen({super.key});

  @override
  State<UiGalleryScreen> createState() => _UiGalleryScreenState();
}

class _UiGalleryScreenState extends State<UiGalleryScreen> {
  ThemeController? _themeController;

  @override
  void initState() {
    super.initState();
    _loadThemeController();
  }

  Future<void> _loadThemeController() async {
    final controller = await ThemeController.load();
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _themeController = controller);
  }

  @override
  void dispose() {
    _themeController?.dispose();
    super.dispose();
  }

  void _setThemeMode(ThemeMode mode) {
    final controller = _themeController;
    if (controller != null) unawaited(controller.setThemeMode(mode));
  }

  @override
  Widget build(BuildContext context) {
    final controller = _themeController;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    if (controller == null) {
      return _buildThemedGallery(ThemeMode.system, platformBrightness);
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) =>
          _buildThemedGallery(controller.themeMode, platformBrightness),
    );
  }

  Widget _buildThemedGallery(ThemeMode mode, Brightness platformBrightness) {
    final brightness = switch (mode) {
      ThemeMode.system => platformBrightness,
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
    };
    final theme = brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;

    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('UI Gallery'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            children: [
              SectionHeader(
                title: 'Theme mode',
                subtitle: 'System appearance or a local preview',
              ),
              SegmentedTabs<ThemeMode>(
                items: const [
                  SegmentedTabItem(value: ThemeMode.system, label: 'System'),
                  SegmentedTabItem(value: ThemeMode.light, label: 'Light'),
                  SegmentedTabItem(value: ThemeMode.dark, label: 'Dark'),
                ],
                selected: mode,
                onChanged: _setThemeMode,
              ),
              SectionHeader(
                title: 'Surfaces and metrics',
                subtitle: 'Neutral, brand, and AQI tones',
                icon: Icons.dashboard_outlined,
              ),
              AppCard(
                onTap: () {},
                child: Text(
                  'Tap-enabled neutral card',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const AppCard(
                tone: AppCardTone.brand,
                child: Text('Soft brand surface'),
              ),
              const SizedBox(height: AppSpacing.md),
              const AppCard(
                tone: AppCardTone.aqiLevel,
                aqiLevel: AqiLevel.unhealthySensitive,
                child: Text('AQI-tinted surface'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.md,
                children: const [
                  StatTile(
                    icon: Icons.air,
                    label: 'Current AQI',
                    value: '42',
                    caption: 'Good air quality',
                  ),
                  StatTile(
                    icon: Icons.speed,
                    label: 'PM2.5',
                    value: '18.6',
                    caption: 'Micrograms per cubic meter',
                  ),
                ],
              ),
              SectionHeader(title: 'Status and messages'),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: const [
                  StatusPill.aqi(32),
                  StatusPill.aqi(82),
                  StatusPill.aqi(142),
                  StatusPill.aqi(186),
                  StatusPill.aqi(260),
                  StatusPill.aqi(410),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                title: 'Location permission missing',
                message: 'Allow location access to show nearby air readings.',
                actionLabel: 'Enable',
                onAction: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              const InfoBanner(
                title: 'Forecast updated',
                message: 'The latest neighborhood forecast is ready.',
                tone: InfoBannerTone.success,
              ),
              const SizedBox(height: AppSpacing.sm),
              const InfoBanner(
                title: 'Elevated pollution expected',
                message: 'Sensitive groups may want to reduce outdoor activity.',
                tone: InfoBannerTone.warning,
              ),
              const SizedBox(height: AppSpacing.sm),
              const InfoBanner(
                title: 'Sensor unavailable',
                message: 'The nearest station has not reported recently.',
                tone: InfoBannerTone.error,
              ),
              SectionHeader(title: 'Controls and loading'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ToggleRow(
                      leading: const Icon(Icons.notifications_outlined),
                      title: 'Pollution alerts',
                      subtitle: 'Notify when AQI rises',
                      trailingValue: 'On',
                      value: true,
                      onChanged: (_) {},
                      showDivider: true,
                    ),
                    ToggleRow(
                      title: 'Weekly summary',
                      subtitle: 'A digest every Monday',
                      value: false,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedTabs<String>(
                items: const [
                  SegmentedTabItem(value: 'day', label: 'Day'),
                  SegmentedTabItem(value: 'week', label: 'Week'),
                  SegmentedTabItem(value: 'month', label: 'Month'),
                ],
                selected: 'week',
                onChanged: (_) {},
              ),
              const SizedBox(height: AppSpacing.md),
              const Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SkeletonBox(width: AppSpacing.xxxl * 3, height: AppSpacing.md),
                  SkeletonBox(width: AppSpacing.xxxl * 2, height: AppSpacing.md),
                  SkeletonBox(width: AppSpacing.xxxl * 4, height: AppSpacing.xl),
                ],
              ),
              SectionHeader(title: 'Empty and animated states'),
              AppCard(
                child: EmptyState(
                  icon: Icons.sensors_off_outlined,
                  title: 'No station data',
                  message: 'Nearby stations have not reported yet.',
                  actionLabel: 'Refresh',
                  onAction: _refresh,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animated AQI',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const AnimatedNumber(value: 128.4, decimals: 1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Updates with tabular figures',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'Current tone: ${brightness.name}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _refresh() {}
}