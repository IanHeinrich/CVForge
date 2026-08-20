// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ats_extracted_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AtsExtractedDocument {

 AtsDocumentInfo get info; List<AtsTextNode> get nodes;/// Keyed by `AtsTextNode.fontName`.
 Map<String, AtsFontInfo> get fonts; List<AtsLinkAnnotation> get links;
/// Create a copy of AtsExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsExtractedDocumentCopyWith<AtsExtractedDocument> get copyWith => _$AtsExtractedDocumentCopyWithImpl<AtsExtractedDocument>(this as AtsExtractedDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsExtractedDocument&&(identical(other.info, info) || other.info == info)&&const DeepCollectionEquality().equals(other.nodes, nodes)&&const DeepCollectionEquality().equals(other.fonts, fonts)&&const DeepCollectionEquality().equals(other.links, links));
}


@override
int get hashCode => Object.hash(runtimeType,info,const DeepCollectionEquality().hash(nodes),const DeepCollectionEquality().hash(fonts),const DeepCollectionEquality().hash(links));

@override
String toString() {
  return 'AtsExtractedDocument(info: $info, nodes: $nodes, fonts: $fonts, links: $links)';
}


}

/// @nodoc
abstract mixin class $AtsExtractedDocumentCopyWith<$Res>  {
  factory $AtsExtractedDocumentCopyWith(AtsExtractedDocument value, $Res Function(AtsExtractedDocument) _then) = _$AtsExtractedDocumentCopyWithImpl;
@useResult
$Res call({
 AtsDocumentInfo info, List<AtsTextNode> nodes, Map<String, AtsFontInfo> fonts, List<AtsLinkAnnotation> links
});


$AtsDocumentInfoCopyWith<$Res> get info;

}
/// @nodoc
class _$AtsExtractedDocumentCopyWithImpl<$Res>
    implements $AtsExtractedDocumentCopyWith<$Res> {
  _$AtsExtractedDocumentCopyWithImpl(this._self, this._then);

  final AtsExtractedDocument _self;
  final $Res Function(AtsExtractedDocument) _then;

/// Create a copy of AtsExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? info = null,Object? nodes = null,Object? fonts = null,Object? links = null,}) {
  return _then(_self.copyWith(
info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AtsDocumentInfo,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<AtsTextNode>,fonts: null == fonts ? _self.fonts : fonts // ignore: cast_nullable_to_non_nullable
as Map<String, AtsFontInfo>,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<AtsLinkAnnotation>,
  ));
}
/// Create a copy of AtsExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AtsDocumentInfoCopyWith<$Res> get info {
  
  return $AtsDocumentInfoCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}


/// Adds pattern-matching-related methods to [AtsExtractedDocument].
extension AtsExtractedDocumentPatterns on AtsExtractedDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsExtractedDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsExtractedDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsExtractedDocument value)  $default,){
final _that = this;
switch (_that) {
case _AtsExtractedDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsExtractedDocument value)?  $default,){
final _that = this;
switch (_that) {
case _AtsExtractedDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AtsDocumentInfo info,  List<AtsTextNode> nodes,  Map<String, AtsFontInfo> fonts,  List<AtsLinkAnnotation> links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsExtractedDocument() when $default != null:
return $default(_that.info,_that.nodes,_that.fonts,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AtsDocumentInfo info,  List<AtsTextNode> nodes,  Map<String, AtsFontInfo> fonts,  List<AtsLinkAnnotation> links)  $default,) {final _that = this;
switch (_that) {
case _AtsExtractedDocument():
return $default(_that.info,_that.nodes,_that.fonts,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AtsDocumentInfo info,  List<AtsTextNode> nodes,  Map<String, AtsFontInfo> fonts,  List<AtsLinkAnnotation> links)?  $default,) {final _that = this;
switch (_that) {
case _AtsExtractedDocument() when $default != null:
return $default(_that.info,_that.nodes,_that.fonts,_that.links);case _:
  return null;

}
}

}

/// @nodoc


class _AtsExtractedDocument implements AtsExtractedDocument {
  const _AtsExtractedDocument({required this.info, required final  List<AtsTextNode> nodes, required final  Map<String, AtsFontInfo> fonts, final  List<AtsLinkAnnotation> links = const <AtsLinkAnnotation>[]}): _nodes = nodes,_fonts = fonts,_links = links;
  

@override final  AtsDocumentInfo info;
 final  List<AtsTextNode> _nodes;
@override List<AtsTextNode> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}

/// Keyed by `AtsTextNode.fontName`.
 final  Map<String, AtsFontInfo> _fonts;
/// Keyed by `AtsTextNode.fontName`.
@override Map<String, AtsFontInfo> get fonts {
  if (_fonts is EqualUnmodifiableMapView) return _fonts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fonts);
}

 final  List<AtsLinkAnnotation> _links;
@override@JsonKey() List<AtsLinkAnnotation> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}


/// Create a copy of AtsExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsExtractedDocumentCopyWith<_AtsExtractedDocument> get copyWith => __$AtsExtractedDocumentCopyWithImpl<_AtsExtractedDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsExtractedDocument&&(identical(other.info, info) || other.info == info)&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&const DeepCollectionEquality().equals(other._fonts, _fonts)&&const DeepCollectionEquality().equals(other._links, _links));
}


@override
int get hashCode => Object.hash(runtimeType,info,const DeepCollectionEquality().hash(_nodes),const DeepCollectionEquality().hash(_fonts),const DeepCollectionEquality().hash(_links));

@override
String toString() {
  return 'AtsExtractedDocument(info: $info, nodes: $nodes, fonts: $fonts, links: $links)';
}


}

/// @nodoc
abstract mixin class _$AtsExtractedDocumentCopyWith<$Res> implements $AtsExtractedDocumentCopyWith<$Res> {
  factory _$AtsExtractedDocumentCopyWith(_AtsExtractedDocument value, $Res Function(_AtsExtractedDocument) _then) = __$AtsExtractedDocumentCopyWithImpl;
@override @useResult
$Res call({
 AtsDocumentInfo info, List<AtsTextNode> nodes, Map<String, AtsFontInfo> fonts, List<AtsLinkAnnotation> links
});


@override $AtsDocumentInfoCopyWith<$Res> get info;

}
/// @nodoc
class __$AtsExtractedDocumentCopyWithImpl<$Res>
    implements _$AtsExtractedDocumentCopyWith<$Res> {
  __$AtsExtractedDocumentCopyWithImpl(this._self, this._then);

  final _AtsExtractedDocument _self;
  final $Res Function(_AtsExtractedDocument) _then;

/// Create a copy of AtsExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? info = null,Object? nodes = null,Object? fonts = null,Object? links = null,}) {
  return _then(_AtsExtractedDocument(
info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AtsDocumentInfo,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<AtsTextNode>,fonts: null == fonts ? _self._fonts : fonts // ignore: cast_nullable_to_non_nullable
as Map<String, AtsFontInfo>,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<AtsLinkAnnotation>,
  ));
}

/// Create a copy of AtsExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AtsDocumentInfoCopyWith<$Res> get info {
  
  return $AtsDocumentInfoCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}

// dart format on
