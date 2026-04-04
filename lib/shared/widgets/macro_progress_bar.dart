import 'package:flutter/material.dart';
import '../../features/auth/presentation/cubit/profile_cubit.dart';
import '../../features/auth/domain/models/auth_enums.dart';
import '../../core/utils/unit_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final int currentAmount;
  final int targetAmount;
  final Color color;
  final double height;
  final Duration animationDuration;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.currentAmount,
    required this.targetAmount,
    required this.color,
    this.height = 8.0,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percentage =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final useMetric = state.maybeWhen(
          loaded: (p, _, _, _, _, _, _) => p.weightUnit == WeightUnit.kg,
          orElse: () => true,
        );
        final unitHelper = UnitHelper(useMetric: useMetric);
        final unit = unitHelper.weightUnit;

        return Semantics(
          label: '$label progress',
          value: '$currentAmount of $targetAmount$unit',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$currentAmount / $targetAmount$unit',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: percentage),
                          duration: animationDuration,
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Container(
                              width: constraints.maxWidth * value,
                              height: height,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(height / 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
