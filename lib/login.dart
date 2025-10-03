import 'package:atlas_copco/home_page.dart';
import 'package:flutter/material.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, const Color.fromARGB(255, 165, 204, 255)],
            ),
          ),
          child: Center(
            child: SizedBox(
              height: 500,
              width: MediaQuery.of(context).size.width / 3.3,
              child: Card(
                color: Colors.white,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 100,
                          child: Column(
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Sign in to your account to continue",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 37, 37, 37),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextField(
                                controller: email,
                                cursorColor: Colors.blue,
                                cursorHeight: 20,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2.0,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                              TextField(
                                controller: password,
                                cursorColor: Colors.blue,
                                cursorHeight: 20,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2.0,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Spacer(),
                            GestureDetector(
                              onTap: () => {},
                              child: Text("Forgot password?"),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            ),
                          },
                          child: Container(
                            height: 42,
                            width: MediaQuery.of(context).size.width / 3.1,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
