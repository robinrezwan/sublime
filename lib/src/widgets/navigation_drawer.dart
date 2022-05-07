import 'package:flutter/material.dart';
import 'package:sublime/src/pages/about_page.dart';
import 'package:sublime/src/pages/settings_page.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/widgets/app_icon_title.dart';

import 'custom_icon_button.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  child: CustomIconButton(
                    icon: const Icon(
                      CustomIcons.chevronLeft,
                      size: 26,
                    ),
                    tooltip: "Back",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: const AppIconTitle(),
                ),
              ],
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                CustomIcons.settings,
                color: Theme.of(context).iconTheme.color,
              ),
              title: const Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                CustomIcons.info,
                color: Theme.of(context).iconTheme.color,
              ),
              title: const Text(
                "About",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
