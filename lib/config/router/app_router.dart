import 'package:cartaspg/screens/Home/homePage.dart';
import 'package:cartaspg/screens/curso/cursoDetail.dart';
import 'package:cartaspg/screens/forgotPassword/forgotPassword.dart';
import 'package:cartaspg/screens/login/login.dart';
import 'package:cartaspg/screens/signIn/signIn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

GoRouter appRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) {
          final user = Provider.of<User?>(context);
          if (user == null) {
            return const Login();
          } else {
            return const Homepage();
          }
        },
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (BuildContext context, GoRouterState state) => const Login(),
          ),
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
            routes: [
              GoRoute(
                path: 'addCurso',
                name: 'AddCurso',
                builder: (BuildContext context, GoRouterState state) => const Homepage(),
              ),
              GoRoute(
                path: 'detalleCurso/:id',
                name: 'detalleCurso',
                builder: (BuildContext context, GoRouterState state) {
                  final String cursoId = state.pathParameters['id']!;
                  return CurdsoDetallePage(cursoId: cursoId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}