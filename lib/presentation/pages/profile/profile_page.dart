
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: authProvider.userProfile?.photoUrl != null
                        ? CachedNetworkImageProvider(authProvider.userProfile!.photoUrl!)
                        : null,
                    child: authProvider.userProfile?.photoUrl == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.userProfile?.name ?? 'Usuário',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authProvider.userProfile?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  if (authProvider.userProfile?.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      authProvider.userProfile!.phone!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Profile Options
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileOption(
                    context,
                    icon: Icons.person_outline,
                    title: 'Editar Perfil',
                    subtitle: 'Nome, telefone, foto',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Meus Endereços',
                    subtitle: 'Gerenciar endereços de entrega',
                    onTap: () => context.push('/profile/address'),
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Histórico de Pedidos',
                    subtitle: 'Ver pedidos anteriores',
                    onTap: () => context.push('/orders/history'),
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.favorite_outline,
                    title: 'Favoritos',
                    subtitle: 'Restaurantes e pratos salvos',
                    onTap: () {
                      // Handle favorites
                    },
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema',
                    subtitle: themeProvider.isDarkMode ? 'Modo escuro' : 'Modo claro',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    subtitle: 'Configurar alertas',
                    onTap: () {
                      // Handle notifications settings
                    },
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.help_outline,
                    title: 'Ajuda',
                    subtitle: 'FAQ e suporte',
                    onTap: () {
                      // Handle help
                    },
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.info_outline,
                    title: 'Sobre',
                    subtitle: 'Versão e informações',
                    onTap: () {
                      // Handle about
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileOption(
                    context,
                    icon: Icons.logout,
                    title: 'Sair',
                    subtitle: 'Fazer logout da conta',
                    onTap: () => _handleSignOut(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Provider.of<CartProvider>(context).isNotEmpty
          ? FloatingCartButton(
              itemCount: Provider.of<CartProvider>(context).itemCount,
              total: Provider.of<CartProvider>(context).total,
              onTap: () => context.push('/cart'),
            )
          : null,
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? theme.colorScheme.error.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive 
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive 
                ? theme.colorScheme.error
                : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sair'),
        content: Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sair'),
          ),
        ],
      ),
    );

    if (result == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      context.go('/auth/login');
    }
  }
}
