// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_basics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactBasics {

 String get fullName; String get headline; String get email; String get phone; String get location; String? get summary; List<ProfileLink> get links;/// Uploaded once here and pulled by whichever template renders one —
/// never per draft. A template that declares `TemplateTag.photo` prints
/// it; the others ignore it entirely, so switching template is how a
/// user chooses whether a given document carries a photograph. See
/// `RegionPhotoStance` for which markets expect one.
 CvPhoto? get photo;
/// Create a copy of ContactBasics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactBasicsCopyWith<ContactBasics> get copyWith => _$ContactBasicsCopyWithImpl<ContactBasics>(this as ContactBasics, _$identity);

  /// Serializes this ContactBasics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactBasics&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.location, location) || other.location == location)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.links, links)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,headline,email,phone,location,summary,const DeepCollectionEquality().hash(links),photo);

@override
String toString() {
  return 'ContactBasics(fullName: $fullName, headline: $headline, email: $email, phone: $phone, location: $location, summary: $summary, links: $links, photo: $photo)';
}


}

/// @nodoc
abstract mixin class $ContactBasicsCopyWith<$Res>  {
  factory $ContactBasicsCopyWith(ContactBasics value, $Res Function(ContactBasics) _then) = _$ContactBasicsCopyWithImpl;
@useResult
$Res call({
 String fullName, String headline, String email, String phone, String location, String? summary, List<ProfileLink> links, CvPhoto? photo
});


$CvPhotoCopyWith<$Res>? get photo;

}
/// @nodoc
class _$ContactBasicsCopyWithImpl<$Res>
    implements $ContactBasicsCopyWith<$Res> {
  _$ContactBasicsCopyWithImpl(this._self, this._then);

  final ContactBasics _self;
  final $Res Function(ContactBasics) _then;

/// Create a copy of ContactBasics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? headline = null,Object? email = null,Object? phone = null,Object? location = null,Object? summary = freezed,Object? links = null,Object? photo = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileLink>,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as CvPhoto?,
  ));
}
/// Create a copy of ContactBasics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvPhotoCopyWith<$Res>? get photo {
    if (_self.photo == null) {
    return null;
  }

  return $CvPhotoCopyWith<$Res>(_self.photo!, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactBasics].
extension ContactBasicsPatterns on ContactBasics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactBasics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactBasics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactBasics value)  $default,){
final _that = this;
switch (_that) {
case _ContactBasics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactBasics value)?  $default,){
final _that = this;
switch (_that) {
case _ContactBasics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String headline,  String email,  String phone,  String location,  String? summary,  List<ProfileLink> links,  CvPhoto? photo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactBasics() when $default != null:
return $default(_that.fullName,_that.headline,_that.email,_that.phone,_that.location,_that.summary,_that.links,_that.photo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String headline,  String email,  String phone,  String location,  String? summary,  List<ProfileLink> links,  CvPhoto? photo)  $default,) {final _that = this;
switch (_that) {
case _ContactBasics():
return $default(_that.fullName,_that.headline,_that.email,_that.phone,_that.location,_that.summary,_that.links,_that.photo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String headline,  String email,  String phone,  String location,  String? summary,  List<ProfileLink> links,  CvPhoto? photo)?  $default,) {final _that = this;
switch (_that) {
case _ContactBasics() when $default != null:
return $default(_that.fullName,_that.headline,_that.email,_that.phone,_that.location,_that.summary,_that.links,_that.photo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactBasics implements ContactBasics {
  const _ContactBasics({required this.fullName, required this.headline, required this.email, required this.phone, required this.location, this.summary, final  List<ProfileLink> links = const <ProfileLink>[], this.photo}): _links = links;
  factory _ContactBasics.fromJson(Map<String, dynamic> json) => _$ContactBasicsFromJson(json);

@override final  String fullName;
@override final  String headline;
@override final  String email;
@override final  String phone;
@override final  String location;
@override final  String? summary;
 final  List<ProfileLink> _links;
@override@JsonKey() List<ProfileLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}

/// Uploaded once here and pulled by whichever template renders one —
/// never per draft. A template that declares `TemplateTag.photo` prints
/// it; the others ignore it entirely, so switching template is how a
/// user chooses whether a given document carries a photograph. See
/// `RegionPhotoStance` for which markets expect one.
@override final  CvPhoto? photo;

/// Create a copy of ContactBasics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactBasicsCopyWith<_ContactBasics> get copyWith => __$ContactBasicsCopyWithImpl<_ContactBasics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactBasicsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactBasics&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.location, location) || other.location == location)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._links, _links)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,headline,email,phone,location,summary,const DeepCollectionEquality().hash(_links),photo);

@override
String toString() {
  return 'ContactBasics(fullName: $fullName, headline: $headline, email: $email, phone: $phone, location: $location, summary: $summary, links: $links, photo: $photo)';
}


}

/// @nodoc
abstract mixin class _$ContactBasicsCopyWith<$Res> implements $ContactBasicsCopyWith<$Res> {
  factory _$ContactBasicsCopyWith(_ContactBasics value, $Res Function(_ContactBasics) _then) = __$ContactBasicsCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String headline, String email, String phone, String location, String? summary, List<ProfileLink> links, CvPhoto? photo
});


@override $CvPhotoCopyWith<$Res>? get photo;

}
/// @nodoc
class __$ContactBasicsCopyWithImpl<$Res>
    implements _$ContactBasicsCopyWith<$Res> {
  __$ContactBasicsCopyWithImpl(this._self, this._then);

  final _ContactBasics _self;
  final $Res Function(_ContactBasics) _then;

/// Create a copy of ContactBasics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? headline = null,Object? email = null,Object? phone = null,Object? location = null,Object? summary = freezed,Object? links = null,Object? photo = freezed,}) {
  return _then(_ContactBasics(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileLink>,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as CvPhoto?,
  ));
}

/// Create a copy of ContactBasics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvPhotoCopyWith<$Res>? get photo {
    if (_self.photo == null) {
    return null;
  }

  return $CvPhotoCopyWith<$Res>(_self.photo!, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}

// dart format on
