// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_defaults.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentDefaults {

 RegionProfile get region;/// The language a new CV is written in.
///
/// Defaults to [DocumentLanguage.enGb] to agree with [region]'s own
/// default. The two are independent axes and neither is inferred from
/// the other — see `RegionProfile`'s "Region is not a locale" note —
/// but their *defaults* may as well describe the same person.
 DocumentLanguage get language;/// `CvTemplate.id` for the template a new CV starts on. Null means the
/// user has never chosen one, in which case a new draft inherits the
/// template of whichever draft is open — the sticky behaviour that was
/// the only behaviour before this field existed.
///
/// Deliberately the raw id and not a `CvTemplate`: this is a model, and
/// `lib/templates/` imports `pdf`. An id that no longer resolves is
/// safe — `TemplateRegistryService.byId` falls back rather than
/// throwing — so a default surviving a template's removal degrades to
/// the fallback instead of breaking every new draft.
 String? get templateId;/// The section order (see `CvDraft.sectionOrder`) to seed a new draft
/// with. Null means no default has ever been set, and a new draft falls
/// back to its chosen template's own `CvTemplate.sectionOrder`.
///
/// Kept as two fields with [hiddenSections] rather than one combined
/// value, mirroring `CvDraft.sectionOrder` / `CvDraft.hiddenSections`
/// being separate there too.
 List<CvSectionType>? get sectionOrder;/// Which sections a new draft starts with hidden. See [sectionOrder].
 Set<CvSectionType>? get hiddenSections;
/// Create a copy of DocumentDefaults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentDefaultsCopyWith<DocumentDefaults> get copyWith => _$DocumentDefaultsCopyWithImpl<DocumentDefaults>(this as DocumentDefaults, _$identity);

  /// Serializes this DocumentDefaults to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentDefaults&&(identical(other.region, region) || other.region == region)&&(identical(other.language, language) || other.language == language)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&const DeepCollectionEquality().equals(other.sectionOrder, sectionOrder)&&const DeepCollectionEquality().equals(other.hiddenSections, hiddenSections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,region,language,templateId,const DeepCollectionEquality().hash(sectionOrder),const DeepCollectionEquality().hash(hiddenSections));

@override
String toString() {
  return 'DocumentDefaults(region: $region, language: $language, templateId: $templateId, sectionOrder: $sectionOrder, hiddenSections: $hiddenSections)';
}


}

/// @nodoc
abstract mixin class $DocumentDefaultsCopyWith<$Res>  {
  factory $DocumentDefaultsCopyWith(DocumentDefaults value, $Res Function(DocumentDefaults) _then) = _$DocumentDefaultsCopyWithImpl;
@useResult
$Res call({
 RegionProfile region, DocumentLanguage language, String? templateId, List<CvSectionType>? sectionOrder, Set<CvSectionType>? hiddenSections
});




}
/// @nodoc
class _$DocumentDefaultsCopyWithImpl<$Res>
    implements $DocumentDefaultsCopyWith<$Res> {
  _$DocumentDefaultsCopyWithImpl(this._self, this._then);

  final DocumentDefaults _self;
  final $Res Function(DocumentDefaults) _then;

/// Create a copy of DocumentDefaults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? region = null,Object? language = null,Object? templateId = freezed,Object? sectionOrder = freezed,Object? hiddenSections = freezed,}) {
  return _then(_self.copyWith(
region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionProfile,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as DocumentLanguage,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,sectionOrder: freezed == sectionOrder ? _self.sectionOrder : sectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>?,hiddenSections: freezed == hiddenSections ? _self.hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentDefaults].
extension DocumentDefaultsPatterns on DocumentDefaults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentDefaults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentDefaults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentDefaults value)  $default,){
final _that = this;
switch (_that) {
case _DocumentDefaults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentDefaults value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentDefaults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegionProfile region,  DocumentLanguage language,  String? templateId,  List<CvSectionType>? sectionOrder,  Set<CvSectionType>? hiddenSections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentDefaults() when $default != null:
return $default(_that.region,_that.language,_that.templateId,_that.sectionOrder,_that.hiddenSections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegionProfile region,  DocumentLanguage language,  String? templateId,  List<CvSectionType>? sectionOrder,  Set<CvSectionType>? hiddenSections)  $default,) {final _that = this;
switch (_that) {
case _DocumentDefaults():
return $default(_that.region,_that.language,_that.templateId,_that.sectionOrder,_that.hiddenSections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegionProfile region,  DocumentLanguage language,  String? templateId,  List<CvSectionType>? sectionOrder,  Set<CvSectionType>? hiddenSections)?  $default,) {final _that = this;
switch (_that) {
case _DocumentDefaults() when $default != null:
return $default(_that.region,_that.language,_that.templateId,_that.sectionOrder,_that.hiddenSections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentDefaults implements DocumentDefaults {
  const _DocumentDefaults({this.region = RegionProfile.uk, this.language = DocumentLanguage.enGb, this.templateId, final  List<CvSectionType>? sectionOrder, final  Set<CvSectionType>? hiddenSections}): _sectionOrder = sectionOrder,_hiddenSections = hiddenSections;
  factory _DocumentDefaults.fromJson(Map<String, dynamic> json) => _$DocumentDefaultsFromJson(json);

@override@JsonKey() final  RegionProfile region;
/// The language a new CV is written in.
///
/// Defaults to [DocumentLanguage.enGb] to agree with [region]'s own
/// default. The two are independent axes and neither is inferred from
/// the other — see `RegionProfile`'s "Region is not a locale" note —
/// but their *defaults* may as well describe the same person.
@override@JsonKey() final  DocumentLanguage language;
/// `CvTemplate.id` for the template a new CV starts on. Null means the
/// user has never chosen one, in which case a new draft inherits the
/// template of whichever draft is open — the sticky behaviour that was
/// the only behaviour before this field existed.
///
/// Deliberately the raw id and not a `CvTemplate`: this is a model, and
/// `lib/templates/` imports `pdf`. An id that no longer resolves is
/// safe — `TemplateRegistryService.byId` falls back rather than
/// throwing — so a default surviving a template's removal degrades to
/// the fallback instead of breaking every new draft.
@override final  String? templateId;
/// The section order (see `CvDraft.sectionOrder`) to seed a new draft
/// with. Null means no default has ever been set, and a new draft falls
/// back to its chosen template's own `CvTemplate.sectionOrder`.
///
/// Kept as two fields with [hiddenSections] rather than one combined
/// value, mirroring `CvDraft.sectionOrder` / `CvDraft.hiddenSections`
/// being separate there too.
 final  List<CvSectionType>? _sectionOrder;
/// The section order (see `CvDraft.sectionOrder`) to seed a new draft
/// with. Null means no default has ever been set, and a new draft falls
/// back to its chosen template's own `CvTemplate.sectionOrder`.
///
/// Kept as two fields with [hiddenSections] rather than one combined
/// value, mirroring `CvDraft.sectionOrder` / `CvDraft.hiddenSections`
/// being separate there too.
@override List<CvSectionType>? get sectionOrder {
  final value = _sectionOrder;
  if (value == null) return null;
  if (_sectionOrder is EqualUnmodifiableListView) return _sectionOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Which sections a new draft starts with hidden. See [sectionOrder].
 final  Set<CvSectionType>? _hiddenSections;
/// Which sections a new draft starts with hidden. See [sectionOrder].
@override Set<CvSectionType>? get hiddenSections {
  final value = _hiddenSections;
  if (value == null) return null;
  if (_hiddenSections is EqualUnmodifiableSetView) return _hiddenSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(value);
}


/// Create a copy of DocumentDefaults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentDefaultsCopyWith<_DocumentDefaults> get copyWith => __$DocumentDefaultsCopyWithImpl<_DocumentDefaults>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentDefaultsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentDefaults&&(identical(other.region, region) || other.region == region)&&(identical(other.language, language) || other.language == language)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&const DeepCollectionEquality().equals(other._sectionOrder, _sectionOrder)&&const DeepCollectionEquality().equals(other._hiddenSections, _hiddenSections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,region,language,templateId,const DeepCollectionEquality().hash(_sectionOrder),const DeepCollectionEquality().hash(_hiddenSections));

@override
String toString() {
  return 'DocumentDefaults(region: $region, language: $language, templateId: $templateId, sectionOrder: $sectionOrder, hiddenSections: $hiddenSections)';
}


}

/// @nodoc
abstract mixin class _$DocumentDefaultsCopyWith<$Res> implements $DocumentDefaultsCopyWith<$Res> {
  factory _$DocumentDefaultsCopyWith(_DocumentDefaults value, $Res Function(_DocumentDefaults) _then) = __$DocumentDefaultsCopyWithImpl;
@override @useResult
$Res call({
 RegionProfile region, DocumentLanguage language, String? templateId, List<CvSectionType>? sectionOrder, Set<CvSectionType>? hiddenSections
});




}
/// @nodoc
class __$DocumentDefaultsCopyWithImpl<$Res>
    implements _$DocumentDefaultsCopyWith<$Res> {
  __$DocumentDefaultsCopyWithImpl(this._self, this._then);

  final _DocumentDefaults _self;
  final $Res Function(_DocumentDefaults) _then;

/// Create a copy of DocumentDefaults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? region = null,Object? language = null,Object? templateId = freezed,Object? sectionOrder = freezed,Object? hiddenSections = freezed,}) {
  return _then(_DocumentDefaults(
region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionProfile,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as DocumentLanguage,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,sectionOrder: freezed == sectionOrder ? _self._sectionOrder : sectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>?,hiddenSections: freezed == hiddenSections ? _self._hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>?,
  ));
}


}

// dart format on
