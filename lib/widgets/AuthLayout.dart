import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackButtonTap;

  const AuthLayout({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackButtonTap, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 0),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onPressed: onBackButtonTap ?? () => Navigator.pop(context),
                  ),
                )
              else
                const SizedBox(height: 20),
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                    height: 1.0,
                  ),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
