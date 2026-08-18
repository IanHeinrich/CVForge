// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileLink {

 String get id; String get label; String get url;
/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileLinkCopyWith<ProfileLink> get copyWith => _$ProfileLinkCopyWithImpl<ProfileLink>(this as ProfileLink, _$identity);

  /// Serializes this ProfileLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLink&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,url);

@override
String toString() {
  return 'ProfileLink(id: $id, label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class $ProfileLinkCopyWith<$Res>  {
  factory $ProfileLinkCopyWith(ProfileLink value, $Res Function(ProfileLink) _then) = _$ProfileLinkCopyWithImpl;
@useResult
$Res call({
 String id, String label, String url
});




}
/// @nodoc
class _$ProfileLinkCopyWithImpl<$Res>
    implements $ProfileLinkCopyWith<$Res> {
  _$ProfileLinkCopyWithImpl(this._self, this._then);

  final ProfileLink _self;
  final $Res Function(ProfileLink) _then;

/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? url = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileLink].
extension ProfileLinkPatterns on ProfileLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileLink value)  $default,){
final _that = this;
switch (_that) {
case _ProfileLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileLink value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
return $default(_that.id,_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String url)  $default,) {final _that = this;
switch (_that) {
case _ProfileLink():
return $default(_that.id,_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
return $default(_that.id,_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileLink implements ProfileLink {
  const _ProfileLink({required this.id, required this.label, required this.url});
  factory _ProfileLink.fromJson(Map<String, dynamic> json) => _$ProfileLinkFromJson(json);

@override final  String id;
@override final  String label;
@override final  String url;

/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileLinkCopyWith<_ProfileLink> get copyWith => __$ProfileLinkCopyWithImpl<_ProfileLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileLink&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,url);

@override
String toString() {
  return 'ProfileLink(id: $id, label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ProfileLinkCopyWith<$Res> implements $ProfileLinkCopyWith<$Res> {
  factory _$ProfileLinkCopyWith(_ProfileLink value, $Res Function(_ProfileLink) _then) = __$ProfileLinkCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String url
});




}
/// @nodoc
class __$ProfileLinkCopyWithImpl<$Res>
    implements _$ProfileLinkCopyWith<$Res> {
  __$ProfileLinkCopyWithImpl(this._self, this._then);

  final _ProfileLink _self;
  final $Res Function(_ProfileLink) _then;

/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? url = null,}) {
  return _then(_ProfileLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
