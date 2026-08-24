// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resolved_cv.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResolvedCv {

 ResolvedHeader get header; List<ResolvedSection> get sections;
/// Create a copy of ResolvedCv
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedCvCopyWith<ResolvedCv> get copyWith => _$ResolvedCvCopyWithImpl<ResolvedCv>(this as ResolvedCv, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedCv&&(identical(other.header, header) || other.header == header)&&const DeepCollectionEquality().equals(other.sections, sections));
}


@override
int get hashCode => Object.hash(runtimeType,header,const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'ResolvedCv(header: $header, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $ResolvedCvCopyWith<$Res>  {
  factory $ResolvedCvCopyWith(ResolvedCv value, $Res Function(ResolvedCv) _then) = _$ResolvedCvCopyWithImpl;
@useResult
$Res call({
 ResolvedHeader header, List<ResolvedSection> sections
});


$ResolvedHeaderCopyWith<$Res> get header;

}
/// @nodoc
class _$ResolvedCvCopyWithImpl<$Res>
    implements $ResolvedCvCopyWith<$Res> {
  _$ResolvedCvCopyWithImpl(this._self, this._then);

  final ResolvedCv _self;
  final $Res Function(ResolvedCv) _then;

/// Create a copy of ResolvedCv
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? header = null,Object? sections = null,}) {
  return _then(_self.copyWith(
header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as ResolvedHeader,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<ResolvedSection>,
  ));
}
/// Create a copy of ResolvedCv
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResolvedHeaderCopyWith<$Res> get header {
  
  return $ResolvedHeaderCopyWith<$Res>(_self.header, (value) {
    return _then(_self.copyWith(header: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResolvedCv].
extension ResolvedCvPatterns on ResolvedCv {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedCv value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedCv() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedCv value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedCv():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedCv value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedCv() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResolvedHeader header,  List<ResolvedSection> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedCv() when $default != null:
return $default(_that.header,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResolvedHeader header,  List<ResolvedSection> sections)  $default,) {final _that = this;
switch (_that) {
case _ResolvedCv():
return $default(_that.header,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResolvedHeader header,  List<ResolvedSection> sections)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedCv() when $default != null:
return $default(_that.header,_that.sections);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedCv implements ResolvedCv {
  const _ResolvedCv({required this.header, required final  List<ResolvedSection> sections}): _sections = sections;
  

@override final  ResolvedHeader header;
 final  List<ResolvedSection> _sections;
@override List<ResolvedSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of ResolvedCv
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedCvCopyWith<_ResolvedCv> get copyWith => __$ResolvedCvCopyWithImpl<_ResolvedCv>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedCv&&(identical(other.header, header) || other.header == header)&&const DeepCollectionEquality().equals(other._sections, _sections));
}


@override
int get hashCode => Object.hash(runtimeType,header,const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'ResolvedCv(header: $header, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$ResolvedCvCopyWith<$Res> implements $ResolvedCvCopyWith<$Res> {
  factory _$ResolvedCvCopyWith(_ResolvedCv value, $Res Function(_ResolvedCv) _then) = __$ResolvedCvCopyWithImpl;
@override @useResult
$Res call({
 ResolvedHeader header, List<ResolvedSection> sections
});


@override $ResolvedHeaderCopyWith<$Res> get header;

}
/// @nodoc
class __$ResolvedCvCopyWithImpl<$Res>
    implements _$ResolvedCvCopyWith<$Res> {
  __$ResolvedCvCopyWithImpl(this._self, this._then);

  final _ResolvedCv _self;
  final $Res Function(_ResolvedCv) _then;

/// Create a copy of ResolvedCv
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? header = null,Object? sections = null,}) {
  return _then(_ResolvedCv(
header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as ResolvedHeader,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<ResolvedSection>,
  ));
}

/// Create a copy of ResolvedCv
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResolvedHeaderCopyWith<$Res> get header {
  
  return $ResolvedHeaderCopyWith<$Res>(_self.header, (value) {
    return _then(_self.copyWith(header: value));
  });
}
}

/// @nodoc
mixin _$ResolvedHeader {

 String get fullName; String get headline; String get email; String get phone; String get location; List<ResolvedLink> get links;/// The Vault photo's JPEG bytes, base64-encoded — carried as the raw
/// scalar rather than as `CvPhoto` so this file keeps its "templates
/// never see a Vault type" boundary, and as a `String` rather than
/// `Uint8List` so [ResolvedHeader] keeps value equality (see
/// [CvPhoto]'s doc comment for what depends on that).
///
/// Always populated when the Vault holds a photo, whatever the draft's
/// template — deciding whether to print it is the template's job, not
/// the composer's.
 String? get photoJpegBase64;
/// Create a copy of ResolvedHeader
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedHeaderCopyWith<ResolvedHeader> get copyWith => _$ResolvedHeaderCopyWithImpl<ResolvedHeader>(this as ResolvedHeader, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedHeader&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.links, links)&&(identical(other.photoJpegBase64, photoJpegBase64) || other.photoJpegBase64 == photoJpegBase64));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,headline,email,phone,location,const DeepCollectionEquality().hash(links),photoJpegBase64);

@override
String toString() {
  return 'ResolvedHeader(fullName: $fullName, headline: $headline, email: $email, phone: $phone, location: $location, links: $links, photoJpegBase64: $photoJpegBase64)';
}


}

/// @nodoc
abstract mixin class $ResolvedHeaderCopyWith<$Res>  {
  factory $ResolvedHeaderCopyWith(ResolvedHeader value, $Res Function(ResolvedHeader) _then) = _$ResolvedHeaderCopyWithImpl;
@useResult
$Res call({
 String fullName, String headline, String email, String phone, String location, List<ResolvedLink> links, String? photoJpegBase64
});




}
/// @nodoc
class _$ResolvedHeaderCopyWithImpl<$Res>
    implements $ResolvedHeaderCopyWith<$Res> {
  _$ResolvedHeaderCopyWithImpl(this._self, this._then);

  final ResolvedHeader _self;
  final $Res Function(ResolvedHeader) _then;

/// Create a copy of ResolvedHeader
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? headline = null,Object? email = null,Object? phone = null,Object? location = null,Object? links = null,Object? photoJpegBase64 = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<ResolvedLink>,photoJpegBase64: freezed == photoJpegBase64 ? _self.photoJpegBase64 : photoJpegBase64 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedHeader].
extension ResolvedHeaderPatterns on ResolvedHeader {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedHeader value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedHeader() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedHeader value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedHeader():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedHeader value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedHeader() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String headline,  String email,  String phone,  String location,  List<ResolvedLink> links,  String? photoJpegBase64)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedHeader() when $default != null:
return $default(_that.fullName,_that.headline,_that.email,_that.phone,_that.location,_that.links,_that.photoJpegBase64);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String headline,  String email,  String phone,  String location,  List<ResolvedLink> links,  String? photoJpegBase64)  $default,) {final _that = this;
switch (_that) {
case _ResolvedHeader():
return $default(_that.fullName,_that.headline,_that.email,_that.phone,_that.location,_that.links,_that.photoJpegBase64);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String headline,  String email,  String phone,  String location,  List<ResolvedLink> links,  String? photoJpegBase64)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedHeader() when $default != null:
return $default(_that.fullName,_that.headline,_that.email,_that.phone,_that.location,_that.links,_that.photoJpegBase64);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedHeader implements ResolvedHeader {
  const _ResolvedHeader({required this.fullName, required this.headline, required this.email, required this.phone, required this.location, final  List<ResolvedLink> links = const <ResolvedLink>[], this.photoJpegBase64}): _links = links;
  

@override final  String fullName;
@override final  String headline;
@override final  String email;
@override final  String phone;
@override final  String location;
 final  List<ResolvedLink> _links;
@override@JsonKey() List<ResolvedLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}

/// The Vault photo's JPEG bytes, base64-encoded — carried as the raw
/// scalar rather than as `CvPhoto` so this file keeps its "templates
/// never see a Vault type" boundary, and as a `String` rather than
/// `Uint8List` so [ResolvedHeader] keeps value equality (see
/// [CvPhoto]'s doc comment for what depends on that).
///
/// Always populated when the Vault holds a photo, whatever the draft's
/// template — deciding whether to print it is the template's job, not
/// the composer's.
@override final  String? photoJpegBase64;

/// Create a copy of ResolvedHeader
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedHeaderCopyWith<_ResolvedHeader> get copyWith => __$ResolvedHeaderCopyWithImpl<_ResolvedHeader>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedHeader&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._links, _links)&&(identical(other.photoJpegBase64, photoJpegBase64) || other.photoJpegBase64 == photoJpegBase64));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,headline,email,phone,location,const DeepCollectionEquality().hash(_links),photoJpegBase64);

@override
String toString() {
  return 'ResolvedHeader(fullName: $fullName, headline: $headline, email: $email, phone: $phone, location: $location, links: $links, photoJpegBase64: $photoJpegBase64)';
}


}

/// @nodoc
abstract mixin class _$ResolvedHeaderCopyWith<$Res> implements $ResolvedHeaderCopyWith<$Res> {
  factory _$ResolvedHeaderCopyWith(_ResolvedHeader value, $Res Function(_ResolvedHeader) _then) = __$ResolvedHeaderCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String headline, String email, String phone, String location, List<ResolvedLink> links, String? photoJpegBase64
});




}
/// @nodoc
class __$ResolvedHeaderCopyWithImpl<$Res>
    implements _$ResolvedHeaderCopyWith<$Res> {
  __$ResolvedHeaderCopyWithImpl(this._self, this._then);

  final _ResolvedHeader _self;
  final $Res Function(_ResolvedHeader) _then;

/// Create a copy of ResolvedHeader
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? headline = null,Object? email = null,Object? phone = null,Object? location = null,Object? links = null,Object? photoJpegBase64 = freezed,}) {
  return _then(_ResolvedHeader(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<ResolvedLink>,photoJpegBase64: freezed == photoJpegBase64 ? _self.photoJpegBase64 : photoJpegBase64 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ResolvedLink {

 String get label; String get url;
/// Create a copy of ResolvedLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedLinkCopyWith<ResolvedLink> get copyWith => _$ResolvedLinkCopyWithImpl<ResolvedLink>(this as ResolvedLink, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedLink&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'ResolvedLink(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class $ResolvedLinkCopyWith<$Res>  {
  factory $ResolvedLinkCopyWith(ResolvedLink value, $Res Function(ResolvedLink) _then) = _$ResolvedLinkCopyWithImpl;
@useResult
$Res call({
 String label, String url
});




}
/// @nodoc
class _$ResolvedLinkCopyWithImpl<$Res>
    implements $ResolvedLinkCopyWith<$Res> {
  _$ResolvedLinkCopyWithImpl(this._self, this._then);

  final ResolvedLink _self;
  final $Res Function(ResolvedLink) _then;

/// Create a copy of ResolvedLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? url = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedLink].
extension ResolvedLinkPatterns on ResolvedLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedLink value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedLink value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedLink() when $default != null:
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String url)  $default,) {final _that = this;
switch (_that) {
case _ResolvedLink():
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedLink() when $default != null:
return $default(_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedLink implements ResolvedLink {
  const _ResolvedLink({required this.label, required this.url});
  

@override final  String label;
@override final  String url;

/// Create a copy of ResolvedLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedLinkCopyWith<_ResolvedLink> get copyWith => __$ResolvedLinkCopyWithImpl<_ResolvedLink>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedLink&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'ResolvedLink(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ResolvedLinkCopyWith<$Res> implements $ResolvedLinkCopyWith<$Res> {
  factory _$ResolvedLinkCopyWith(_ResolvedLink value, $Res Function(_ResolvedLink) _then) = __$ResolvedLinkCopyWithImpl;
@override @useResult
$Res call({
 String label, String url
});




}
/// @nodoc
class __$ResolvedLinkCopyWithImpl<$Res>
    implements _$ResolvedLinkCopyWith<$Res> {
  __$ResolvedLinkCopyWithImpl(this._self, this._then);

  final _ResolvedLink _self;
  final $Res Function(_ResolvedLink) _then;

/// Create a copy of ResolvedLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? url = null,}) {
  return _then(_ResolvedLink(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
