import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import 'dart:io';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  _AccountProfilePageState createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> with SingleTickerProviderStateMixin {
  // User profile data
  final String username = 'John Doe';
  final String userEmail = 'johndoe@example.com';
  final String userPhone = '+1 234 567 890';
  final String userLocation = 'San Francisco, CA';
  final String joinDate = 'May 2023';
  
  // Profile image
  File? _selectedImage;
  bool _isImageLoading = false;
  
  // For edit mode
  bool _isEditMode = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  bool _isProcessing = false;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: username);
    _phoneController = TextEditingController(text: userPhone);
    _locationController = TextEditingController(text: userLocation);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  // Handle profile image selection
  Future<void> _pickImage() async {
    setState(() => _isImageLoading = true);
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImageLoading = false);
      }
    }
  }
  
  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        // Reset text fields when canceling edit mode
        _nameController.text = username;
        _phoneController.text = userPhone;
        _locationController.text = userLocation;
      }
    });
  }
  
  // Save profile changes
  Future<void> _saveChanges() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      // Simulate API call or database update
      await Future.delayed(const Duration(seconds: 1));
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _isEditMode = false;
          // In a real app, you would update the actual user data here
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  // Show confirmation dialog for signing out
  Future<void> _showSignOutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // In a real app, you would call your auth service to sign out
      // For now, just navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have been signed out')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
  
  // Handle navigation to change password screen
  void _navigateToChangePassword() {
    // In a real app, navigate to change password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Change password screen would open here'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Account & Profile',
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w600, 
            color: Colors.white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Edit button in app bar
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: _toggleEditMode,
            tooltip: _isEditMode ? 'Cancel' : 'Edit Profile',
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      // Profile picture with loading indicator
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: _isImageLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                              )
                            : CircleAvatar(
                                radius: 58,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!) as ImageProvider
                                    : const AssetImage('assets/profile_placeholder.png'),
                              ),
                      ),
                      // Edit button on the image
                      if (_isEditMode)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Personal Information Section
                _buildSectionHeader('Personal Information', isDarkMode),
                
                // Show different UI based on edit mode
                _isEditMode
                    ? _buildEditableProfileSection(isDarkMode)
                    : _buildProfileInfoSection(isDarkMode),
                
                const SizedBox(height: 24),
                
                // Account Management Section
                _buildSectionHeader('Account Management', isDarkMode),
                _buildProfileOption(
                  title: 'Change Password',
                  value: '••••••••',
                  icon: Icons.lock,
                  isDarkMode: isDarkMode,
                  onTap: _navigateToChangePassword,
                ),
                _buildProfileOption(
                  title: 'Privacy Settings',
                  value: 'Manage your data and privacy',
                  icon: Icons.security,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy');
                  },
                ),
                _buildProfileOption(
                  title: 'Connected Accounts',
                  value: 'Google, Facebook',
                  icon: Icons.link,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    // Navigate to connected accounts
                  },
                ),
                _buildProfileOption(
                  title: 'Subscription',
                  value: 'Premium Plan',
                  icon: Icons.card_membership,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    // Navigate to subscription page
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Support Section
                _buildSectionHeader('Support', isDarkMode),
                _buildProfileOption(
                  title: 'Help & Support',
                  value: 'Get help with the app',
                  icon: Icons.help_outline,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    // Navigate to help page
                  },
                ),
                _buildProfileOption(
                  title: 'About',
                  value: 'App version 1.0.0',
                  icon: Icons.info_outline,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    // Navigate to about page
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Sign Out Button
                Center(
                  child: TextButton.icon(
                    onPressed: _showSignOutDialog,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12, 
                        horizontal: 24
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Account Age Info
                if (!_isEditMode)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Member since $joinDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode 
                              ? Colors.grey.shade400 
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  
  Widget _buildProfileOption({
    required String title, 
    required String value, 
    required IconData icon, 
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDarkMode ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.blueAccent.withOpacity(0.1) 
                      : Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blueAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode 
                            ? Colors.grey.shade400 
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22,
                color: isDarkMode 
                    ? Colors.grey.shade500 
                    : Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileInfoSection(bool isDarkMode) {
    return Column(
      children: [
        // User name with verified badge
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isDarkMode ? 0 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDarkMode 
              ? Colors.black.withOpacity(0.3) 
              : Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.blueAccent.withOpacity(0.1) 
                        : Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blueAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account is verified',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode 
                              ? Colors.grey.shade400 
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Email info card
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isDarkMode ? 0 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDarkMode 
              ? Colors.black.withOpacity(0.3) 
              : Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.blueAccent.withOpacity(0.1) 
                        : Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.email,
                    color: Colors.blueAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode 
                            ? Colors.white 
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Contact & location info card
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isDarkMode ? 0 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDarkMode 
              ? Colors.black.withOpacity(0.3) 
              : Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Phone number
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.blueAccent.withOpacity(0.1) 
                            : Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.blueAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phone',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userPhone,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Location
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.blueAccent.withOpacity(0.1) 
                            : Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blueAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userLocation,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEditableProfileSection(bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDarkMode ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3) 
          : Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode 
                    ? Colors.black.withOpacity(0.2) 
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Phone field
            const Text(
              'Phone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode 
                    ? Colors.black.withOpacity(0.2) 
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter your phone number',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 16),
            
            // Location field
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode 
                    ? Colors.black.withOpacity(0.2) 
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter your location',
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blueAccent,
                  disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
