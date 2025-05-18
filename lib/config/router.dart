import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:toruerp/views/inventory/product/list.dart';
import 'package:toruerp/views/inventory/product/stock/stock_in.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/stockin',
      name: 'In Stock',
      builder: (context, state) => const StockInScreen(),
    ),
  ],
);
