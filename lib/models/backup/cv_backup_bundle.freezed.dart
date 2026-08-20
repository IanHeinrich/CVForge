// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_backup_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvBackupBundle {

 String get app; int get bundleVersion; DateTime get exportedAt; String get appVersion; CvVault? get vault; List<CvDraft> get drafts; String? get activeDraftId;
/// Create a copy of CvBackupBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvBackupBundleCopyWith<CvBackupBundle> get copyWith => _$CvBackupBundleCopyWithImpl<CvBackupBundle>(this as CvBackupBundle, _$identity);

  /// Serializes this CvBackupBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvBackupBundle&&(identical(other.app, app) || other.app == app)&&(identical(other.bundleVersion, bundleVersion) || other.bundleVersion == bundleVersion)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.vault, vault) || other.vault == vault)&&const DeepCollectionEquality().equals(other.drafts, drafts)&&(identical(other.activeDraftId, activeDraftId) || other.activeDraftId == activeDraftId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,app,bundleVersion,exportedAt,appVersion,vault,const DeepCollectionEquality().hash(drafts),activeDraftId);

@override
String toString() {
  return 'CvBackupBundle(app: $app, bundleVersion: $bundleVersion, exportedAt: $exportedAt, appVersion: $appVersion, vault: $vault, drafts: $drafts, activeDraftId: $activeDraftId)';
}


}

/// @nodoc
abstract mixin class $CvBackupBundleCopyWith<$Res>  {
  factory $CvBackupBundleCopyWith(CvBackupBundle value, $Res Function(CvBackupBundle) _then) = _$CvBackupBundleCopyWithImpl;
@useResult
$Res call({
 String app, int bundleVersion, DateTime exportedAt, String appVersion, CvVault? vault, List<CvDraft> drafts, String? activeDraftId
});


$CvVaultCopyWith<$Res>? get vault;

}
/// @nodoc
class _$CvBackupBundleCopyWithImpl<$Res>
    implements $CvBackupBundleCopyWith<$Res> {
  _$CvBackupBundleCopyWithImpl(this._self, this._then);

  final CvBackupBundle _self;
  final $Res Function(CvBackupBundle) _then;

/// Create a copy of CvBackupBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? app = null,Object? bundleVersion = null,Object? exportedAt = null,Object? appVersion = null,Object? vault = freezed,Object? drafts = null,Object? activeDraftId = freezed,}) {
  return _then(_self.copyWith(
app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,bundleVersion: null == bundleVersion ? _self.bundleVersion : bundleVersion // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,vault: freezed == vault ? _self.vault : vault // ignore: cast_nullable_to_non_nullable
as CvVault?,drafts: null == drafts ? _self.drafts : drafts // ignore: cast_nullable_to_non_nullable
as List<CvDraft>,activeDraftId: freezed == activeDraftId ? _self.activeDraftId : activeDraftId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CvBackupBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvVaultCopyWith<$Res>? get vault {
    if (_self.vault == null) {
    return null;
  }

  return $CvVaultCopyWith<$Res>(_self.vault!, (value) {
    return _then(_self.copyWith(vault: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvBackupBundle].
extension CvBackupBundlePatterns on CvBackupBundle {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvBackupBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvBackupBundle() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvBackupBundle value)  $default,){
final _that = this;
switch (_that) {
case _CvBackupBundle():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvBackupBundle value)?  $default,){
final _that = this;
switch (_that) {
case _CvBackupBundle() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String app,  int bundleVersion,  DateTime exportedAt,  String appVersion,  CvVault? vault,  List<CvDraft> drafts,  String? activeDraftId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvBackupBundle() when $default != null:
return $default(_that.app,_that.bundleVersion,_that.exportedAt,_that.appVersion,_that.vault,_that.drafts,_that.activeDraftId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String app,  int bundleVersion,  DateTime exportedAt,  String appVersion,  CvVault? vault,  List<CvDraft> drafts,  String? activeDraftId)  $default,) {final _that = this;
switch (_that) {
case _CvBackupBundle():
return $default(_that.app,_that.bundleVersion,_that.exportedAt,_that.appVersion,_that.vault,_that.drafts,_that.activeDraftId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String app,  int bundleVersion,  DateTime exportedAt,  String appVersion,  CvVault? vault,  List<CvDraft> drafts,  String? activeDraftId)?  $default,) {final _that = this;
switch (_that) {
case _CvBackupBundle() when $default != null:
return $default(_that.app,_that.bundleVersion,_that.exportedAt,_that.appVersion,_that.vault,_that.drafts,_that.activeDraftId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvBackupBundle implements CvBackupBundle {
  const _CvBackupBundle({required this.app, required this.bundleVersion, required this.exportedAt, required this.appVersion, this.vault, final  List<CvDraft> drafts = const <CvDraft>[], this.activeDraftId}): _drafts = drafts;
  factory _CvBackupBundle.fromJson(Map<String, dynamic> json) => _$CvBackupBundleFromJson(json);

@override final  String app;
@override final  int bundleVersion;
@override final  DateTime exportedAt;
@override final  String appVersion;
@override final  CvVault? vault;
 final  List<CvDraft> _drafts;
@override@JsonKey() List<CvDraft> get drafts {
  if (_drafts is EqualUnmodifiableListView) return _drafts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_drafts);
}

@override final  String? activeDraftId;

/// Create a copy of CvBackupBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvBackupBundleCopyWith<_CvBackupBundle> get copyWith => __$CvBackupBundleCopyWithImpl<_CvBackupBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvBackupBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvBackupBundle&&(identical(other.app, app) || other.app == app)&&(identical(other.bundleVersion, bundleVersion) || other.bundleVersion == bundleVersion)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.vault, vault) || other.vault == vault)&&const DeepCollectionEquality().equals(other._drafts, _drafts)&&(identical(other.activeDraftId, activeDraftId) || other.activeDraftId == activeDraftId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,app,bundleVersion,exportedAt,appVersion,vault,const DeepCollectionEquality().hash(_drafts),activeDraftId);

@override
String toString() {
  return 'CvBackupBundle(app: $app, bundleVersion: $bundleVersion, exportedAt: $exportedAt, appVersion: $appVersion, vault: $vault, drafts: $drafts, activeDraftId: $activeDraftId)';
}


}

/// @nodoc
abstract mixin class _$CvBackupBundleCopyWith<$Res> implements $CvBackupBundleCopyWith<$Res> {
  factory _$CvBackupBundleCopyWith(_CvBackupBundle value, $Res Function(_CvBackupBundle) _then) = __$CvBackupBundleCopyWithImpl;
@override @useResult
$Res call({
 String app, int bundleVersion, DateTime exportedAt, String appVersion, CvVault? vault, List<CvDraft> drafts, String? activeDraftId
});


@override $CvVaultCopyWith<$Res>? get vault;

}
/// @nodoc
class __$CvBackupBundleCopyWithImpl<$Res>
    implements _$CvBackupBundleCopyWith<$Res> {
  __$CvBackupBundleCopyWithImpl(this._self, this._then);

  final _CvBackupBundle _self;
  final $Res Function(_CvBackupBundle) _then;

/// Create a copy of CvBackupBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? app = null,Object? bundleVersion = null,Object? exportedAt = null,Object? appVersion = null,Object? vault = freezed,Object? drafts = null,Object? activeDraftId = freezed,}) {
  return _then(_CvBackupBundle(
app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,bundleVersion: null == bundleVersion ? _self.bundleVersion : bundleVersion // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,vault: freezed == vault ? _self.vault : vault // ignore: cast_nullable_to_non_nullable
as CvVault?,drafts: null == drafts ? _self._drafts : drafts // ignore: cast_nullable_to_non_nullable
as List<CvDraft>,activeDraftId: freezed == activeDraftId ? _self.activeDraftId : activeDraftId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CvBackupBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvVaultCopyWith<$Res>? get vault {
    if (_self.vault == null) {
    return null;
  }

  return $CvVaultCopyWith<$Res>(_self.vault!, (value) {
    return _then(_self.copyWith(vault: value));
  });
}
}

// dart format on
