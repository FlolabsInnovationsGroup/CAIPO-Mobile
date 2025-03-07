import 'package:flutter/material.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  _AccountProfilePageState createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account & Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOption('Name', 'John Doe', Icons.person, () {}),
            _buildProfileOption('Email', 'johndoe@example.com', Icons.email, () {}),
            _buildProfileOption('Phone', '+1 234 567 890', Icons.phone, () {}),
            _buildProfileOption('Change Password', '********', Icons.lock, () {}),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(String title, String value, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
