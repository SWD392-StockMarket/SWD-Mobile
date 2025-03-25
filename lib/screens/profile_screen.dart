import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:source_code_mobile/models/profile_response.dart';
import 'package:source_code_mobile/models/user_response.dart';
import 'package:source_code_mobile/services/authservice.dart';
import 'package:source_code_mobile/widgets/gradient_app_bar.dart';
import 'package:source_code_mobile/widgets/gradient_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<UserResponse?> _userProfile;
  bool _isEditing = false; // Biến theo dõi trạng thái chỉnh sửa

  // Khai báo các TextEditingController để hiển thị dữ liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subscriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userProfile = _authService.getUserProfile();
  }

  @override
  void dispose() {
    // Giải phóng các controller để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _subscriptionController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout(); // Xóa token
    Navigator.pushReplacementNamed(context, '/'); // Điều hướng về LoginScreen
  }

  Future<void> _updateProfile() async {
    final box = GetStorage();
    final String? userId = box.read<String>('user_id');
    final String? token = box.read<String>('jwt_token');

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID or token is missing')),
      );
      return;
    }

    final updatedUser = UserResponse(
      id: int.parse(userId),
      userName: _nameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      subscriptionStatus: _subscriptionController.text,
      status: "Active", // Giá trị mặc định từ API của bạn
      createdAt: "", // Không cần cập nhật
      lastEdited: DateTime.now().toIso8601String(), // Thời gian chỉnh sửa mới
    );

    final success = await _authService.updateProfile(updatedUser);

    if (success) {
      // Tải lại dữ liệu người dùng từ API
      _userProfile = _authService.getUserProfile();
      setState(() {
        _isEditing = false;
      });
      // Gọi setState để làm mới FutureBuilder
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double inputWidth = screenWidth * 0.9;

    return GradientContainer(
      scaffold: Scaffold(
        appBar: const GradientAppBar(
            title: 'Profile',
            showBackButton: true,
        ),
        backgroundColor: Colors.transparent,
        body: FutureBuilder<UserResponse?>(
          future: _userProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No user data found"));
            }

            final user = snapshot.data!;
            // Cập nhật dữ liệu vào các controller
            _nameController.text = user.userName ?? '';
            _phoneController.text = user.phoneNumber ?? '';
            _emailController.text = user.email ?? '';
            _subscriptionController.text = user.subscriptionStatus ?? '';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDivider(),
                    _buildSectionTitle("Personal Information",  onEdit: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    }),

                    _buildTextField("Name", inputWidth, controller: _nameController),
                    _buildTextField("Email", inputWidth, controller: _emailController),
                    _buildTextField("Phone Number", inputWidth, controller: _phoneController),
                    _buildTextField("Subscription", inputWidth, controller: _subscriptionController),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: SizedBox(
                          width: inputWidth,
                          child: ElevatedButton(
                            onPressed: _updateProfile, // Hàm lưu sẽ được thêm sau
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    _buildDivider(),
                    _buildSectionTitle("Manage Account"),
                    _buildButton("Logout", Icons.logout, inputWidth),
                    _buildButton("Reset password", Icons.remove_red_eye, inputWidth),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: double.infinity,
        height: 1.5,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, double width, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: width,
        child: TextField(
          controller: controller,
          readOnly: !_isEditing, // Chỉ cho chỉnh sửa khi _isEditing = true
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: _isEditing ? label : null, // Hiển thị label khi không chỉnh sửa
            hintText: _isEditing ? null : label, // Hiển thị hint khi chỉnh sửa
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, double width, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: onPressed ?? _logout, // Giữ nguyên logic nút (hiện chưa có chức năng)
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.black, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}