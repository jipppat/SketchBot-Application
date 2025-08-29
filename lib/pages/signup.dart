import 'package:flutter/material.dart';
import 'login.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isChecked = false; 
  bool isLoading = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            children: [
              Image.asset('assets/images/sketchlogo.png', height: 250),

              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 20),
              buildInputField('User name', usernameController),
              buildInputField('Email(@gmail.com)', emailController),
              buildInputField('Password', passwordController, obscure: true),
              buildInputField(
                'Confirm Password',
                confirmPasswordController,
                obscure: true,
              ),

              SizedBox(height: 10),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  Flexible(child: Text('I agree with privacy and policy')),
                ],
              ),
              

              
              SizedBox(height: 10),
              ElevatedButton(
                onPressed:
                    isChecked
                        ? handleSignup
                        : null, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 19, 31, 140),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
               SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ), 
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          ),
        ),
      ),
    );
  }

  
  void handleSignup() async {
    setState(() {
      isLoading = true;
    });

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

   
    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Error"),
              content: Text("Passwords do not match."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      setState(() => isLoading = false);
      return;
    }

    
    print(" Saving user:");
    print("Username: $username");
    print("Email: $email");
    print("Password: $password");

    

    await Future.delayed(Duration(seconds: 1)); // ลองบันทึก

    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Sign Up Successful"),
            content: Text("Welcome, $username!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }
}
