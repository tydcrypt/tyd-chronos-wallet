import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService extends ChangeNotifier {
  String? _sessionKey;
  String? _currentUser;
  String? _currentEmail;
  String? _currentPhone;
  String? _mnemonicPhrase;
  String? _walletAddress;
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  AuthenticationService() {
    _initialize();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;
  String? get currentEmail => _currentEmail;
  String? get currentPhone => _currentPhone;
  String? get sessionKey => _sessionKey;
  bool get isInitialized => _isInitialized;
  String? get mnemonicPhrase => _mnemonicPhrase;
  String? get walletAddress => _walletAddress;

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionKey = prefs.getString('session_key');
      _currentUser = prefs.getString('current_user');
      _currentEmail = prefs.getString('current_email');
      _currentPhone = prefs.getString('current_phone');
      _mnemonicPhrase = prefs.getString('mnemonic_phrase');
      _walletAddress = prefs.getString('wallet_address');

      // Set authentication status based on session
      _isAuthenticated = _sessionKey != null && _sessionKey!.isNotEmpty;

      _isInitialized = true;
      notifyListeners();
    } catch (error) {
      debugPrint('Error initializing auth service: $error');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }

  String _getIdentifierType(String identifier) {
    // Email validation
    final emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (RegExp(emailRegex).hasMatch(identifier)) {
      return 'email';
    }

    // Phone number validation (international format)
    final phoneRegex = r'^\+?[1-9]\d{1,14}$';
    if (RegExp(phoneRegex).hasMatch(identifier.replaceAll(' ', ''))) {
      return 'phone';
    }

    // Default to username
    return 'username';
  }

  // Generate mnemonic phrase and wallet address
  Future<Map<String, String>> generateWallet() async {
    try {
      // Generate a 12-word mnemonic phrase
      final words = [
        'apple', 'banana', 'cherry', 'dolphin', 'elephant', 'flower',
        'giraffe', 'honey', 'ice', 'jelly', 'kangaroo', 'lemon'
      ];
      final mnemonic = words.join(' ');
      
      // Generate a demo wallet address
      final address = '0x${List.generate(40, (i) => (i * 7 + DateTime.now().millisecond) % 16).map((n) => n.toRadixString(16)).join()}';
      
      return {
        'mnemonic': mnemonic,
        'address': address,
      };
    } catch (e) {
      debugPrint('Error generating wallet: $e');
      // Fallback demo data
      return {
        'mnemonic': 'apple banana cherry dolphin elephant flower giraffe honey ice jelly kangaroo lemon',
        'address': '0x742d35Cc6634C0532925a3b8D1234567890abcd',
      };
    }
  }

  // NEW: User registration with all three fields and wallet generation
  Future<Map<String, dynamic>> register(
    String email, 
    String phone, 
    String username, 
    String password, 
    String confirmPassword
  ) async {
    await _ensureInitialized();

    try {
      // Validate all fields are provided
      if (email.isEmpty || phone.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Validate password match
      if (password != confirmPassword) {
        return {'success': false, 'message': 'Passwords do not match'};
      }

      // Validate password strength
      if (!validatePassword(password)) {
        return {'success': false, 'message': 'Password must be at least 6 characters'};
      }

      // Validate email format
      if (!validateEmail(email)) {
        return {'success': false, 'message': 'Please enter a valid email address'};
      }

      // Validate phone format
      if (!validatePhone(phone)) {
        return {'success': false, 'message': 'Please enter a valid phone number'};
      }

      // Check if user already exists with any identifier
      final prefs = await SharedPreferences.getInstance();
      final storedUsers = prefs.getStringList('registered_users') ?? [];
      final storedEmails = prefs.getStringList('registered_emails') ?? [];
      final storedPhones = prefs.getStringList('registered_phones') ?? [];
      final storedUsernames = prefs.getStringList('registered_usernames') ?? [];
      
      if (storedEmails.contains(email)) {
        return {'success': false, 'message': 'Email already registered'};
      }
      if (storedPhones.contains(phone)) {
        return {'success': false, 'message': 'Phone number already registered'};
      }
      if (storedUsernames.contains(username)) {
        return {'success': false, 'message': 'Username already taken'};
      }

      // Generate wallet for new user
      final walletData = await generateWallet();
      
      // Store user data
      storedUsers.addAll([email, phone, username]);
      storedEmails.add(email);
      storedPhones.add(phone);
      storedUsernames.add(username);
      
      await prefs.setStringList('registered_users', storedUsers);
      await prefs.setStringList('registered_emails', storedEmails);
      await prefs.setStringList('registered_phones', storedPhones);
      await prefs.setStringList('registered_usernames', storedUsernames);
      
      // Store user credentials (in real app, use proper hashing)
      final credentials = {
        'email': email,
        'phone': phone,
        'username': username,
        'password': password, // In production, hash this password
      };
      await prefs.setString('${email}_credentials', credentials.toString());
      await prefs.setString('${phone}_credentials', credentials.toString());
      await prefs.setString('${username}_credentials', credentials.toString());
      
      // Store wallet data for all identifiers
      await prefs.setString('${email}_mnemonic', walletData['mnemonic']!);
      await prefs.setString('${email}_wallet', walletData['address']!);
      await prefs.setString('${phone}_mnemonic', walletData['mnemonic']!);
      await prefs.setString('${phone}_wallet', walletData['address']!);
      await prefs.setString('${username}_mnemonic', walletData['mnemonic']!);
      await prefs.setString('${username}_wallet', walletData['address']!);
      
      // Create session
      _sessionKey = 'user_session_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = username;
      _currentEmail = email;
      _currentPhone = phone;
      _mnemonicPhrase = walletData['mnemonic'];
      _walletAddress = walletData['address'];
      _isAuthenticated = true;

      // Save session data
      await prefs.setString('session_key', _sessionKey!);
      await prefs.setString('current_user', _currentUser!);
      await prefs.setString('current_email', _currentEmail!);
      await prefs.setString('current_phone', _currentPhone!);
      await prefs.setString('wallet_address', _walletAddress!);
      await prefs.setString('mnemonic_phrase', _mnemonicPhrase!);

      notifyListeners();
      
      return {
        'success': true, 
        'message': 'Registration successful! Your TydChronos wallet has been created.',
        'mnemonic': walletData['mnemonic'],
        'walletAddress': walletData['address']
      };
    } catch (error) {
      debugPrint('Registration error: $error');
      return {'success': false, 'message': 'Registration failed: $error'};
    }
  }

  // Main authentication method for login
  Future<bool> authenticate(String identifier, String password) async {
    await _ensureInitialized();

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Check if user exists in storage
      final prefs = await SharedPreferences.getInstance();
      final storedUsers = prefs.getStringList('registered_users') ?? [];
      
      // User can login with email, phone, or username
      final userExists = storedUsers.contains(identifier);
      
      if (userExists) {
        // For demo purposes, accept any password for existing users
        // In real app, verify hashed password
        
        // Restore user session
        _sessionKey = 'user_session_${DateTime.now().millisecondsSinceEpoch}';
        _currentUser = identifier;
        
        // Restore wallet data if available
        _mnemonicPhrase = prefs.getString('${identifier}_mnemonic');
        _walletAddress = prefs.getString('${identifier}_wallet');
        
        // Determine identifier type and set appropriate field
        final identifierType = _getIdentifierType(identifier);
        if (identifierType == 'email') {
          _currentEmail = identifier;
        } else if (identifierType == 'phone') {
          _currentPhone = identifier;
        }

        // Save session
        await prefs.setString('session_key', _sessionKey!);
        await prefs.setString('current_user', _currentUser!);
        _isAuthenticated = true;

        notifyListeners();
        return true;
      }

      return false;
    } catch (error) {
      debugPrint('Authentication error: $error');
      return false;
    }
  }

  // Email/Password specific sign in
  Future<bool> signIn(String identifier, String password) async {
    return await authenticate(identifier, password);
  }

  // Email/Password specific sign up (backward compatibility)
  Future<Map<String, dynamic>> signUp(String identifier, String password, String confirmPassword) async {
    // For backward compatibility, use the identifier for all three fields
    return await register(identifier, identifier, identifier, password, confirmPassword);
  }

  // Generic login method (compatibility)
  Future<bool> loginUser(String identifier, String password) async {
    return await authenticate(identifier, password);
  }

  // Generic register method (compatibility)
  Future<Map<String, dynamic>> registerUser(String identifier, String password, String pin) async {
    // For demo, we'll use the password as confirm password
    return await register(identifier, identifier, identifier, password, password);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('session_key');
      await prefs.remove('current_user');
      await prefs.remove('current_email');
      await prefs.remove('current_phone');

      _sessionKey = null;
      _currentUser = null;
      _currentEmail = null;
      _currentPhone = null;
      _isAuthenticated = false;
      _mnemonicPhrase = null;
      _walletAddress = null;

      notifyListeners();
    } catch (error) {
      debugPrint('Sign out error: $error');
    }
  }

  // Logout method - alias for signOut
  Future<void> logout() async {
    await signOut();
    print('User logged out via logout method');
  }

  // Check if user exists (for registration)
  Future<bool> checkUserExists(String identifier) async {
    await _ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getStringList('registered_users') ?? [];
    return storedUsers.contains(identifier);
  }

  // Validate password strength
  bool validatePassword(String password) {
    return password.length >= 6;
  }

  // Validate email format
  bool validateEmail(String identifier) {
    final emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailRegex).hasMatch(identifier);
  }

  // Validate phone format
  bool validatePhone(String phone) {
    final phoneRegex = r'^\+?[1-9]\d{1,14}$';
    return RegExp(phoneRegex).hasMatch(phone.replaceAll(' ', ''));
  }

  // Get user wallet data
  Future<Map<String, String>?> getUserWalletData(String identifier) async {
    await _ensureInitialized();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final mnemonic = prefs.getString('${identifier}_mnemonic');
      final walletAddress = prefs.getString('${identifier}_wallet');
      
      if (mnemonic != null && walletAddress != null) {
        return {
          'mnemonic': mnemonic,
          'address': walletAddress,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting wallet data: $e');
      return null;
    }
  }
}