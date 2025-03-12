import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../services/firebase_service.dart';
import 'dart:io';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  _AccountProfilePageState createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> with SingleTickerProviderStateMixin {
  // User profile data - now initialized as null or empty
  String _username = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userLocation = '';
  String _joinDate = '';
  String? _photoURL;
  bool _isVerified = false;
  
  // Profile image
  File? _selectedImage;
  bool _isImageLoading = false;
  bool _isLoadingProfile = true;
  
  // For edit mode
  bool _isEditMode = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  bool _isProcessing = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // For hover effects
  int? _hoveredOptionIndex;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    
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
    
    // Load user data
    _loadUserData();
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
      
      // Show option to choose camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: Text('Take a photo', style: themeProvider.bodyLarge),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: Text('Choose from gallery', style: themeProvider.bodyLarge),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );
      
      if (source == null) {
        setState(() => _isImageLoading = false);
        return;
      }
      
      final XFile? image = await picker.pickImage(
        source: source,
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
          SnackBar(
            content: Text('Error picking image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
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
        _nameController.text = _username;
        _phoneController.text = _userPhone;
        _locationController.text = _userLocation;
      }
    });
  }
  
  // Save profile changes
  Future<void> _saveChanges() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Update display name in Firebase Auth
      await currentUser.updateDisplayName(_nameController.text.trim());
      
      // Update profile picture if selected
      if (_selectedImage != null) {
        // In a real app, you would upload to Firebase Storage and get a URL
        // For this example, we'll skip this step
        // final String photoUrl = await uploadProfileImage(_selectedImage!, currentUser.uid);
        // await currentUser.updatePhotoURL(photoUrl);
      }
      
      // Update additional data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
            'displayName': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'location': _locationController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      // Update local state
      setState(() {
        _username = _nameController.text.trim();
        _userPhone = _phoneController.text.trim();
        _userLocation = _locationController.text.trim();
      });
      
      // Show success message
      if (mounted) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 16),
                const Expanded(child: Text('Profile updated successfully')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(themeProvider.borderRadius),
            ),
          ),
        );
        
        setState(() {
          _isEditMode = false;
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            behavior: SnackBarBehavior.floating,
          ),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 24),
            const SizedBox(width: 16),
            const Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out? You will need to log in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: themeProvider.textButtonStyle,
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('SIGN OUT'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeProvider.borderRadius),
        ),
      ),
    );
    
    if (confirmed == true) {
      try {
        await FirebaseService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have been signed out'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    setState(() => _isLoadingProfile = true);
    
    try {
      // Get current Firebase user
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Basic data from Firebase Auth
        setState(() {
          _username = currentUser.displayName ?? 'User';
          _userEmail = currentUser.email ?? '';
          _photoURL = currentUser.photoURL;
          _isVerified = currentUser.emailVerified;
          
          // Initialize controllers with current values
          _nameController.text = _username;
        });
        
        // Try to get additional data from Firestore
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data();
            
            if (userData != null) {
              setState(() {
                _userPhone = userData['phone'] ?? '';
                _locationController.text = userData['location'] ?? '';
                _phoneController.text = _userPhone;
                _userLocation = userData['location'] ?? '';
                
                // Format the creation timestamp or use the provided timestamp
                if (userData['createdAt'] != null) {
                  final Timestamp createdAt = userData['createdAt'];
                  final DateTime joinDateTime = createdAt.toDate();
                  _joinDate = '${_getMonthName(joinDateTime.month)} ${joinDateTime.year}';
                } else {
                  // Use Firebase Auth's creation time as fallback
                  final DateTime? joinDateTime = currentUser.metadata.creationTime;
                  if (joinDateTime != null) {
                    _joinDate = '${_getMonthName(joinDateTime.month)} ${joinDateTime.year}';
                  } else {
                    _joinDate = 'Unknown';
                  }
                }
              });
            }
          } else {
            // If user document doesn't exist yet, initialize with defaults
            // and use the Auth creation time
            final DateTime? joinDateTime = currentUser.metadata.creationTime;
            if (joinDateTime != null) {
              setState(() {
                _joinDate = '${_getMonthName(joinDateTime.month)} ${joinDateTime.year}';
              });
            }
          }
        } catch (e) {
          // Handle Firestore errors
          print('Error loading additional user data: $e');
          
          // Still use what we have from Auth
          final DateTime? joinDateTime = currentUser.metadata.creationTime;
          if (joinDateTime != null) {
            setState(() {
              _joinDate = '${_getMonthName(joinDateTime.month)} ${joinDateTime.year}';
            });
          }
        }
      } else {
        // Not logged in - should not happen but handle gracefully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not logged in. Please log in to view your profile.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back to login screen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
          }
        });
      }
    } catch (e) {
      // Handle auth errors
      print('Error loading user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading your profile: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _animationController.forward();
        });
      }
    }
  }
  
  // Helper to get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Account & Profile',
          style: themeProvider.settingsHeaderStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.primaryIconColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.close : Icons.edit,
              color: themeProvider.primaryIconColor,
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
                // Warning banner
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Keep your profile information up to date to ensure the best experience.',
                          style: themeProvider.bodyMedium.copyWith(
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
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
                
                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: themeProvider.settingsBottomBarDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _showSignOutDialog,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Sign Out'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                      if (_isEditMode)
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.accentColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: themeProvider.accentColor.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Save Changes',
                            style: themeProvider.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Account Age Info
                if (!_isEditMode)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Member since $_joinDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode 
                              ? themeProvider.secondaryTextColor
                              : themeProvider.primaryTextColor.withOpacity(0.6),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: themeProvider.settingsHeaderDecoration,
      child: Row(
        children: [
          Icon(
            _getSectionIcon(title),
            color: themeProvider.accentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: themeProvider.settingsHeaderStyle,
          ),
        ],
      ),
    );
  }
  
  IconData _getSectionIcon(String section) {
    switch (section.toLowerCase()) {
      case 'personal information':
        return Icons.person_outline;
      case 'account management':
        return Icons.admin_panel_settings_outlined;
      case 'support':
        return Icons.help_outline;
      default:
        return Icons.settings;
    }
  }
  
  Widget _buildProfileOption({
    required String title, 
    required String value, 
    required IconData icon, 
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: themeProvider.settingsCardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: themeProvider.getSettingsIconDecoration(isActive: true),
          child: Icon(
            icon,
            color: themeProvider.accentColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: themeProvider.settingsTitleStyle,
        ),
        subtitle: Text(
          value,
          style: themeProvider.settingsDescriptionStyle,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: themeProvider.secondaryIconColor,
        ),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildProfileInfoSection(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
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
                            _username,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.primaryTextColor,
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
                          color: themeProvider.secondaryTextColor,
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
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.primaryTextColor,
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
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userPhone,
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.primaryTextColor,
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
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userLocation,
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.primaryTextColor,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
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
            Text(
              'Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.primaryTextColor,
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
                hintStyle: TextStyle(
                  color: themeProvider.secondaryTextColor,
                ),
                prefixIcon: Icon(Icons.person, color: themeProvider.secondaryIconColor),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Phone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.primaryTextColor,
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
                hintStyle: TextStyle(
                  color: themeProvider.secondaryTextColor,
                ),
                prefixIcon: Icon(Icons.phone, color: themeProvider.secondaryIconColor),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.primaryTextColor,
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
                hintStyle: TextStyle(
                  color: themeProvider.secondaryTextColor,
                ),
                prefixIcon: Icon(Icons.location_on, color: themeProvider.secondaryIconColor),
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
