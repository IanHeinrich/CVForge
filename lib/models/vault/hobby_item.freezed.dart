// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hobby_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HobbyItem {

 String get id; String get text;
/// Create a copy of HobbyItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HobbyItemCopyWith<HobbyItem> get copyWith => _$HobbyItemCopyWithImpl<HobbyItem>(this as HobbyItem, _$identity);

  /// Serializes this HobbyItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HobbyItem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text);

@override
String toString() {
  return 'HobbyItem(id: $id, text: $text)';
}


}

/// @nodoc
abstract mixin class $HobbyItemCopyWith<$Res>  {
  factory $HobbyItemCopyWith(HobbyItem value, $Res Function(HobbyItem) _then) = _$HobbyItemCopyWithImpl;
@useResult
$Res call({
 String id, String text
});




}
/// @nodoc
class _$HobbyItemCopyWithImpl<$Res>
    implements $HobbyItemCopyWith<$Res> {
  _$HobbyItemCopyWithImpl(this._self, this._then);

  final HobbyItem _self;
  final $Res Function(HobbyItem) _then;

/// Create a copy of HobbyItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HobbyItem].
extension HobbyItemPatterns on HobbyItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HobbyItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HobbyItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HobbyItem value)  $default,){
final _that = this;
switch (_that) {
case _HobbyItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HobbyItem value)?  $default,){
final _that = this;
switch (_that) {
case _HobbyItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HobbyItem() when $default != null:
return $default(_that.id,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text)  $default,) {final _that = this;
switch (_that) {
case _HobbyItem():
return $default(_that.id,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text)?  $default,) {final _that = this;
switch (_that) {
case _HobbyItem() when $default != null:
return $default(_that.id,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HobbyItem implements HobbyItem {
  const _HobbyItem({required this.id, required this.text});
  factory _HobbyItem.fromJson(Map<String, dynamic> json) => _$HobbyItemFromJson(json);

@override final  String id;
@override final  String text;

/// Create a copy of HobbyItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HobbyItemCopyWith<_HobbyItem> get copyWith => __$HobbyItemCopyWithImpl<_HobbyItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HobbyItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HobbyItem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text);

@override
String toString() {
  return 'HobbyItem(id: $id, text: $text)';
}


}

/// @nodoc
abstract mixin class _$HobbyItemCopyWith<$Res> implements $HobbyItemCopyWith<$Res> {
  factory _$HobbyItemCopyWith(_HobbyItem value, $Res Function(_HobbyItem) _then) = __$HobbyItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String text
});




}
/// @nodoc
class __$HobbyItemCopyWithImpl<$Res>
    implements _$HobbyItemCopyWith<$Res> {
  __$HobbyItemCopyWithImpl(this._self, this._then);

  final _HobbyItem _self;
  final $Res Function(_HobbyItem) _then;

/// Create a copy of HobbyItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,}) {
  return _then(_HobbyItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
