import 'package:cartaspg/screens/Home/homePage.dart';
import 'package:cartaspg/screens/forgotPassword/forgotPassword.dart';
import 'package:cartaspg/screens/login/login.dart';
import 'package:cartaspg/screens/signIn/signIn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter appRouter() {
  return GoRouter(
    initialLocation: '/',
    routes:[
      GoRoute(
        path: '/',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => const Login(),
        routes: [
          GoRoute(
            path: 'SignIn',
            name: 'SignIn',
            builder: (BuildContext context, GoRouterState state) => const Signin(),
          ),
          GoRoute(
            path: 'forgotPassword',
            name: 'ForgotPassword',
            builder: (BuildContext context, GoRouterState state) => const ForgotMyPassword(),
          ),
          GoRoute(
            path: 'homePage',
            name: 'HomePage',
            builder: (BuildContext context, GoRouterState state) => const Homepage(),
          )
        ]
      )
    ] 
  );

}
