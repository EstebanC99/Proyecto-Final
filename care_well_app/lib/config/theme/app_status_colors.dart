import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.strengthWeak,
    required this.strengthMedium,
    required this.strengthStrong,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;
  final Color strengthWeak;
  final Color strengthMedium;
  final Color strengthStrong;

  static const light = AppStatusColors(
    success: AppColors.success,
    successContainer: AppColors.successContainer,
    warning: AppColors.warning,
    warningContainer: AppColors.warningContainer,
    info: AppColors.info,
    infoContainer: AppColors.infoContainer,
    strengthWeak: AppColors.strengthWeak,
    strengthMedium: AppColors.strengthMedium,
    strengthStrong: AppColors.strengthStrong,
  );

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? strengthWeak,
    Color? strengthMedium,
    Color? strengthStrong,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      strengthWeak: strengthWeak ?? this.strengthWeak,
      strengthMedium: strengthMedium ?? this.strengthMedium,
      strengthStrong: strengthStrong ?? this.strengthStrong,
    );
  }

  @override
  AppStatusColors lerp(AppStatusColors? other, double t) {
    if (other == null) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      strengthWeak: Color.lerp(strengthWeak, other.strengthWeak, t)!,
      strengthMedium: Color.lerp(strengthMedium, other.strengthMedium, t)!,
      strengthStrong: Color.lerp(strengthStrong, other.strengthStrong, t)!,
    );
  }
}
