// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

 int get schemaVersion; RegionProfile get defaultRegion; String? get copilotProviderId; String? get copilotModelId; bool get rememberApiKey;/// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
/// draft with, set via the "Save as my default" action in Studio.
/// Null means no default has ever been saved — a new draft then falls
/// back to its chosen template's own `CvTemplate.sectionOrder`. Never
/// re-resolved against an existing draft; it only ever seeds a draft
/// at creation time. Saved and reset together with
/// [defaultHiddenSections] by the same Studio action, so the two
/// fields never drift apart from each other, but kept as two fields
/// rather than one combined value — same shape as `CvDraft.sectionOrder`
/// / `CvDraft.hiddenSections` being separate fields there too.
 List<CvSectionType>? get defaultSectionOrder;/// Same seed-only rationale as [defaultSectionOrder], one field over
/// for `CvDraft.hiddenSections` — which sections a brand-new draft
/// starts with hidden. Null means no default has been saved, so a new
/// draft starts with nothing hidden (`CvDraft.hiddenSections`'s own
/// default).
 Set<CvSectionType>? get defaultHiddenSections;/// When `BackupService.exportBackup` last completed, set by
/// `SettingsViewModel.exportBackup` — null means never. Never included
/// in a backup bundle by construction (see this class's own doc
/// comment on why `CvBackupBundle` has no `AppSettings` field at all),
/// so there is no stale-timestamp-on-restore case to guard against.
 DateTime? get lastBackupAt;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.defaultRegion, defaultRegion) || other.defaultRegion == defaultRegion)&&(identical(other.copilotProviderId, copilotProviderId) || other.copilotProviderId == copilotProviderId)&&(identical(other.copilotModelId, copilotModelId) || other.copilotModelId == copilotModelId)&&(identical(other.rememberApiKey, rememberApiKey) || other.rememberApiKey == rememberApiKey)&&const DeepCollectionEquality().equals(other.defaultSectionOrder, defaultSectionOrder)&&const DeepCollectionEquality().equals(other.defaultHiddenSections, defaultHiddenSections)&&(identical(other.lastBackupAt, lastBackupAt) || other.lastBackupAt == lastBackupAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,defaultRegion,copilotProviderId,copilotModelId,rememberApiKey,const DeepCollectionEquality().hash(defaultSectionOrder),const DeepCollectionEquality().hash(defaultHiddenSections),lastBackupAt);

@override
String toString() {
  return 'AppSettings(schemaVersion: $schemaVersion, defaultRegion: $defaultRegion, copilotProviderId: $copilotProviderId, copilotModelId: $copilotModelId, rememberApiKey: $rememberApiKey, defaultSectionOrder: $defaultSectionOrder, defaultHiddenSections: $defaultHiddenSections, lastBackupAt: $lastBackupAt)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, RegionProfile defaultRegion, String? copilotProviderId, String? copilotModelId, bool rememberApiKey, List<CvSectionType>? defaultSectionOrder, Set<CvSectionType>? defaultHiddenSections, DateTime? lastBackupAt
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? defaultRegion = null,Object? copilotProviderId = freezed,Object? copilotModelId = freezed,Object? rememberApiKey = null,Object? defaultSectionOrder = freezed,Object? defaultHiddenSections = freezed,Object? lastBackupAt = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,defaultRegion: null == defaultRegion ? _self.defaultRegion : defaultRegion // ignore: cast_nullable_to_non_nullable
as RegionProfile,copilotProviderId: freezed == copilotProviderId ? _self.copilotProviderId : copilotProviderId // ignore: cast_nullable_to_non_nullable
as String?,copilotModelId: freezed == copilotModelId ? _self.copilotModelId : copilotModelId // ignore: cast_nullable_to_non_nullable
as String?,rememberApiKey: null == rememberApiKey ? _self.rememberApiKey : rememberApiKey // ignore: cast_nullable_to_non_nullable
as bool,defaultSectionOrder: freezed == defaultSectionOrder ? _self.defaultSectionOrder : defaultSectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>?,defaultHiddenSections: freezed == defaultHiddenSections ? _self.defaultHiddenSections : defaultHiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>?,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  RegionProfile defaultRegion,  String? copilotProviderId,  String? copilotModelId,  bool rememberApiKey,  List<CvSectionType>? defaultSectionOrder,  Set<CvSectionType>? defaultHiddenSections,  DateTime? lastBackupAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.schemaVersion,_that.defaultRegion,_that.copilotProviderId,_that.copilotModelId,_that.rememberApiKey,_that.defaultSectionOrder,_that.defaultHiddenSections,_that.lastBackupAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  RegionProfile defaultRegion,  String? copilotProviderId,  String? copilotModelId,  bool rememberApiKey,  List<CvSectionType>? defaultSectionOrder,  Set<CvSectionType>? defaultHiddenSections,  DateTime? lastBackupAt)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.schemaVersion,_that.defaultRegion,_that.copilotProviderId,_that.copilotModelId,_that.rememberApiKey,_that.defaultSectionOrder,_that.defaultHiddenSections,_that.lastBackupAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  RegionProfile defaultRegion,  String? copilotProviderId,  String? copilotModelId,  bool rememberApiKey,  List<CvSectionType>? defaultSectionOrder,  Set<CvSectionType>? defaultHiddenSections,  DateTime? lastBackupAt)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.schemaVersion,_that.defaultRegion,_that.copilotProviderId,_that.copilotModelId,_that.rememberApiKey,_that.defaultSectionOrder,_that.defaultHiddenSections,_that.lastBackupAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({required this.schemaVersion, this.defaultRegion = RegionProfile.uk, this.copilotProviderId, this.copilotModelId, this.rememberApiKey = false, final  List<CvSectionType>? defaultSectionOrder, final  Set<CvSectionType>? defaultHiddenSections, this.lastBackupAt}): _defaultSectionOrder = defaultSectionOrder,_defaultHiddenSections = defaultHiddenSections;
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override final  int schemaVersion;
@override@JsonKey() final  RegionProfile defaultRegion;
@override final  String? copilotProviderId;
@override final  String? copilotModelId;
@override@JsonKey() final  bool rememberApiKey;
/// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
/// draft with, set via the "Save as my default" action in Studio.
/// Null means no default has ever been saved — a new draft then falls
/// back to its chosen template's own `CvTemplate.sectionOrder`. Never
/// re-resolved against an existing draft; it only ever seeds a draft
/// at creation time. Saved and reset together with
/// [defaultHiddenSections] by the same Studio action, so the two
/// fields never drift apart from each other, but kept as two fields
/// rather than one combined value — same shape as `CvDraft.sectionOrder`
/// / `CvDraft.hiddenSections` being separate fields there too.
 final  List<CvSectionType>? _defaultSectionOrder;
/// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
/// draft with, set via the "Save as my default" action in Studio.
/// Null means no default has ever been saved — a new draft then falls
/// back to its chosen template's own `CvTemplate.sectionOrder`. Never
/// re-resolved against an existing draft; it only ever seeds a draft
/// at creation time. Saved and reset together with
/// [defaultHiddenSections] by the same Studio action, so the two
/// fields never drift apart from each other, but kept as two fields
/// rather than one combined value — same shape as `CvDraft.sectionOrder`
/// / `CvDraft.hiddenSections` being separate fields there too.
@override List<CvSectionType>? get defaultSectionOrder {
  final value = _defaultSectionOrder;
  if (value == null) return null;
  if (_defaultSectionOrder is EqualUnmodifiableListView) return _defaultSectionOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Same seed-only rationale as [defaultSectionOrder], one field over
/// for `CvDraft.hiddenSections` — which sections a brand-new draft
/// starts with hidden. Null means no default has been saved, so a new
/// draft starts with nothing hidden (`CvDraft.hiddenSections`'s own
/// default).
 final  Set<CvSectionType>? _defaultHiddenSections;
/// Same seed-only rationale as [defaultSectionOrder], one field over
/// for `CvDraft.hiddenSections` — which sections a brand-new draft
/// starts with hidden. Null means no default has been saved, so a new
/// draft starts with nothing hidden (`CvDraft.hiddenSections`'s own
/// default).
@override Set<CvSectionType>? get defaultHiddenSections {
  final value = _defaultHiddenSections;
  if (value == null) return null;
  if (_defaultHiddenSections is EqualUnmodifiableSetView) return _defaultHiddenSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(value);
}

/// When `BackupService.exportBackup` last completed, set by
/// `SettingsViewModel.exportBackup` — null means never. Never included
/// in a backup bundle by construction (see this class's own doc
/// comment on why `CvBackupBundle` has no `AppSettings` field at all),
/// so there is no stale-timestamp-on-restore case to guard against.
@override final  DateTime? lastBackupAt;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.defaultRegion, defaultRegion) || other.defaultRegion == defaultRegion)&&(identical(other.copilotProviderId, copilotProviderId) || other.copilotProviderId == copilotProviderId)&&(identical(other.copilotModelId, copilotModelId) || other.copilotModelId == copilotModelId)&&(identical(other.rememberApiKey, rememberApiKey) || other.rememberApiKey == rememberApiKey)&&const DeepCollectionEquality().equals(other._defaultSectionOrder, _defaultSectionOrder)&&const DeepCollectionEquality().equals(other._defaultHiddenSections, _defaultHiddenSections)&&(identical(other.lastBackupAt, lastBackupAt) || other.lastBackupAt == lastBackupAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,defaultRegion,copilotProviderId,copilotModelId,rememberApiKey,const DeepCollectionEquality().hash(_defaultSectionOrder),const DeepCollectionEquality().hash(_defaultHiddenSections),lastBackupAt);

@override
String toString() {
  return 'AppSettings(schemaVersion: $schemaVersion, defaultRegion: $defaultRegion, copilotProviderId: $copilotProviderId, copilotModelId: $copilotModelId, rememberApiKey: $rememberApiKey, defaultSectionOrder: $defaultSectionOrder, defaultHiddenSections: $defaultHiddenSections, lastBackupAt: $lastBackupAt)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, RegionProfile defaultRegion, String? copilotProviderId, String? copilotModelId, bool rememberApiKey, List<CvSectionType>? defaultSectionOrder, Set<CvSectionType>? defaultHiddenSections, DateTime? lastBackupAt
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? defaultRegion = null,Object? copilotProviderId = freezed,Object? copilotModelId = freezed,Object? rememberApiKey = null,Object? defaultSectionOrder = freezed,Object? defaultHiddenSections = freezed,Object? lastBackupAt = freezed,}) {
  return _then(_AppSettings(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,defaultRegion: null == defaultRegion ? _self.defaultRegion : defaultRegion // ignore: cast_nullable_to_non_nullable
as RegionProfile,copilotProviderId: freezed == copilotProviderId ? _self.copilotProviderId : copilotProviderId // ignore: cast_nullable_to_non_nullable
as String?,copilotModelId: freezed == copilotModelId ? _self.copilotModelId : copilotModelId // ignore: cast_nullable_to_non_nullable
as String?,rememberApiKey: null == rememberApiKey ? _self.rememberApiKey : rememberApiKey // ignore: cast_nullable_to_non_nullable
as bool,defaultSectionOrder: freezed == defaultSectionOrder ? _self._defaultSectionOrder : defaultSectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>?,defaultHiddenSections: freezed == defaultHiddenSections ? _self._defaultHiddenSections : defaultHiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>?,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
