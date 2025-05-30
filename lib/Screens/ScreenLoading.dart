import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(child: CircularProgressIndicator(color: Colors.white)),
  );
 }
}
