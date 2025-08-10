import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main_pages/home_page.dart';
import '../../Controllers/singiup_controller.dart';
import '../congratulations_screen.dart';
import 'link_driver_screen.dart';

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
                      // Wait for registration to complete successfully
                      final registrationResult = await singUpController.setUserDataWithResult(
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