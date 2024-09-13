import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;
  File? _selectedImage;
  final _firebase = FirebaseAuth.instance;
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  
  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();
    print("Email & Password: $_enteredEmail & $_enteredPassword");

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCreds = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        print(userCreds);
      } else {
        final userCreds = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCreds.user!.uid}.jpeg");
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc("${userCreds.user!.uid}")
            .set({
          "username": _enteredUsername,
          "email": _enteredEmail,
          "image_url": imageUrl
        });

      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {}

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? "Authentication Failed")),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        // title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                elevation: 10,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            onPickImage: (imageArg) {
                              _selectedImage = imageArg;
                            },
                          ),
                        if (!_isLogin)
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            // border: OutlineInputBorder(),
                          ),
                          enableSuggestions: false,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null ||
                                value.trim().length<4 ||
                                value.isEmpty) {
                              return "Enter a valid username, at least 4 characters.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredUsername = value!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            // border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains("@")) {
                              return "Enter a valid email address.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        const SizedBox(height: 1),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            // border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return "Enter correct password(at least 6 characters).";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Text(_isLogin ? 'Login' : 'Signup'),
                        ), // ElevatedButton
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'New here? Sign Up.'
                              : 'Already have an account? Login.'), // Text
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
