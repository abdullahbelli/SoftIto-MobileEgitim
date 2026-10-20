import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../controller/venture_tracking_controller.dart';
import '../models/venture_stage.dart';
import '../widget/gantt_chart_view.dart';
import '../widget/opportunity_card.dart';
import '../widget/stage_timeline_card.dart';

/// Girişim Süreci Takibi Ana Sayfası (Gantt Şeması, Aşamalar ve İş Olanakları ile)
class VentureTrackingView extends StatefulWidget {
  final VentureTrackingController controller;
  final ThemeController themeController;

  const VentureTrackingView({
    super.key,
    required this.controller,
    required this.themeController,
  });

  @override
  State<VentureTrackingView> createState() => _VentureTrackingViewState();
}

class _VentureTrackingViewState extends State<VentureTrackingView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Girişim Süreci Takibi'),
        actions: [
          AppThemeToggleButton(themeController: widget.themeController),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.waterfall_chart_rounded), text: 'Gantt Şeması'),
            Tab(icon: Icon(Icons.playlist_add_check_rounded), text: 'Aşamalar'),
            Tab(icon: Icon(Icons.trending_up_rounded), text: 'İş Olanakları'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const BrandPaletteBar(height: 3),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _GanttTab(controller: widget.controller),
                  _StagesTab(controller: widget.controller),
                  _OpportunitiesTab(controller: widget.controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GanttTab extends StatelessWidget {
  final VentureTrackingController controller;
  const _GanttTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<VentureStage>>(
      valueListenable: controller.stages,
      builder: (context, stages, _) {
        return GanttChartView(
          stages: stages,
          onToggleTask: controller.toggleTask,
        );
      },
    );
  }
}

class _StagesTab extends StatelessWidget {
  final VentureTrackingController controller;
  const _StagesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<VentureStage>>(
      valueListenable: controller.stages,
      builder: (context, stages, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: stages.length,
          itemBuilder: (context, index) {
            final stage = stages[index];
            return StageTimelineCard(
              stage: stage,
              onToggleTask: (taskId) => controller.toggleTask(stage.id, taskId),
            );
          },
        );
      },
    );
  }
}

class _OpportunitiesTab extends StatelessWidget {
  final VentureTrackingController controller;
  const _OpportunitiesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BusinessOpportunity>>(
      valueListenable: controller.opportunities,
      builder: (context, opps, _) {
        if (opps.isEmpty) {
          return const Center(
            child: Text(
              'Henüz kayıtlı iş olanağı bulunmuyor.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: opps.length,
          itemBuilder: (context, index) {
            final opp = opps[index];
            return OpportunityCard(opportunity: opp);
          },
        );
      },
    );
  }
}
