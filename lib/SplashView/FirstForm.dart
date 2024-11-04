import 'package:flutter/material.dart';
import 'package:phchat_huynhsenpai_flutter/theme.dart';

class FirstForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/kic16142511712718.jpg'), // Đường dẫn đến ảnh nền của bạn
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/logos/chatting.png', // Đường dẫn đến logo của bạn
                height: 60,
              ),
              const SizedBox(height: 10),
              const Text(
                'P H C H A T',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                    'Login' , style: TextStyle(
                  color: Colors.white,
                ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  minimumSize: const Size(350, 60), // Điều chỉnh độ dài của nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Bo tròn nhẹ các góc
                  ),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                    'Sign up',style: TextStyle(
                  color: Colors.white,
                ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: blueColor,
                  minimumSize: const Size(350, 60), // Điều chỉnh độ dài của nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Bo tròn nhẹ các góc
                  ),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Xử lý khi nhấn nút Continue as a guest
                },
                child: const Text(
                  'Continue as a guest',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 30), // Tạo khoảng cách với đáy màn hình
            ],
          ),
        ),
      ),
    );
  }
}
