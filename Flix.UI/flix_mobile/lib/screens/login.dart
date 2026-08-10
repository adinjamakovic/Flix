import 'package:flix_mobile/widgets/loginbox.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
const Login({ super.key });

  @override
  Widget build(BuildContext context){
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/login.png", fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.15, 0.3, 1.0],
                colors: [
                  Colors.transparent,
                  colors.surface.withValues(alpha: 0.6),
                  colors.surface.withValues(alpha: 0.8),
                  colors.surface
                  ]
                )
              )
            ),

            SafeArea(
              child: LoginBox()
            )
        ],
      ),
    );
  }
}