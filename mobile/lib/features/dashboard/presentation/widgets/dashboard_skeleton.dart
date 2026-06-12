// lib/features/dashboard/presentation/widgets/dashboard_skeleton.dart

import 'package:flutter/material.dart';
import '../../../../../shared/widgets/skeleton_loader.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 200, height: 22),
                  ],
                ),
              ),
              SkeletonBox(width: 44, height: 44, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 24),

          // 2x2 stat grid
          Row(
            children: [
              Expanded(child: _StatSkeleton()),
              const SizedBox(width: 10),
              Expanded(child: _StatSkeleton()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatSkeleton()),
              const SizedBox(width: 10),
              Expanded(child: _StatSkeleton()),
            ],
          ),
          const SizedBox(height: 28),

          // Section header
          const SkeletonBox(width: 160, height: 16),
          const SizedBox(height: 14),

          // Horizontal scroll placeholders
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => const SkeletonBox(
                  width: 160, height: 130, borderRadius: 14),
            ),
          ),
          const SizedBox(height: 28),

          // Section header
          const SkeletonBox(width: 160, height: 16),
          const SizedBox(height: 14),

          // Deadline items
          const SkeletonList(count: 3),
        ],
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(height: 88, borderRadius: 14);
  }
}
