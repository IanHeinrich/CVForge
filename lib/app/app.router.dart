// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i7;
import 'package:stacked/stacked.dart' as _i6;
import 'package:stacked_services/stacked_services.dart' as _i5;

import '../features/studio/views/studio/studio_view.dart' as _i3;
import '../features/vault/views/vault/vault_view.dart' as _i2;
import '../ui/views/startup/startup_view.dart' as _i1;
import '../ui/views/unknown/unknown_view.dart' as _i4;

final stackedRouter = StackedRouterWeb(
  navigatorKey: _i5.StackedService.navigatorKey,
);

class StackedRouterWeb extends _i6.RootStackRouter {
  StackedRouterWeb({_i7.GlobalKey<_i7.NavigatorState>? navigatorKey})
    : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    StartupViewRoute.name: (routeData) {
      final args = routeData.argsAs<StartupViewArgs>(
        orElse: () => const StartupViewArgs(),
      );
      return _i6.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.StartupView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    VaultViewRoute.name: (routeData) {
      final args = routeData.argsAs<VaultViewArgs>(
        orElse: () => const VaultViewArgs(),
      );
      return _i6.CustomPage<dynamic>(
        routeData: routeData,
        child: _i2.VaultView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    StudioViewRoute.name: (routeData) {
      final args = routeData.argsAs<StudioViewArgs>(
        orElse: () => const StudioViewArgs(),
      );
      return _i6.CustomPage<dynamic>(
        routeData: routeData,
        child: _i3.StudioView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    UnknownViewRoute.name: (routeData) {
      final args = routeData.argsAs<UnknownViewArgs>(
        orElse: () => const UnknownViewArgs(),
      );
      return _i6.CustomPage<dynamic>(
        routeData: routeData,
        child: _i4.UnknownView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i6.RouteConfig> get routes => [
    _i6.RouteConfig(StartupViewRoute.name, path: '/'),
    _i6.RouteConfig(VaultViewRoute.name, path: '/vault'),
    _i6.RouteConfig(StudioViewRoute.name, path: '/studio'),
    _i6.RouteConfig(UnknownViewRoute.name, path: '/404'),
    _i6.RouteConfig(
      '*#redirect',
      path: '*',
      redirectTo: '/404',
      fullMatch: true,
    ),
  ];
}

/// generated route for
/// [_i1.StartupView]
class StartupViewRoute extends _i6.PageRouteInfo<StartupViewArgs> {
  StartupViewRoute({_i7.Key? key})
    : super(
        StartupViewRoute.name,
        path: '/',
        args: StartupViewArgs(key: key),
      );

  static const String name = 'StartupView';
}

class StartupViewArgs {
  const StartupViewArgs({this.key});

  final _i7.Key? key;

  @override
  String toString() {
    return 'StartupViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.VaultView]
class VaultViewRoute extends _i6.PageRouteInfo<VaultViewArgs> {
  VaultViewRoute({_i7.Key? key})
    : super(
        VaultViewRoute.name,
        path: '/vault',
        args: VaultViewArgs(key: key),
      );

  static const String name = 'VaultView';
}

class VaultViewArgs {
  const VaultViewArgs({this.key});

  final _i7.Key? key;

  @override
  String toString() {
    return 'VaultViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.StudioView]
class StudioViewRoute extends _i6.PageRouteInfo<StudioViewArgs> {
  StudioViewRoute({_i7.Key? key})
    : super(
        StudioViewRoute.name,
        path: '/studio',
        args: StudioViewArgs(key: key),
      );

  static const String name = 'StudioView';
}

class StudioViewArgs {
  const StudioViewArgs({this.key});

  final _i7.Key? key;

  @override
  String toString() {
    return 'StudioViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.UnknownView]
class UnknownViewRoute extends _i6.PageRouteInfo<UnknownViewArgs> {
  UnknownViewRoute({_i7.Key? key})
    : super(
        UnknownViewRoute.name,
        path: '/404',
        args: UnknownViewArgs(key: key),
      );

  static const String name = 'UnknownView';
}

class UnknownViewArgs {
  const UnknownViewArgs({this.key});

  final _i7.Key? key;

  @override
  String toString() {
    return 'UnknownViewArgs{key: $key}';
  }
}

extension RouterStateExtension on _i5.RouterService {
  Future<dynamic> navigateToStartupView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToVaultView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(VaultViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToStudioView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(StudioViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToUnknownView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(UnknownViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithStartupView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithVaultView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(VaultViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithStudioView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(StudioViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithUnknownView({
    _i7.Key? key,
    void Function(_i6.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(UnknownViewRoute(key: key), onFailure: onFailure);
  }
}
