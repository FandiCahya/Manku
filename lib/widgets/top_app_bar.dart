import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: 16,
      ),
      color: context.colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Section - Profile & Greeting
          Flexible(
            child: Row(
              children: [
                // Profile Avatar
                Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDrYEcxtKZ3JEZ_94TF_CWfrdbR8WNY0KWvkAxClzIiN8oG0mWa9Tcy6s4wAx35udDaL7MVPd-cUY7uSrbZhGBGJQvJFcI6SKtZkhSe3X-VFNeJ1ZFPXZgwEAifpCZ7UZLHQpV76fMPc5EmZZuclE5fYLC_onN0l4tFAXk1_zVWVfmfQS8t1_TankrBex9d4tkOOzP0prn_ZbvfzxBothFU2aWb2N5dvQabAR_3Ime0mq8swE8dMY2Na_i2fLk94XoaAB0GDpW1ZvI',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: context.colors.primary,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                // Greeting
                Flexible(
                  child: Text(
                    'Hello, Saver!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Right Section - Notification
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: context.colors.primary,
            ),
            onPressed: () {},
            tooltip: 'Notifications',
            iconSize: isSmallScreen ? 20 : 24,
          ),
        ],
      ),
    );
  }
}
