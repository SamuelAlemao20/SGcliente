import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();
    if (context.mounted) {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        // O AppBar só aparece se a tela for acessada diretamente.
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildProfileHeader(context, user),
                _buildProfileOption(
                  context,
                  icon: Icons.person_outline,
                  title: 'Editar Perfil',
                  onTap: () {/* Navegar para a tela de edição */},
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Meus Endereços',
                  onTap: () {/* Navegar para a tela de endereços */},
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Histórico de Pedidos',
                  onTap: () => context.go('/orders/history'),
                ),
                _buildThemeSwitcher(context),
                const Divider(),
                _buildProfileOption(
                  context,
                  icon: Icons.logout,
                  title: 'Sair',
                  isDestructive: true,
                  onTap: () => _handleSignOut(context),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoUrl != null
                ? CachedNetworkImageProvider(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(user.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(user.email,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon,
      required String title,
      VoidCallback? onTap,
      bool isDestructive = false}) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeSwitcher(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode_outlined),
      title: const Text('Modo Escuro'),
      value: themeProvider.isDarkMode,
      onChanged: (_) => themeProvider.toggleTheme(),
    );
  }
}
