import 'package:atlas_copco/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/services/auth_service.dart';
import 'screens/admin_dashboard.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authService: AuthService()),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue,
                      const Color.fromARGB(255, 165, 204, 255),
                    ],
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
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 100,
                                child: Column(
                                  children: const [
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
                                        color: Color.fromARGB(255, 37, 37, 37),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 120,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextField(
                                      controller: email,
                                      cursorColor: Colors.blue,
                                      cursorHeight: 20,
                                      decoration: const InputDecoration(
                                        labelText: "Email",
                                      ),
                                    ),
                                    TextField(
                                      controller: password,
                                      cursorColor: Colors.blue,
                                      cursorHeight: 20,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: "Password",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => {},
                                    child: const Text("Forgot password?"),
                                  ),
                                ],
                              ),
                              BlocConsumer<AuthBloc, dynamic>(
                                listener: (context, state) {
                                  if (state is AuthAuthenticated) {
                                    // navigate to admin for SDH role, else HomePage
                                    final user = state.user;
                                    final role = user?['role']?['role_name'];
                                    if (role == 'SDH') {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminDashboard(),
                                        ),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomePage(),
                                        ),
                                      );
                                    }
                                  }
                                  if (state is AuthError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(state.message)),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  if (state is AuthLoading)
                                    return const CircularProgressIndicator();
                                  return GestureDetector(
                                    onTap: () => context.read<AuthBloc>().add(
                                      AuthLoginRequested(
                                        email.text.trim(),
                                        password.text,
                                      ),
                                    ),
                                    child: Container(
                                      height: 42,
                                      width:
                                          MediaQuery.of(context).size.width /
                                          3.1,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
        },
      ),
    );
  }
}
