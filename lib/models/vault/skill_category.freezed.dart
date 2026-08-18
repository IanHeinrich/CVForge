// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skill_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SkillCategory {

 String get id; String get name; List<Skill> get skills;
/// Create a copy of SkillCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillCategoryCopyWith<SkillCategory> get copyWith => _$SkillCategoryCopyWithImpl<SkillCategory>(this as SkillCategory, _$identity);

  /// Serializes this SkillCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.skills, skills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(skills));

@override
String toString() {
  return 'SkillCategory(id: $id, name: $name, skills: $skills)';
}


}

/// @nodoc
abstract mixin class $SkillCategoryCopyWith<$Res>  {
  factory $SkillCategoryCopyWith(SkillCategory value, $Res Function(SkillCategory) _then) = _$SkillCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<Skill> skills
});




}
/// @nodoc
class _$SkillCategoryCopyWithImpl<$Res>
    implements $SkillCategoryCopyWith<$Res> {
  _$SkillCategoryCopyWithImpl(this._self, this._then);

  final SkillCategory _self;
  final $Res Function(SkillCategory) _then;

/// Create a copy of SkillCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? skills = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as List<Skill>,
  ));
}

}


/// Adds pattern-matching-related methods to [SkillCategory].
extension SkillCategoryPatterns on SkillCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkillCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkillCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkillCategory value)  $default,){
final _that = this;
switch (_that) {
case _SkillCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkillCategory value)?  $default,){
final _that = this;
switch (_that) {
case _SkillCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<Skill> skills)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkillCategory() when $default != null:
return $default(_that.id,_that.name,_that.skills);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<Skill> skills)  $default,) {final _that = this;
switch (_that) {
case _SkillCategory():
return $default(_that.id,_that.name,_that.skills);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<Skill> skills)?  $default,) {final _that = this;
switch (_that) {
case _SkillCategory() when $default != null:
return $default(_that.id,_that.name,_that.skills);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SkillCategory implements SkillCategory {
  const _SkillCategory({required this.id, required this.name, final  List<Skill> skills = const <Skill>[]}): _skills = skills;
  factory _SkillCategory.fromJson(Map<String, dynamic> json) => _$SkillCategoryFromJson(json);

@override final  String id;
@override final  String name;
 final  List<Skill> _skills;
@override@JsonKey() List<Skill> get skills {
  if (_skills is EqualUnmodifiableListView) return _skills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skills);
}


/// Create a copy of SkillCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkillCategoryCopyWith<_SkillCategory> get copyWith => __$SkillCategoryCopyWithImpl<_SkillCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkillCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkillCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._skills, _skills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_skills));

@override
String toString() {
  return 'SkillCategory(id: $id, name: $name, skills: $skills)';
}


}

/// @nodoc
abstract mixin class _$SkillCategoryCopyWith<$Res> implements $SkillCategoryCopyWith<$Res> {
  factory _$SkillCategoryCopyWith(_SkillCategory value, $Res Function(_SkillCategory) _then) = __$SkillCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<Skill> skills
});




}
/// @nodoc
class __$SkillCategoryCopyWithImpl<$Res>
    implements _$SkillCategoryCopyWith<$Res> {
  __$SkillCategoryCopyWithImpl(this._self, this._then);

  final _SkillCategory _self;
  final $Res Function(_SkillCategory) _then;

/// Create a copy of SkillCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? skills = null,}) {
  return _then(_SkillCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<Skill>,
  ));
}


}

// dart format on
