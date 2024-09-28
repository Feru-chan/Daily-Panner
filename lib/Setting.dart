import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:provider/provider.dart';
import 'package:testpj/themeprovider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                title: Text('Dark Mode'),
                trailing: AnimatedToggleSwitch<bool>.dual(
                  current: themeProvider.isDarkMode,
                  first: false,
                  second: true,
                  spacing: 0.0,
                  style: ToggleStyle(
                    borderColor: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                  height: 55,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  styleBuilder: (value) => ToggleStyle(
                    backgroundColor: value ? Colors.black : Colors.white,
                  ),
                  iconBuilder: (value) => value
                      ? Icon(Icons.dark_mode, color: Colors.white)
                      : Icon(Icons.light_mode, color: Colors.yellow),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}