// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Skill {

 String get id; String get label;/// [CvBullet] ids this skill was demonstrated in — bullet
/// granularity, not experience granularity, because that's the unit a
/// future Copilot actually rewrites (see `CvDraft.bulletOverrides`);
/// grounding at the job level would leave it guessing which of a job's
/// several bullets a given skill applies to. Bullet ids are already
/// globally unique (`Uuid` from `VaultService`), so a flat list here
/// needs no experience id alongside it. Purely descriptive metadata
/// today — the composer/template don't read it.
 List<String> get linkedBulletIds;
/// Create a copy of Skill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillCopyWith<Skill> get copyWith => _$SkillCopyWithImpl<Skill>(this as Skill, _$identity);

  /// Serializes this Skill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Skill&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.linkedBulletIds, linkedBulletIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,const DeepCollectionEquality().hash(linkedBulletIds));

@override
String toString() {
  return 'Skill(id: $id, label: $label, linkedBulletIds: $linkedBulletIds)';
}


}

/// @nodoc
abstract mixin class $SkillCopyWith<$Res>  {
  factory $SkillCopyWith(Skill value, $Res Function(Skill) _then) = _$SkillCopyWithImpl;
@useResult
$Res call({
 String id, String label, List<String> linkedBulletIds
});




}
/// @nodoc
class _$SkillCopyWithImpl<$Res>
    implements $SkillCopyWith<$Res> {
  _$SkillCopyWithImpl(this._self, this._then);

  final Skill _self;
  final $Res Function(Skill) _then;

/// Create a copy of Skill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? linkedBulletIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,linkedBulletIds: null == linkedBulletIds ? _self.linkedBulletIds : linkedBulletIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Skill].
extension SkillPatterns on Skill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Skill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Skill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Skill value)  $default,){
final _that = this;
switch (_that) {
case _Skill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Skill value)?  $default,){
final _that = this;
switch (_that) {
case _Skill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  List<String> linkedBulletIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Skill() when $default != null:
return $default(_that.id,_that.label,_that.linkedBulletIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  List<String> linkedBulletIds)  $default,) {final _that = this;
switch (_that) {
case _Skill():
return $default(_that.id,_that.label,_that.linkedBulletIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  List<String> linkedBulletIds)?  $default,) {final _that = this;
switch (_that) {
case _Skill() when $default != null:
return $default(_that.id,_that.label,_that.linkedBulletIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Skill implements Skill {
  const _Skill({required this.id, required this.label, final  List<String> linkedBulletIds = const <String>[]}): _linkedBulletIds = linkedBulletIds;
  factory _Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);

@override final  String id;
@override final  String label;
/// [CvBullet] ids this skill was demonstrated in — bullet
/// granularity, not experience granularity, because that's the unit a
/// future Copilot actually rewrites (see `CvDraft.bulletOverrides`);
/// grounding at the job level would leave it guessing which of a job's
/// several bullets a given skill applies to. Bullet ids are already
/// globally unique (`Uuid` from `VaultService`), so a flat list here
/// needs no experience id alongside it. Purely descriptive metadata
/// today — the composer/template don't read it.
 final  List<String> _linkedBulletIds;
/// [CvBullet] ids this skill was demonstrated in — bullet
/// granularity, not experience granularity, because that's the unit a
/// future Copilot actually rewrites (see `CvDraft.bulletOverrides`);
/// grounding at the job level would leave it guessing which of a job's
/// several bullets a given skill applies to. Bullet ids are already
/// globally unique (`Uuid` from `VaultService`), so a flat list here
/// needs no experience id alongside it. Purely descriptive metadata
/// today — the composer/template don't read it.
@override@JsonKey() List<String> get linkedBulletIds {
  if (_linkedBulletIds is EqualUnmodifiableListView) return _linkedBulletIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linkedBulletIds);
}


/// Create a copy of Skill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkillCopyWith<_Skill> get copyWith => __$SkillCopyWithImpl<_Skill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Skill&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._linkedBulletIds, _linkedBulletIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,const DeepCollectionEquality().hash(_linkedBulletIds));

@override
String toString() {
  return 'Skill(id: $id, label: $label, linkedBulletIds: $linkedBulletIds)';
}


}

/// @nodoc
abstract mixin class _$SkillCopyWith<$Res> implements $SkillCopyWith<$Res> {
  factory _$SkillCopyWith(_Skill value, $Res Function(_Skill) _then) = __$SkillCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, List<String> linkedBulletIds
});




}
/// @nodoc
class __$SkillCopyWithImpl<$Res>
    implements _$SkillCopyWith<$Res> {
  __$SkillCopyWithImpl(this._self, this._then);

  final _Skill _self;
  final $Res Function(_Skill) _then;

/// Create a copy of Skill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? linkedBulletIds = null,}) {
  return _then(_Skill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,linkedBulletIds: null == linkedBulletIds ? _self._linkedBulletIds : linkedBulletIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
