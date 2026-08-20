// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i9;
import 'package:stacked/stacked.dart' as _i8;
import 'package:stacked_services/stacked_services.dart' as _i7;

import '../features/settings/views/settings/settings_view.dart' as _i5;
import '../features/studio/views/drafts_list/drafts_list_view.dart' as _i4;
import '../features/studio/views/studio/studio_view.dart' as _i3;
import '../features/vault/views/vault/vault_view.dart' as _i2;
import '../ui/views/startup/startup_view.dart' as _i1;
import '../ui/views/unknown/unknown_view.dart' as _i6;

final stackedRouter = StackedRouterWeb(
  navigatorKey: _i7.StackedService.navigatorKey,
);

class StackedRouterWeb extends _i8.RootStackRouter {
  StackedRouterWeb({_i9.GlobalKey<_i9.NavigatorState>? navigatorKey})
    : super(navigatorKey);

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    StartupViewRoute.name: (routeData) {
      final args = routeData.argsAs<StartupViewArgs>(
        orElse: () => const StartupViewArgs(),
      );
      return _i8.CustomPage<dynamic>(
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
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: _i2.VaultView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    StudioViewRoute.name: (routeData) {
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<StudioViewArgs>(
        orElse: () => StudioViewArgs(draftId: queryParams.optString('draftId')),
      );
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: _i3.StudioView(key: args.key, draftId: args.draftId),
        opaque: true,
        barrierDismissible: false,
      );
    },
    DraftsListViewRoute.name: (routeData) {
      final args = routeData.argsAs<DraftsListViewArgs>(
        orElse: () => const DraftsListViewArgs(),
      );
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: _i4.DraftsListView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    SettingsViewRoute.name: (routeData) {
      final args = routeData.argsAs<SettingsViewArgs>(
        orElse: () => const SettingsViewArgs(),
      );
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: _i5.SettingsView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    UnknownViewRoute.name: (routeData) {
      final args = routeData.argsAs<UnknownViewArgs>(
        orElse: () => const UnknownViewArgs(),
      );
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: _i6.UnknownView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i8.RouteConfig> get routes => [
    _i8.RouteConfig(StartupViewRoute.name, path: '/'),
    _i8.RouteConfig(VaultViewRoute.name, path: '/vault'),
    _i8.RouteConfig(StudioViewRoute.name, path: '/studio'),
    _i8.RouteConfig(DraftsListViewRoute.name, path: '/drafts'),
    _i8.RouteConfig(SettingsViewRoute.name, path: '/settings'),
    _i8.RouteConfig(UnknownViewRoute.name, path: '/404'),
    _i8.RouteConfig(
      '*#redirect',
      path: '*',
      redirectTo: '/404',
      fullMatch: true,
    ),
  ];
}

/// generated route for
/// [_i1.StartupView]
class StartupViewRoute extends _i8.PageRouteInfo<StartupViewArgs> {
  StartupViewRoute({_i9.Key? key})
    : super(
        StartupViewRoute.name,
        path: '/',
        args: StartupViewArgs(key: key),
      );

  static const String name = 'StartupView';
}

class StartupViewArgs {
  const StartupViewArgs({this.key});

  final _i9.Key? key;

  @override
  String toString() {
    return 'StartupViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.VaultView]
class VaultViewRoute extends _i8.PageRouteInfo<VaultViewArgs> {
  VaultViewRoute({_i9.Key? key})
    : super(
        VaultViewRoute.name,
        path: '/vault',
        args: VaultViewArgs(key: key),
      );

  static const String name = 'VaultView';
}

class VaultViewArgs {
  const VaultViewArgs({this.key});

  final _i9.Key? key;

  @override
  String toString() {
    return 'VaultViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.StudioView]
class StudioViewRoute extends _i8.PageRouteInfo<StudioViewArgs> {
  StudioViewRoute({_i9.Key? key, String? draftId})
    : super(
        StudioViewRoute.name,
        path: '/studio',
        args: StudioViewArgs(key: key, draftId: draftId),
        rawQueryParams: {'draftId': draftId},
      );

  static const String name = 'StudioView';
}

class StudioViewArgs {
  const StudioViewArgs({this.key, this.draftId});

  final _i9.Key? key;

  final String? draftId;

  @override
  String toString() {
    return 'StudioViewArgs{key: $key, draftId: $draftId}';
  }
}

/// generated route for
/// [_i4.DraftsListView]
class DraftsListViewRoute extends _i8.PageRouteInfo<DraftsListViewArgs> {
  DraftsListViewRoute({_i9.Key? key})
    : super(
        DraftsListViewRoute.name,
        path: '/drafts',
        args: DraftsListViewArgs(key: key),
      );

  static const String name = 'DraftsListView';
}

class DraftsListViewArgs {
  const DraftsListViewArgs({this.key});

  final _i9.Key? key;

  @override
  String toString() {
    return 'DraftsListViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i5.SettingsView]
class SettingsViewRoute extends _i8.PageRouteInfo<SettingsViewArgs> {
  SettingsViewRoute({_i9.Key? key})
    : super(
        SettingsViewRoute.name,
        path: '/settings',
        args: SettingsViewArgs(key: key),
      );

  static const String name = 'SettingsView';
}

class SettingsViewArgs {
  const SettingsViewArgs({this.key});

  final _i9.Key? key;

  @override
  String toString() {
    return 'SettingsViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i6.UnknownView]
class UnknownViewRoute extends _i8.PageRouteInfo<UnknownViewArgs> {
  UnknownViewRoute({_i9.Key? key})
    : super(
        UnknownViewRoute.name,
        path: '/404',
        args: UnknownViewArgs(key: key),
      );

  static const String name = 'UnknownView';
}

class UnknownViewArgs {
  const UnknownViewArgs({this.key});

  final _i9.Key? key;

  @override
  String toString() {
    return 'UnknownViewArgs{key: $key}';
  }
}

extension RouterStateExtension on _i7.RouterService {
  Future<dynamic> navigateToStartupView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToVaultView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(VaultViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToStudioView({
    _i9.Key? key,
    String? draftId,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(
      StudioViewRoute(key: key, draftId: draftId),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToDraftsListView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(DraftsListViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToSettingsView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(SettingsViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToUnknownView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(UnknownViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithStartupView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithVaultView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(VaultViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithStudioView({
    _i9.Key? key,
    String? draftId,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(
      StudioViewRoute(key: key, draftId: draftId),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithDraftsListView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(DraftsListViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithSettingsView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(SettingsViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithUnknownView({
    _i9.Key? key,
    void Function(_i8.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(UnknownViewRoute(key: key), onFailure: onFailure);
  }
}
