// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Experience {

 String get id; String get role; String get company; String get location; YearMonth get start; YearMonth? get end; bool get isCurrent; List<ExperienceBullet> get bullets;/// Shared by every [Experience] that represents a promotion within the
/// same company — `null` means "not grouped with anything". A group of
/// one (a group id set on only one experience) renders identically to
/// an ungrouped entry, so nothing needs to clear this when a group
/// shrinks back down. See `CvComposer._buildExperience` for how this
/// becomes a single company heading with multiple role/date lines.
 String? get companyGroupId;
/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExperienceCopyWith<Experience> get copyWith => _$ExperienceCopyWithImpl<Experience>(this as Experience, _$identity);

  /// Serializes this Experience to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Experience&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&const DeepCollectionEquality().equals(other.bullets, bullets)&&(identical(other.companyGroupId, companyGroupId) || other.companyGroupId == companyGroupId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,company,location,start,end,isCurrent,const DeepCollectionEquality().hash(bullets),companyGroupId);

@override
String toString() {
  return 'Experience(id: $id, role: $role, company: $company, location: $location, start: $start, end: $end, isCurrent: $isCurrent, bullets: $bullets, companyGroupId: $companyGroupId)';
}


}

/// @nodoc
abstract mixin class $ExperienceCopyWith<$Res>  {
  factory $ExperienceCopyWith(Experience value, $Res Function(Experience) _then) = _$ExperienceCopyWithImpl;
@useResult
$Res call({
 String id, String role, String company, String location, YearMonth start, YearMonth? end, bool isCurrent, List<ExperienceBullet> bullets, String? companyGroupId
});


$YearMonthCopyWith<$Res> get start;$YearMonthCopyWith<$Res>? get end;

}
/// @nodoc
class _$ExperienceCopyWithImpl<$Res>
    implements $ExperienceCopyWith<$Res> {
  _$ExperienceCopyWithImpl(this._self, this._then);

  final Experience _self;
  final $Res Function(Experience) _then;

/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = null,Object? company = null,Object? location = null,Object? start = null,Object? end = freezed,Object? isCurrent = null,Object? bullets = null,Object? companyGroupId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as YearMonth,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as YearMonth?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ExperienceBullet>,companyGroupId: freezed == companyGroupId ? _self.companyGroupId : companyGroupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$YearMonthCopyWith<$Res> get start {
  
  return $YearMonthCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$YearMonthCopyWith<$Res>? get end {
    if (_self.end == null) {
    return null;
  }

  return $YearMonthCopyWith<$Res>(_self.end!, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// Adds pattern-matching-related methods to [Experience].
extension ExperiencePatterns on Experience {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Experience value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Experience() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Experience value)  $default,){
final _that = this;
switch (_that) {
case _Experience():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Experience value)?  $default,){
final _that = this;
switch (_that) {
case _Experience() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String role,  String company,  String location,  YearMonth start,  YearMonth? end,  bool isCurrent,  List<ExperienceBullet> bullets,  String? companyGroupId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Experience() when $default != null:
return $default(_that.id,_that.role,_that.company,_that.location,_that.start,_that.end,_that.isCurrent,_that.bullets,_that.companyGroupId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String role,  String company,  String location,  YearMonth start,  YearMonth? end,  bool isCurrent,  List<ExperienceBullet> bullets,  String? companyGroupId)  $default,) {final _that = this;
switch (_that) {
case _Experience():
return $default(_that.id,_that.role,_that.company,_that.location,_that.start,_that.end,_that.isCurrent,_that.bullets,_that.companyGroupId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String role,  String company,  String location,  YearMonth start,  YearMonth? end,  bool isCurrent,  List<ExperienceBullet> bullets,  String? companyGroupId)?  $default,) {final _that = this;
switch (_that) {
case _Experience() when $default != null:
return $default(_that.id,_that.role,_that.company,_that.location,_that.start,_that.end,_that.isCurrent,_that.bullets,_that.companyGroupId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Experience implements Experience {
  const _Experience({required this.id, required this.role, required this.company, required this.location, required this.start, this.end, this.isCurrent = false, final  List<ExperienceBullet> bullets = const <ExperienceBullet>[], this.companyGroupId}): _bullets = bullets;
  factory _Experience.fromJson(Map<String, dynamic> json) => _$ExperienceFromJson(json);

@override final  String id;
@override final  String role;
@override final  String company;
@override final  String location;
@override final  YearMonth start;
@override final  YearMonth? end;
@override@JsonKey() final  bool isCurrent;
 final  List<ExperienceBullet> _bullets;
@override@JsonKey() List<ExperienceBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}

/// Shared by every [Experience] that represents a promotion within the
/// same company — `null` means "not grouped with anything". A group of
/// one (a group id set on only one experience) renders identically to
/// an ungrouped entry, so nothing needs to clear this when a group
/// shrinks back down. See `CvComposer._buildExperience` for how this
/// becomes a single company heading with multiple role/date lines.
@override final  String? companyGroupId;

/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExperienceCopyWith<_Experience> get copyWith => __$ExperienceCopyWithImpl<_Experience>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExperienceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Experience&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&const DeepCollectionEquality().equals(other._bullets, _bullets)&&(identical(other.companyGroupId, companyGroupId) || other.companyGroupId == companyGroupId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,company,location,start,end,isCurrent,const DeepCollectionEquality().hash(_bullets),companyGroupId);

@override
String toString() {
  return 'Experience(id: $id, role: $role, company: $company, location: $location, start: $start, end: $end, isCurrent: $isCurrent, bullets: $bullets, companyGroupId: $companyGroupId)';
}


}

/// @nodoc
abstract mixin class _$ExperienceCopyWith<$Res> implements $ExperienceCopyWith<$Res> {
  factory _$ExperienceCopyWith(_Experience value, $Res Function(_Experience) _then) = __$ExperienceCopyWithImpl;
@override @useResult
$Res call({
 String id, String role, String company, String location, YearMonth start, YearMonth? end, bool isCurrent, List<ExperienceBullet> bullets, String? companyGroupId
});


@override $YearMonthCopyWith<$Res> get start;@override $YearMonthCopyWith<$Res>? get end;

}
/// @nodoc
class __$ExperienceCopyWithImpl<$Res>
    implements _$ExperienceCopyWith<$Res> {
  __$ExperienceCopyWithImpl(this._self, this._then);

  final _Experience _self;
  final $Res Function(_Experience) _then;

/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = null,Object? company = null,Object? location = null,Object? start = null,Object? end = freezed,Object? isCurrent = null,Object? bullets = null,Object? companyGroupId = freezed,}) {
  return _then(_Experience(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as YearMonth,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as YearMonth?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ExperienceBullet>,companyGroupId: freezed == companyGroupId ? _self.companyGroupId : companyGroupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$YearMonthCopyWith<$Res> get start {
  
  return $YearMonthCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of Experience
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$YearMonthCopyWith<$Res>? get end {
    if (_self.end == null) {
    return null;
  }

  return $YearMonthCopyWith<$Res>(_self.end!, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}

// dart format on
