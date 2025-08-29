import 'package:flutter/material.dart';
import 'package:sketchbot_simulator/pages/signup.dart';
import  'homescaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void handleLogin() async {
    setState(() {
      isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );

      setState(() {
        isLoading = false;
      });
      return;
    }

    await Future.delayed(Duration(seconds: 1)); 
    setState(() {
      isLoading = false;
    });

    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/sketchlogo.png', height: 300),

            Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email(@gmail.com)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 19, 31, 140),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              ),
              child:
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                        'Login',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
            ),

            SizedBox(height: 16),

             Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Do not have an account? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
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
    );
  }
}
