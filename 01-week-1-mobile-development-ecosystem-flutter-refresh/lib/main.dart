import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Mahasiswa', 
          style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          backgroundColor: const Color.fromARGB(255, 137, 180, 228),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 80),
              SizedBox(height: 12),
              Text(
                'M. Aldyth Rafiasyah Fauzi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text('NIM: 244107020179'),
            ],
          ),
        ),
      ),
    );
  }
}