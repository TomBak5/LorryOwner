import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_pages/home_page.dart';
import '../../Controllers/singiup_controller.dart';
import '../congratulations_screen.dart';
import 'link_driver_screen.dart';
import '../../Api_Provider/api_provider.dart';
import '../../widgets/widgets.dart';
import '../../AppConstData/routes.dart';

class AccountInfoScreen extends StatefulWidget {
  final String userRole;
  const AccountInfoScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();
  final SingUpController singUpController = Get.find<SingUpController>();
  bool isLoading = false;
  bool isGoogleUser = false;
  Map<String, dynamic>? googleUserData;

  @override
  void initState() {
    super.initState();
    _checkForGoogleUser();
  }

  Future<void> _checkForGoogleUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempGoogleUser = prefs.getString('tempGoogleUser');
      
      if (tempGoogleUser != null) {
        setState(() {
          isGoogleUser = true;
          googleUserData = jsonDecode(tempGoogleUser);
        });
        
        // Pre-populate form with Google user data
        if (googleUserData != null) {
          fullNameController.text = googleUserData!['displayName'] ?? '';
          // For Google users, we'll use email as mobile number
          phoneController.text = googleUserData!['email'] ?? '';
        }
      }
    } catch (e) {
      print("Error checking for Google user: $e");
    }
  }

  // Register Google user with account info
  Future<bool> _registerGoogleUser() async {
    try {
      if (googleUserData == null) return false;
      
      // Check if this is an existing user
      if (googleUserData!['existingUser'] == true) {
        // Update existing user's role and info
        return await _updateExistingGoogleUser();
      } else {
        // Register new Google user
        return await _registerNewGoogleUser();
      }
    } catch (e) {
      print("Error registering Google user: $e");
      showCommonToast("Registration failed: $e");
      return false;
    }
  }
  
  // Update existing Google user
  Future<bool> _updateExistingGoogleUser() async {
    try {
      // For existing users, we need to update their role in the database
      // We'll do this by calling the registration API with the existing user's data
      // but with the new role - this will update the existing record
      
      final existingUserData = googleUserData!['existingUserData'];
      
      final registerResponse = await ApiProvider().registerUser(
        name: fullNameController.text.isNotEmpty ? fullNameController.text : existingUserData['name'] ?? googleUserData!['displayName'] ?? 'User',
        mobile: phoneController.text.isNotEmpty ? phoneController.text : existingUserData['mobile'] ?? googleUserData!['email'] ?? '',
        cCode: existingUserData['ccode'] ?? '+1',
        email: googleUserData!['email'] ?? '',
        password: googleUserData!['uid'], // Use Firebase UID as password
        referCode: existingUserData['referCode'] ?? '',
        userRole: widget.userRole, // This is the new role we want to set
        company: widget.userRole == 'dispatcher' ? companyController.text : existingUserData['company'],
        emergencyContact: widget.userRole == 'dispatcher' ? emergencyContactController.text : existingUserData['emergencyContact'],
        selectedBrand: googleUserData?['selectedBrand'] ?? existingUserData['selectedBrand'] ?? singUpController.selectedBrand,
        selectedTrailerType: googleUserData?['selectedTrailerType'] ?? existingUserData['selectedTrailerType'] ?? singUpController.selectedTrailerType,
      );

      if (registerResponse["Result"] == "true") {
        // Registration/update successful, login again to get updated data
        final loginResponse = await ApiProvider().loginUserWithEmail(
          email: googleUserData!['email'] ?? '',
          password: googleUserData!['uid'],
        );

        if (loginResponse["Result"] == "true") {
          // Clear temp data
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('tempGoogleUser');
          
          // Save updated user data
          String encodedData = jsonEncode(loginResponse["UserLogin"]);
          await prefs.setString("userData", encodedData);
          
          showCommonToast("Role updated successfully!");
          return true;
        } else {
          showCommonToast("Login failed after role update. Please try again.");
          return false;
        }
      } else {
        showCommonToast(registerResponse["ResponseMsg"] ?? "Failed to update role");
        return false;
      }
    } catch (e) {
      print("Error updating existing Google user: $e");
      showCommonToast("Failed to update role: $e");
      return false;
    }
  }
  
  // Register new Google user
  Future<bool> _registerNewGoogleUser() async {
    try {
      final registerResponse = await ApiProvider().registerUser(
        name: fullNameController.text.isNotEmpty ? fullNameController.text : googleUserData!['displayName'] ?? 'User',
        mobile: phoneController.text.isNotEmpty ? phoneController.text : googleUserData!['email'] ?? '',
        cCode: '+1',
        email: googleUserData!['email'] ?? '',
        password: googleUserData!['uid'], // Use Firebase UID as password
        referCode: '',
        userRole: widget.userRole,
        company: widget.userRole == 'dispatcher' ? companyController.text : null,
        emergencyContact: widget.userRole == 'dispatcher' ? emergencyContactController.text : null,
        selectedBrand: googleUserData?['selectedBrand'] ?? singUpController.selectedBrand,
        selectedTrailerType: googleUserData?['selectedTrailerType'] ?? singUpController.selectedTrailerType,
      );

      if (registerResponse["Result"] == "true") {
        // Registration successful, try login again
        final loginResponse = await ApiProvider().loginUserWithEmail(
          email: googleUserData!['email'] ?? '',
          password: googleUserData!['uid'],
        );

        if (loginResponse["Result"] == "true") {
          // Clear temp data
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('tempGoogleUser');
          
          // Save user data
          String encodedData = jsonEncode(loginResponse["UserLogin"]);
          await prefs.setString("userData", encodedData);
          
          return true;
        } else {
          showCommonToast("Login failed after registration. Please try again.");
          return false;
        }
      } else {
        showCommonToast(registerResponse["ResponseMsg"] ?? "Registration failed");
        return false;
      }
    } catch (e) {
      print("Error registering new Google user: $e");
      showCommonToast("Registration failed: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDispatcher = widget.userRole == 'dispatcher';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('Account information', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black)),
                  const Spacer(),
                  Text(
                    widget.userRole == 'dispatcher' ? '1/2' : '2/3',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1 / 3,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
                minHeight: 3,
              ),
              const SizedBox(height: 32),
              Text('Account information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
              const SizedBox(height: 32),
              Text('Full name', style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 8),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: isDispatcher ? 'Dry Van Dispatcher' : 'Enter full name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Text('Phone number', style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+44',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              if (isDispatcher) ...[
                Text('Company name', style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(height: 8),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    hintText: 'Your company name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Family emergency contact', style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(height: 8),
                TextField(
                  controller: emergencyContactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+44',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    // Prevent multiple taps while loading
                    if (isLoading) return;
                    
                    setState(() { isLoading = true; });
                    
                    // Debug: Print truck selection values
                    print('Truck selection debug:');
                    print('  selectedBrand: ${singUpController.selectedBrand}');
                    print('  selectedTrailerType: ${singUpController.selectedTrailerType}');
                    print('  userRole: ${widget.userRole}');
                    
                    try {
                      bool registrationResult = false;
                      
                      if (isGoogleUser && googleUserData != null) {
                        // Handle Google user registration
                        registrationResult = await _registerGoogleUser();
                      } else {
                        // Handle regular user registration
                        registrationResult = await singUpController.setUserDataWithResult(
                          context,
                          name: fullNameController.text,
                          mobile: phoneController.text,
                          ccode: singUpController.countryCode,
                          email: singUpController.emailController.text,
                          pass: singUpController.passwordController.text,
                          reff: singUpController.referralCodeController.text,
                          userRole: widget.userRole,
                          company: isDispatcher ? companyController.text : null,
                          emergencyContact: isDispatcher ? emergencyContactController.text : null,
                          selectedBrand: singUpController.selectedBrand,
                          selectedTrailerType: singUpController.selectedTrailerType,
                        );
                      }
                      
                      setState(() { isLoading = false; });
                      
                      // Only navigate if registration was successful
                      if (registrationResult == true) {
                        if (isDispatcher) {
                          Get.to(() => LinkDriverScreen(
                            initialDrivers: [],
                            onDriversSelected: (drivers) {
                              Get.to(() => CongratulationsScreen(userRole: widget.userRole));
                            },
                          ));
                        } else {
                          Get.to(() => CongratulationsScreen(userRole: widget.userRole));
                        }
                      } else {
                        // Registration failed, show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registration failed. Please try again.')),
                        );
                      }
                    } catch (e) {
                      setState(() { isLoading = false; });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoading ? Colors.grey : Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.offAll(() => HomePage());
                  },
                  child: Text('Skip now', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
} 