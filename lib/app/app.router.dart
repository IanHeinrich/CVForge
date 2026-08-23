// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i11;
import 'package:stacked/stacked.dart' as _i10;
import 'package:stacked_services/stacked_services.dart' as _i9;

import '../features/analyzer/views/analyzer/analyzer_view.dart' as _i6;
import '../features/settings/views/settings/settings_view.dart' as _i5;
import '../features/studio/views/drafts_list/drafts_list_view.dart' as _i4;
import '../features/studio/views/studio/studio_view.dart' as _i3;
import '../features/vault/views/vault/vault_view.dart' as _i2;
import '../ui/views/privacy/privacy_view.dart' as _i7;
import '../ui/views/startup/startup_view.dart' as _i1;
import '../ui/views/terms/terms_view.dart' as _i8;

final stackedRouter = StackedRouterWeb(
  navigatorKey: _i9.StackedService.navigatorKey,
);

class StackedRouterWeb extends _i10.RootStackRouter {
  StackedRouterWeb({_i11.GlobalKey<_i11.NavigatorState>? navigatorKey})
    : super(navigatorKey);

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    StartupViewRoute.name: (routeData) {
      final args = routeData.argsAs<StartupViewArgs>(
        orElse: () => const StartupViewArgs(),
      );
      return _i10.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.StartupView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    VaultViewRoute.name: (routeData) {
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<VaultViewArgs>(
        orElse: () =>
            VaultViewArgs(invalidUrl: queryParams.optString('invalidUrl')),
      );
      return _i10.CustomPage<dynamic>(
        routeData: routeData,
        child: _i2.VaultView(key: args.key, invalidUrl: args.invalidUrl),
        opaque: true,
        barrierDismissible: false,
      );
    },
    StudioViewRoute.name: (routeData) {
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<StudioViewArgs>(
        orElse: () => StudioViewArgs(draftId: queryParams.optString('draftId')),
      );
      return _i10.CustomPage<dynamic>(
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
      return _i10.CustomPage<dynamic>(
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
      return _i10.CustomPage<dynamic>(
        routeData: routeData,
        child: _i5.SettingsView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    AnalyzerViewRoute.name: (routeData) {
      final args = routeData.argsAs<AnalyzerViewArgs>(
        orElse: () => const AnalyzerViewArgs(),
      );
      return _i10.CustomPage<dynamic>(
        routeData: routeData,
        child: _i6.AnalyzerView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    PrivacyViewRoute.name: (routeData) {
      final args = routeData.argsAs<PrivacyViewArgs>(
        orElse: () => const PrivacyViewArgs(),
      );
      return _i10.CustomPage<dynamic>(
        routeData: routeData,
        child: _i7.PrivacyView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
    TermsViewRoute.name: (routeData) {
      final args = routeData.argsAs<TermsViewArgs>(
        orElse: () => const TermsViewArgs(),
      );
      return _i10.CustomPage<dynamic>(
        routeData: routeData,
        child: _i8.TermsView(key: args.key),
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i10.RouteConfig> get routes => [
    _i10.RouteConfig(StartupViewRoute.name, path: '/'),
    _i10.RouteConfig(VaultViewRoute.name, path: '/vault'),
    _i10.RouteConfig(StudioViewRoute.name, path: '/studio'),
    _i10.RouteConfig(DraftsListViewRoute.name, path: '/drafts'),
    _i10.RouteConfig(SettingsViewRoute.name, path: '/settings'),
    _i10.RouteConfig(AnalyzerViewRoute.name, path: '/analyzer'),
    _i10.RouteConfig(PrivacyViewRoute.name, path: '/privacy'),
    _i10.RouteConfig(TermsViewRoute.name, path: '/terms'),
    _i10.RouteConfig(
      '*#redirect',
      path: '*',
      redirectTo: '/vault?invalidUrl=true',
      fullMatch: true,
    ),
  ];
}

/// generated route for
/// [_i1.StartupView]
class StartupViewRoute extends _i10.PageRouteInfo<StartupViewArgs> {
  StartupViewRoute({_i11.Key? key})
    : super(
        StartupViewRoute.name,
        path: '/',
        args: StartupViewArgs(key: key),
      );

  static const String name = 'StartupView';
}

class StartupViewArgs {
  const StartupViewArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'StartupViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.VaultView]
class VaultViewRoute extends _i10.PageRouteInfo<VaultViewArgs> {
  VaultViewRoute({_i11.Key? key, String? invalidUrl})
    : super(
        VaultViewRoute.name,
        path: '/vault',
        args: VaultViewArgs(key: key, invalidUrl: invalidUrl),
        rawQueryParams: {'invalidUrl': invalidUrl},
      );

  static const String name = 'VaultView';
}

class VaultViewArgs {
  const VaultViewArgs({this.key, this.invalidUrl});

  final _i11.Key? key;

  final String? invalidUrl;

  @override
  String toString() {
    return 'VaultViewArgs{key: $key, invalidUrl: $invalidUrl}';
  }
}

/// generated route for
/// [_i3.StudioView]
class StudioViewRoute extends _i10.PageRouteInfo<StudioViewArgs> {
  StudioViewRoute({_i11.Key? key, String? draftId})
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

  final _i11.Key? key;

  final String? draftId;

  @override
  String toString() {
    return 'StudioViewArgs{key: $key, draftId: $draftId}';
  }
}

/// generated route for
/// [_i4.DraftsListView]
class DraftsListViewRoute extends _i10.PageRouteInfo<DraftsListViewArgs> {
  DraftsListViewRoute({_i11.Key? key})
    : super(
        DraftsListViewRoute.name,
        path: '/drafts',
        args: DraftsListViewArgs(key: key),
      );

  static const String name = 'DraftsListView';
}

class DraftsListViewArgs {
  const DraftsListViewArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'DraftsListViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i5.SettingsView]
class SettingsViewRoute extends _i10.PageRouteInfo<SettingsViewArgs> {
  SettingsViewRoute({_i11.Key? key})
    : super(
        SettingsViewRoute.name,
        path: '/settings',
        args: SettingsViewArgs(key: key),
      );

  static const String name = 'SettingsView';
}

class SettingsViewArgs {
  const SettingsViewArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'SettingsViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i6.AnalyzerView]
class AnalyzerViewRoute extends _i10.PageRouteInfo<AnalyzerViewArgs> {
  AnalyzerViewRoute({_i11.Key? key})
    : super(
        AnalyzerViewRoute.name,
        path: '/analyzer',
        args: AnalyzerViewArgs(key: key),
      );

  static const String name = 'AnalyzerView';
}

class AnalyzerViewArgs {
  const AnalyzerViewArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'AnalyzerViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.PrivacyView]
class PrivacyViewRoute extends _i10.PageRouteInfo<PrivacyViewArgs> {
  PrivacyViewRoute({_i11.Key? key})
    : super(
        PrivacyViewRoute.name,
        path: '/privacy',
        args: PrivacyViewArgs(key: key),
      );

  static const String name = 'PrivacyView';
}

class PrivacyViewArgs {
  const PrivacyViewArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'PrivacyViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i8.TermsView]
class TermsViewRoute extends _i10.PageRouteInfo<TermsViewArgs> {
  TermsViewRoute({_i11.Key? key})
    : super(
        TermsViewRoute.name,
        path: '/terms',
        args: TermsViewArgs(key: key),
      );

  static const String name = 'TermsView';
}

class TermsViewArgs {
  const TermsViewArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'TermsViewArgs{key: $key}';
  }
}

extension RouterStateExtension on _i9.RouterService {
  Future<dynamic> navigateToStartupView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToVaultView({
    _i11.Key? key,
    String? invalidUrl,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(
      VaultViewRoute(key: key, invalidUrl: invalidUrl),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToStudioView({
    _i11.Key? key,
    String? draftId,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(
      StudioViewRoute(key: key, draftId: draftId),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToDraftsListView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(DraftsListViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToSettingsView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(SettingsViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToAnalyzerView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(AnalyzerViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToPrivacyView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(PrivacyViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> navigateToTermsView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return navigateTo(TermsViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithStartupView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(StartupViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithVaultView({
    _i11.Key? key,
    String? invalidUrl,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(
      VaultViewRoute(key: key, invalidUrl: invalidUrl),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithStudioView({
    _i11.Key? key,
    String? draftId,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(
      StudioViewRoute(key: key, draftId: draftId),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithDraftsListView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(DraftsListViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithSettingsView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(SettingsViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithAnalyzerView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(AnalyzerViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithPrivacyView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(PrivacyViewRoute(key: key), onFailure: onFailure);
  }

  Future<dynamic> replaceWithTermsView({
    _i11.Key? key,
    void Function(_i10.NavigationFailure)? onFailure,
  }) async {
    return replaceWith(TermsViewRoute(key: key), onFailure: onFailure);
  }
}
