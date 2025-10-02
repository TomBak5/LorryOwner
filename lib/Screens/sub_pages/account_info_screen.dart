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
  SingUpController? singUpController;
  bool isLoading = false;
  bool isGoogleUser = false;
  Map<String, dynamic>? googleUserData;

  @override
  void initState() {
    super.initState();
    _checkForGoogleUser();
    _initializeController();
  }
  
  void _initializeController() {
    try {
      singUpController = Get.find<SingUpController>();
    } catch (e) {
      print("SingUpController not found, using fallback values");
      singUpController = null;
    }
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
          // Don't pre-populate phone field for Google users - let them enter their phone number
          // phoneController.text = googleUserData!['email'] ?? '';
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
      // For existing users, we need to complete the full registration process
      // This means calling the registration API to create/update the user record
      // The backend should handle existing users properly
      
      final existingUserData = googleUserData!['existingUserData'];
      
      final registerResponse = await ApiProvider().registerUser(
        name: fullNameController.text.isNotEmpty ? fullNameController.text : existingUserData['name'] ?? googleUserData!['displayName'] ?? 'User',
        mobile: phoneController.text.isNotEmpty ? phoneController.text : existingUserData['mobile'] ?? '',
        cCode: existingUserData['ccode'] ?? '+1',
        email: googleUserData!['email'] ?? '',
        password: googleUserData!['uid'], // Use Firebase UID as password
        referCode: existingUserData['referCode'] ?? '',
        userRole: widget.userRole, // This is the new role we want to set
        company: widget.userRole == 'dispatcher' ? companyController.text : existingUserData['company'],
        emergencyContact: widget.userRole == 'dispatcher' ? emergencyContactController.text : existingUserData['emergencyContact'],
        selectedBrand: googleUserData?['selectedBrand'] ?? existingUserData['selectedBrand'] ?? singUpController?.selectedBrand ?? '1',
        selectedTrailerType: googleUserData?['selectedTrailerType'] ?? existingUserData['selectedTrailerType'] ?? singUpController?.selectedTrailerType ?? 'Flatbed Trailers',
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
          
          showCommonToast("Registration completed successfully!");
          return true;
        } else {
          showCommonToast("Login failed after registration. Please try again.");
          return false;
        }
      } else {
        // Check if it's an "email exists" error and handle it differently
        String errorMsg = registerResponse["ResponseMsg"] ?? "Registration failed";
        if (errorMsg.toLowerCase().contains("email") && errorMsg.toLowerCase().contains("exist")) {
          showCommonToast("This email is already registered. Please contact support or try a different account.");
        } else {
          showCommonToast(errorMsg);
        }
        return false;
      }
    } catch (e) {
      print("Error updating existing Google user: $e");
      showCommonToast("Failed to complete registration: $e");
      return false;
    }
  }
  
  // Register new Google user
  Future<bool> _registerNewGoogleUser() async {
    try {
      final registerResponse = await ApiProvider().registerUser(
        name: fullNameController.text.isNotEmpty ? fullNameController.text : googleUserData!['displayName'] ?? 'User',
        mobile: phoneController.text.isNotEmpty ? phoneController.text : '',
        cCode: '+1',
        email: googleUserData!['email'] ?? '',
        password: googleUserData!['uid'], // Use Firebase UID as password
        referCode: '',
        userRole: widget.userRole,
        company: widget.userRole == 'dispatcher' ? companyController.text : null,
        emergencyContact: widget.userRole == 'dispatcher' ? emergencyContactController.text : null,
        selectedBrand: googleUserData?['selectedBrand'] ?? singUpController?.selectedBrand ?? '1',
        selectedTrailerType: googleUserData?['selectedTrailerType'] ?? singUpController?.selectedTrailerType ?? 'Flatbed Trailers',
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
                    print('  selectedBrand: ${singUpController?.selectedBrand ?? '1'}');
                    print('  selectedTrailerType: ${singUpController?.selectedTrailerType ?? 'Flatbed Trailers'}');
                    print('  userRole: ${widget.userRole}');
                    
                    try {
                      bool registrationResult = false;
                      
                      // Validate required fields
                      if (fullNameController.text.isEmpty) {
                        showCommonToast("Please enter your full name");
                        setState(() { isLoading = false; });
                        return;
                      }
                      
                      if (phoneController.text.isEmpty) {
                        showCommonToast("Please enter your phone number");
                        setState(() { isLoading = false; });
                        return;
                      }
                      
                      if (isGoogleUser && googleUserData != null) {
                        // Handle Google user registration
                        registrationResult = await _registerGoogleUser();
                      } else {
                        // Handle regular user registration
                        if (singUpController != null) {
                          registrationResult = await singUpController!.setUserDataWithResult(
                            context,
                            name: fullNameController.text,
                            mobile: phoneController.text,
                            ccode: singUpController!.countryCode,
                            email: singUpController!.emailController.text,
                            pass: singUpController!.passwordController.text,
                            reff: singUpController!.referralCodeController.text,
                            userRole: widget.userRole,
                            company: isDispatcher ? companyController.text : null,
                            emergencyContact: isDispatcher ? emergencyContactController.text : null,
                            selectedBrand: singUpController!.selectedBrand,
                            selectedTrailerType: singUpController!.selectedTrailerType,
                          );
                        } else {
                          showCommonToast("SignUp controller not available. Please try again.");
                          setState(() { isLoading = false; });
                          return;
                        }
                      }
                      
                      setState(() { isLoading = false; });
                      
                      // Only navigate if registration was successful
                      if (registrationResult == true) {
                        // Mark Google registration as completed
                        if (isGoogleUser) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasCompletedGoogleRegistration', true);
                        }
                        
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