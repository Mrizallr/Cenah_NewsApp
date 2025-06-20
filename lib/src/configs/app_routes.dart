// TODO Implement this library.
import 'package:cenah_news/src/pages/auth/register_screen.dart';
import 'package:cenah_news/src/pages/create_article/create_article_screen.dart';
import 'package:cenah_news/src/pages/edit_article/edit_article_screen.dart';
import 'package:cenah_news/src/pages/my_articles/my_articles.dart';
import 'package:flutter/material.dart';
import 'package:cenah_news/src/pages/home/home_screen.dart';
import 'package:cenah_news/src/pages/auth/login_screen.dart';
import 'package:cenah_news/src/pages/splashscreen/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const introduction = '/intro';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const articleDetail = '/article/:id';
  static const profile = '/profile';
  static const explore = '/explore';
  static const trending = '/trending';
  static const saved = '/saved';
  static const myArticles = '/my-articles';
  static const createArticle = '/create-article';
  static const editArticle = '/edit-article/:id';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case myArticles:
        return MaterialPageRoute(builder: (_) => const MyArticlesScreen());
      case createArticle:
        return MaterialPageRoute(builder: (_) => const CreateArticleScreen());
      case editArticle:
        final articleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditArticleScreen(articleId: articleId),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
