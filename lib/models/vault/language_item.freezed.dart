// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LanguageItem {

 String get id; String get name;/// Null prints the language on its own, with no level beside it —
/// which is what someone listing a language they don't want to grade
/// actually wants.
 LanguageProficiency? get proficiency;
/// Create a copy of LanguageItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LanguageItemCopyWith<LanguageItem> get copyWith => _$LanguageItemCopyWithImpl<LanguageItem>(this as LanguageItem, _$identity);

  /// Serializes this LanguageItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanguageItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.proficiency, proficiency) || other.proficiency == proficiency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,proficiency);

@override
String toString() {
  return 'LanguageItem(id: $id, name: $name, proficiency: $proficiency)';
}


}

/// @nodoc
abstract mixin class $LanguageItemCopyWith<$Res>  {
  factory $LanguageItemCopyWith(LanguageItem value, $Res Function(LanguageItem) _then) = _$LanguageItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, LanguageProficiency? proficiency
});




}
/// @nodoc
class _$LanguageItemCopyWithImpl<$Res>
    implements $LanguageItemCopyWith<$Res> {
  _$LanguageItemCopyWithImpl(this._self, this._then);

  final LanguageItem _self;
  final $Res Function(LanguageItem) _then;

/// Create a copy of LanguageItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? proficiency = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,proficiency: freezed == proficiency ? _self.proficiency : proficiency // ignore: cast_nullable_to_non_nullable
as LanguageProficiency?,
  ));
}

}


/// Adds pattern-matching-related methods to [LanguageItem].
extension LanguageItemPatterns on LanguageItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LanguageItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LanguageItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LanguageItem value)  $default,){
final _that = this;
switch (_that) {
case _LanguageItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LanguageItem value)?  $default,){
final _that = this;
switch (_that) {
case _LanguageItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  LanguageProficiency? proficiency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LanguageItem() when $default != null:
return $default(_that.id,_that.name,_that.proficiency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  LanguageProficiency? proficiency)  $default,) {final _that = this;
switch (_that) {
case _LanguageItem():
return $default(_that.id,_that.name,_that.proficiency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  LanguageProficiency? proficiency)?  $default,) {final _that = this;
switch (_that) {
case _LanguageItem() when $default != null:
return $default(_that.id,_that.name,_that.proficiency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LanguageItem implements LanguageItem {
  const _LanguageItem({required this.id, required this.name, this.proficiency});
  factory _LanguageItem.fromJson(Map<String, dynamic> json) => _$LanguageItemFromJson(json);

@override final  String id;
@override final  String name;
/// Null prints the language on its own, with no level beside it —
/// which is what someone listing a language they don't want to grade
/// actually wants.
@override final  LanguageProficiency? proficiency;

/// Create a copy of LanguageItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LanguageItemCopyWith<_LanguageItem> get copyWith => __$LanguageItemCopyWithImpl<_LanguageItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LanguageItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LanguageItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.proficiency, proficiency) || other.proficiency == proficiency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,proficiency);

@override
String toString() {
  return 'LanguageItem(id: $id, name: $name, proficiency: $proficiency)';
}


}

/// @nodoc
abstract mixin class _$LanguageItemCopyWith<$Res> implements $LanguageItemCopyWith<$Res> {
  factory _$LanguageItemCopyWith(_LanguageItem value, $Res Function(_LanguageItem) _then) = __$LanguageItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, LanguageProficiency? proficiency
});




}
/// @nodoc
class __$LanguageItemCopyWithImpl<$Res>
    implements _$LanguageItemCopyWith<$Res> {
  __$LanguageItemCopyWithImpl(this._self, this._then);

  final _LanguageItem _self;
  final $Res Function(_LanguageItem) _then;

/// Create a copy of LanguageItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? proficiency = freezed,}) {
  return _then(_LanguageItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,proficiency: freezed == proficiency ? _self.proficiency : proficiency // ignore: cast_nullable_to_non_nullable
as LanguageProficiency?,
  ));
}


}

// dart format on
