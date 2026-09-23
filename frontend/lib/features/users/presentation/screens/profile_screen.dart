import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/features/auth/presentation/auth_bloc.dart';
import 'package:expense_tracker/features/users/presentation/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileStarted());
  }

  Future<void> _editProfile() async {
    final bloc = context.read<ProfileBloc>();
    final user = bloc.state.user;
    if (user == null) return;
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'Name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: emailController,
                  label: 'Email',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: passwordController,
                  label: 'New password (optional)',
                  hintText: 'Leave blank to keep current',
                  prefixIcon: Icons.lock_outline_rounded,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            GradientButton(
              label: 'Save',
              expanded: false,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      bloc.add(
        ProfileUpdated(
          name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
          email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
          password: passwordController.text.isEmpty ? null : passwordController.text,
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete account',
      message: 'This permanently deletes your account and all data. Continue?',
      confirmLabel: 'Delete account',
    );
    if (!confirmed) return;
    if (!mounted) return;
    context.read<ProfileBloc>().add(const ProfileDeleted());
  }

  Future<void> _signOut() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign out',
      destructive: false,
    );
    if (!confirmed) return;
    if (!mounted) return;
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            current.deleted ||
            (current.failure != null && current.failure != previous.failure),
        listener: (context, state) {
          if (state.deleted) {
            context.read<AuthBloc>().add(const AuthSignOutRequested());
            return;
          }
          final failure = state.failure;
          if (failure != null) {
            showAppSnack(context, failure.message, isError: true);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ProfileBloc>().add(const ProfileRefreshed()),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 10),
                _buildIdentity(state),
                const SizedBox(height: 20),
                _buildMenuSection(context),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667085).withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.delete_forever_rounded,
                        iconColor: AppColors.expense,
                        label: 'Delete account',
                        onTap: _deleteAccount,
                        loading: state.isDeleting,
                      ),
                    ],
                  ),
                ),
                if (state.version != null) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'monex v${state.version}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.hint,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdentity(ProfileState state) {
    final user = state.user;
    final name = user?.name ?? '…';
    final email = user?.email ?? '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667085).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.buttonGradient,
            ),
            alignment: Alignment.center,
            child: Text(
              user?.initials ?? '?',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (state.isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667085).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.category_outlined,
            iconColor: AppColors.primary,
            label: 'Manage categories',
            onTap: () => context.push('/categories'),
          ),
          const Divider(height: 1, color: Color(0xFFEDF0F4)),
          _MenuTile(
            icon: Icons.edit_outlined,
            iconColor: AppColors.primary,
            label: 'Edit profile',
            onTap: _editProfile,
            loading: stateUpdating,
          ),
          const Divider(height: 1, color: Color(0xFFEDF0F4)),
          _MenuTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.expense,
            label: 'Sign out',
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  bool get stateUpdating => context.watch<ProfileBloc>().state.isUpdating;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.hint,
              ),
          ],
        ),
      ),
    );
  }
}