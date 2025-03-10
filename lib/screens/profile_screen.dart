import 'package:flutter/material.dart';
import 'package:source_code_mobile/widgets/gradient_app_bar.dart';
import '../widgets/gradient_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double inputWidth = screenWidth * 0.9; // Giảm chiều rộng form

    return GradientContainer(
      scaffold: Scaffold(
        appBar: const GradientAppBar(title: 'Profile'),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Giảm padding từ 20 xuống 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar
                Container(
                  width: 100, // Giảm avatar từ 120 xuống 100
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),

                // Divider trên "Personal Information"
                _buildDivider(),

                // Personal Information
                _buildSectionTitle("Personal Information"),
                _buildTextField("Name", inputWidth),
                _buildTextField("Phone", inputWidth),
                _buildTextField("Email", inputWidth),
                _buildTextField("Name", inputWidth),

                // Divider trên "Manage Account"
                _buildDivider(),

                _buildSectionTitle("Manage Account"),
                _buildButton("Logout", Icons.logout, inputWidth),
                _buildButton("Reset password", Icons.remove_red_eye, inputWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12), // Giảm khoảng cách giữa các phần
      child: Container(
        width: double.infinity,
        height: 1.5,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Giảm khoảng cách
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16, // Giảm font chữ từ 18 xuống 16
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Giảm khoảng cách giữa các ô input
      child: SizedBox(
        width: width,
        child: TextField(
          style: const TextStyle(fontSize: 14), // Giảm kích thước chữ trong input
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6), // Giảm bo góc
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Giảm khoảng cách giữa các nút
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6), // Giảm bo góc
        child: SizedBox(
          width: width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 12), // Giảm chiều cao nút
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black, fontSize: 14), // Giảm font chữ của nút
                ),
                const SizedBox(width: 8), // Giữ khoảng cách giữa chữ và icon
                Icon(icon, color: Colors.black, size: 22), // Giảm size icon
              ],
            ),
          ),
        ),
      ),
    );
  }
}
