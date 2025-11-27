import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedAuthMethod = 'email'; // 'email', 'phone', 'username'
  
  // Mock user database for demonstration
  final Map<String, String> _mockUsers = {
    'user@tydchronos.com': 'password123',
    'admin@tydchronos.com': 'admin123',
    '+1234567890': 'password123',
    'tyduser': 'password123',
  };

  Future<void> _handleAuthentication() async {
    if (!_validateInputs()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      
      String identifier = '';
      switch (_selectedAuthMethod) {
        case 'email':
          identifier = _emailController.text;
          break;
        case 'phone':
          identifier = _phoneController.text;
          break;
        case 'username':
          identifier = _usernameController.text;
          break;
      }
      
      // Mock authentication - in real app, this would call your backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Check against mock database
      if (_mockUsers.containsKey(identifier) && 
          _mockUsers[identifier] == _passwordController.text) {
        await authService.authenticate(identifier, _passwordController.text);
        print('✅ Authentication successful for: $identifier');
      } else {
        _showErrorDialog('Invalid credentials. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Authentication failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    switch (_selectedAuthMethod) {
      case 'email':
        if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
          _showErrorDialog('Please enter a valid email address');
          return false;
        }
        break;
      case 'phone':
        if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
          _showErrorDialog('Please enter a valid phone number');
          return false;
        }
        break;
      case 'username':
        if (_usernameController.text.isEmpty || _usernameController.text.length < 3) {
          _showErrorDialog('Please enter a valid username (min 3 characters)');
          return false;
        }
        break;
    }
    
    if (_passwordController.text.isEmpty) {
      _showErrorDialog('Please enter your password');
      return false;
    }
    
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Authentication Error', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthMethodSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAuthMethod,
          icon: Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white, fontSize: 16),
          onChanged: (String? newValue) {
            setState(() {
              _selectedAuthMethod = newValue!;
              // Clear all fields when switching method
              _emailController.clear();
              _phoneController.clear();
              _usernameController.clear();
              _passwordController.clear();
            });
          },
          items: <String>['email', 'phone', 'username']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    value == 'email' ? Icons.email :
                    value == 'phone' ? Icons.phone :
                    Icons.person,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    value == 'email' ? 'Email' :
                    value == 'phone' ? 'Phone' :
                    'Username',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    switch (_selectedAuthMethod) {
      case 'email':
        return TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            labelStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[800],
            prefixIcon: Icon(Icons.email, color: Color(0xFFD4AF37)),
          ),
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
        );
      case 'phone':
        return TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            labelStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[800],
            prefixIcon: Icon(Icons.phone, color: Color(0xFFD4AF37)),
            prefixText: '+',
          ),
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
        );
      case 'username':
        return TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[800],
            prefixIcon: Icon(Icons.person, color: Color(0xFFD4AF37)),
          ),
          style: TextStyle(color: Colors.white),
        );
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1a1a1a),
              Color(0xFF2d1f00),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: EdgeInsets.all(30),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TydChronos Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'TydChronos Wallet',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Advanced Banking & Cryptocurrency Platform',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  
                  // Authentication Method Selector
                  _buildAuthMethodSelector(),
                  SizedBox(height: 20),
                  
                  // Dynamic Input Field
                  _buildInputField(),
                  SizedBox(height: 20),
                  
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: Icon(Icons.lock, color: Color(0xFFD4AF37)),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  
                  // Sign In Button
                  _isLoading
                      ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)))
                      : ElevatedButton(
                          onPressed: _handleAuthentication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD4AF37),
                            foregroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Sign In to TydChronos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                  SizedBox(height: 20),
                  
                  // Demo Credentials Hint
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[800]!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Credentials:',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: user@tydchronos.com\nPhone: +1234567890\nUsername: tyduser\nPassword: password123',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
