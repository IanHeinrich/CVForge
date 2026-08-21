// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publication.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Publication {

 String get id; String get title;/// Author/venue/year detail, e.g. "Trujillo, L. (2021). AUC
/// Interpretationes, 11(2), 194–206." Free text, optional — a
/// publication with just a title is still valid.
 String? get citation; String? get link;/// Same role as [Project.bullets] — supporting detail a candidate
/// might want to surface under a publication (e.g. "Cited by 40+
/// subsequent papers", "Led the fieldwork component"), selected and
/// reordered per-draft exactly like project bullets are.
 List<CvBullet> get bullets;
/// Create a copy of Publication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicationCopyWith<Publication> get copyWith => _$PublicationCopyWithImpl<Publication>(this as Publication, _$identity);

  /// Serializes this Publication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Publication&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.citation, citation) || other.citation == citation)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other.bullets, bullets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,citation,link,const DeepCollectionEquality().hash(bullets));

@override
String toString() {
  return 'Publication(id: $id, title: $title, citation: $citation, link: $link, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class $PublicationCopyWith<$Res>  {
  factory $PublicationCopyWith(Publication value, $Res Function(Publication) _then) = _$PublicationCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? citation, String? link, List<CvBullet> bullets
});




}
/// @nodoc
class _$PublicationCopyWithImpl<$Res>
    implements $PublicationCopyWith<$Res> {
  _$PublicationCopyWithImpl(this._self, this._then);

  final Publication _self;
  final $Res Function(Publication) _then;

/// Create a copy of Publication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? citation = freezed,Object? link = freezed,Object? bullets = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,citation: freezed == citation ? _self.citation : citation // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<CvBullet>,
  ));
}

}


/// Adds pattern-matching-related methods to [Publication].
extension PublicationPatterns on Publication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Publication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Publication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Publication value)  $default,){
final _that = this;
switch (_that) {
case _Publication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Publication value)?  $default,){
final _that = this;
switch (_that) {
case _Publication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? citation,  String? link,  List<CvBullet> bullets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Publication() when $default != null:
return $default(_that.id,_that.title,_that.citation,_that.link,_that.bullets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? citation,  String? link,  List<CvBullet> bullets)  $default,) {final _that = this;
switch (_that) {
case _Publication():
return $default(_that.id,_that.title,_that.citation,_that.link,_that.bullets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? citation,  String? link,  List<CvBullet> bullets)?  $default,) {final _that = this;
switch (_that) {
case _Publication() when $default != null:
return $default(_that.id,_that.title,_that.citation,_that.link,_that.bullets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Publication implements Publication {
  const _Publication({required this.id, required this.title, this.citation, this.link, final  List<CvBullet> bullets = const <CvBullet>[]}): _bullets = bullets;
  factory _Publication.fromJson(Map<String, dynamic> json) => _$PublicationFromJson(json);

@override final  String id;
@override final  String title;
/// Author/venue/year detail, e.g. "Trujillo, L. (2021). AUC
/// Interpretationes, 11(2), 194–206." Free text, optional — a
/// publication with just a title is still valid.
@override final  String? citation;
@override final  String? link;
/// Same role as [Project.bullets] — supporting detail a candidate
/// might want to surface under a publication (e.g. "Cited by 40+
/// subsequent papers", "Led the fieldwork component"), selected and
/// reordered per-draft exactly like project bullets are.
 final  List<CvBullet> _bullets;
/// Same role as [Project.bullets] — supporting detail a candidate
/// might want to surface under a publication (e.g. "Cited by 40+
/// subsequent papers", "Led the fieldwork component"), selected and
/// reordered per-draft exactly like project bullets are.
@override@JsonKey() List<CvBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}


/// Create a copy of Publication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicationCopyWith<_Publication> get copyWith => __$PublicationCopyWithImpl<_Publication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Publication&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.citation, citation) || other.citation == citation)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other._bullets, _bullets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,citation,link,const DeepCollectionEquality().hash(_bullets));

@override
String toString() {
  return 'Publication(id: $id, title: $title, citation: $citation, link: $link, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class _$PublicationCopyWith<$Res> implements $PublicationCopyWith<$Res> {
  factory _$PublicationCopyWith(_Publication value, $Res Function(_Publication) _then) = __$PublicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? citation, String? link, List<CvBullet> bullets
});




}
/// @nodoc
class __$PublicationCopyWithImpl<$Res>
    implements _$PublicationCopyWith<$Res> {
  __$PublicationCopyWithImpl(this._self, this._then);

  final _Publication _self;
  final $Res Function(_Publication) _then;

/// Create a copy of Publication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? citation = freezed,Object? link = freezed,Object? bullets = null,}) {
  return _then(_Publication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,citation: freezed == citation ? _self.citation : citation // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<CvBullet>,
  ));
}


}

// dart format on
