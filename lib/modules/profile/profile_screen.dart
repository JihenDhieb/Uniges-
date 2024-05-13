import 'package:flutter/material.dart';
import 'package:uniges/modules/profile/profile_cards_widget.dart';
import 'package:uniges/modules/profile/profile_pic_widget.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "My Account",
              icon: Icon(Icons.person_outline_rounded),
              press: () => {},
            ),
            ProfileMenu(
              text: "Notifications",
              icon: Icon(Icons.notifications_none),
              press: () {},
            ),
            ProfileMenu(
              text: "Settings",
              icon: Icon(Icons.settings_suggest_outlined),
              press: () {},
            ),
            ProfileMenu(
              text: "Help Center",
              icon: Icon(Icons.live_help_outlined),
              press: () {},
            ),
            ProfileMenu(
              text: "Log Out",
              icon: Icon(Icons.logout_outlined),
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}
