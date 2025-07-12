import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main_pages/home_page.dart';
import '../../Controllers/singiup_controller.dart';
import '../congratulations_screen.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({Key? key}) : super(key: key);

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
                  Text('2/3', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 2 / 3,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
                minHeight: 3,
              ),
              const SizedBox(height: 32),
              Text('Your Account information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
              const SizedBox(height: 32),
              Text('Full name', style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 8),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
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
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Text('Company name', style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 8),
              TextField(
                controller: companyController,
                decoration: InputDecoration(
                  hintText: 'Enter company name',
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
                  hintText: 'Enter emergency contact',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() { isLoading = true; });
                    await singUpController.setUserData(
                      context,
                      name: fullNameController.text,
                      mobile: phoneController.text,
                      ccode: singUpController.countryCode,
                      email: singUpController.emailController.text,
                      pass: singUpController.passwordController.text,
                      reff: singUpController.referralCodeController.text,
                      userRole: singUpController.selectedRole,
                      company: companyController.text,
                      emergencyContact: emergencyContactController.text,
                    );
                    Get.to(() => CongratulationsScreen(userRole: 'driver'));
                    setState(() { isLoading = false; });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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