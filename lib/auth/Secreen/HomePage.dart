import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartgarage/screens/cateegory/CategoryListScreen.dart';
import 'package:smartgarage/screens/motos/moto_list_screen.dart';
import 'package:smartgarage/screens/parts_list_screen.dart';
import 'package:smartgarage/screens/purchase/add_purchase_screen.dart';
import 'package:smartgarage/screens/purchase/cleint/ClientsListScreen.dart';
import 'package:smartgarage/screens/user/usersecreen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebLayout = screenWidth > 800;

    final List<Widget> _pages = [
      PartsListScreen(isAdmin: true),
      ProfileScreen(user: user),
      ClientsListScreen(),
      AddPurchaseScreen(),
      CategoryListScreen(isAdmin: true),
    ];

    final List<NavItem> navItems = [
      NavItem(icon: Icons.inventory_2_outlined, title: "Parts", index: 0),
      NavItem(icon: Icons.person_outline_rounded, title: "Profile", index: 1),
      NavItem(icon: Icons.people_outline, title: "Clients", index: 2),
      NavItem(icon: Icons.shopping_cart_outlined, title: "Purchases", index: 3),
      NavItem(icon: Icons.category_outlined, title: "Categories", index: 4),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isWebLayout
          ? Row(
              children: [
                // Side Navigation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isExpanded ? 260 : 100,
                  child: _buildSideNav(navItems, user),
                ),
                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      _buildWebAppBar(user, screenWidth),
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            child: _pages[_selectedIndex],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : _buildMobileLayout(_pages, navItems, user),
    );
  }

  Widget _buildSideNav(List<NavItem> navItems, User? user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Image.asset("assets/logo2.png", height: 20, width: 20),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Smart Garage",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.menu_open : Icons.menu,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = _selectedIndex == item.index;
                return _buildNavItem(item, isSelected);
              },
            ),
          ),
          // User Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  backgroundColor: Colors.teal.shade100,
                  child: user?.photoURL == null
                      ? Icon(
                          Icons.person,
                          size: 22,
                          color: Colors.teal.shade700,
                        )
                      : null,
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "User",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedIndex = item.index;
              _animationController.reset();
              _animationController.forward();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.teal.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.teal : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? Colors.teal : Colors.grey.shade600,
                  size: 24,
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected ? Colors.teal : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebAppBar(User? user, double screenWidth) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getPageTitle(_selectedIndex),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPageSubtitle(_selectedIndex),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Action Buttons
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.grey.shade700,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey.shade700),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    List<Widget> pages,
    List<NavItem> navItems,
    User? user,
  ) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Image.asset("assets/logo2.png", height: 32, width: 32),
            const SizedBox(width: 12),
            Text(
              _getPageTitle(_selectedIndex),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 20, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.map((item) {
                final isSelected = _selectedIndex == item.index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = item.index;
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? Colors.teal : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.teal : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return "Parts Inventory";
      case 1:
        return "Profile";
      case 2:
        return "Clients Management";
      case 3:
        return "Purchase Orders";
      case 4:
        return "Categories";
      default:
        return "Smart Garage";
    }
  }

  String _getPageSubtitle(int index) {
    switch (index) {
      case 0:
        return "Manage your spare parts and inventory";
      case 1:
        return "View and edit your profile information";
      case 2:
        return "Manage customer information and history";
      case 3:
        return "Track and manage purchase orders";
      case 4:
        return "Organize parts by categories";
      default:
        return "";
    }
  }
}

class NavItem {
  final IconData icon;
  final String title;
  final int index;

  NavItem({required this.icon, required this.title, required this.index});
}
