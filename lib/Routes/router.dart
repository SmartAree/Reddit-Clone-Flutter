import 'package:flutter/material.dart';
import 'package:reddit_clone/Features/Auth/Screens/login_screen.dart';
import 'package:reddit_clone/Features/Community/screens/community_detail_screen.dart';
import 'package:reddit_clone/Features/Community/screens/create_community_screen.dart';
import 'package:reddit_clone/Features/Community/screens/editcommunity_screen.dart';
import 'package:reddit_clone/Features/Community/screens/modtools_screen.dart';
import 'package:reddit_clone/Features/Home/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: LoginScreen(),
        ),
  },
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: HomeScreen(),
        ),
    '/create-community': (_) => const MaterialPage(
          child: CreateCommunityScreen(),
        ),

    //! : with this ':' it will consider this as a parameter because we want a path like this
    //? https://redditclone.com/r/memes or https://redditclone.com/r/flutter
    //? because we will have different communities so we want to display like this on web
    '/r/:name': (route) => MaterialPage(
          child: CommunityDetailScreen(
            name: route.pathParameters['name']!,
          ),
        ),
    '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(
            name: routeData.pathParameters['name']!,
          ),
        ),
    '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(
            name: routeData.pathParameters['name']!,
          ),
        ),
  },
);
