// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ats_text_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AtsTextNode {

 int get pageIndex; String get str; AtsTextMatrix get transform;/// The advance width along the text direction — an *advance* box, not
/// an *ink* box. Confirmed in the spike: a dropped/unmapped glyph
/// (e.g. a PUA bullet drawn with a non-embedded font) can leave a
/// nonzero [width] with no corresponding characters in [str] — see
/// `AtsAnalyzerService`'s phantom-glyph check, which exists because of
/// exactly that finding.
 double get width;/// The rotation-invariant effective em size — `hypot(transform.c,
/// transform.d)` on every real content run in the spike's corpus.
/// `0` on synthetic empty/EOL marker runs (`str.isEmpty`); always
/// filter those out before using this for a font-size-based check.
 double get height;/// `pdf.js`'s internal font id (e.g. `g_d0_f1`) — a key into
/// `AtsExtractedDocument.fonts`, not a user-facing name.
 String get fontName; bool get hasEol;
/// Create a copy of AtsTextNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsTextNodeCopyWith<AtsTextNode> get copyWith => _$AtsTextNodeCopyWithImpl<AtsTextNode>(this as AtsTextNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsTextNode&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.str, str) || other.str == str)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.fontName, fontName) || other.fontName == fontName)&&(identical(other.hasEol, hasEol) || other.hasEol == hasEol));
}


@override
int get hashCode => Object.hash(runtimeType,pageIndex,str,transform,width,height,fontName,hasEol);

@override
String toString() {
  return 'AtsTextNode(pageIndex: $pageIndex, str: $str, transform: $transform, width: $width, height: $height, fontName: $fontName, hasEol: $hasEol)';
}


}

/// @nodoc
abstract mixin class $AtsTextNodeCopyWith<$Res>  {
  factory $AtsTextNodeCopyWith(AtsTextNode value, $Res Function(AtsTextNode) _then) = _$AtsTextNodeCopyWithImpl;
@useResult
$Res call({
 int pageIndex, String str, AtsTextMatrix transform, double width, double height, String fontName, bool hasEol
});


$AtsTextMatrixCopyWith<$Res> get transform;

}
/// @nodoc
class _$AtsTextNodeCopyWithImpl<$Res>
    implements $AtsTextNodeCopyWith<$Res> {
  _$AtsTextNodeCopyWithImpl(this._self, this._then);

  final AtsTextNode _self;
  final $Res Function(AtsTextNode) _then;

/// Create a copy of AtsTextNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageIndex = null,Object? str = null,Object? transform = null,Object? width = null,Object? height = null,Object? fontName = null,Object? hasEol = null,}) {
  return _then(_self.copyWith(
pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,str: null == str ? _self.str : str // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as AtsTextMatrix,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,fontName: null == fontName ? _self.fontName : fontName // ignore: cast_nullable_to_non_nullable
as String,hasEol: null == hasEol ? _self.hasEol : hasEol // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AtsTextNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AtsTextMatrixCopyWith<$Res> get transform {
  
  return $AtsTextMatrixCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}
}


/// Adds pattern-matching-related methods to [AtsTextNode].
extension AtsTextNodePatterns on AtsTextNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsTextNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsTextNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsTextNode value)  $default,){
final _that = this;
switch (_that) {
case _AtsTextNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsTextNode value)?  $default,){
final _that = this;
switch (_that) {
case _AtsTextNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pageIndex,  String str,  AtsTextMatrix transform,  double width,  double height,  String fontName,  bool hasEol)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsTextNode() when $default != null:
return $default(_that.pageIndex,_that.str,_that.transform,_that.width,_that.height,_that.fontName,_that.hasEol);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pageIndex,  String str,  AtsTextMatrix transform,  double width,  double height,  String fontName,  bool hasEol)  $default,) {final _that = this;
switch (_that) {
case _AtsTextNode():
return $default(_that.pageIndex,_that.str,_that.transform,_that.width,_that.height,_that.fontName,_that.hasEol);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pageIndex,  String str,  AtsTextMatrix transform,  double width,  double height,  String fontName,  bool hasEol)?  $default,) {final _that = this;
switch (_that) {
case _AtsTextNode() when $default != null:
return $default(_that.pageIndex,_that.str,_that.transform,_that.width,_that.height,_that.fontName,_that.hasEol);case _:
  return null;

}
}

}

/// @nodoc


class _AtsTextNode implements AtsTextNode {
  const _AtsTextNode({required this.pageIndex, required this.str, required this.transform, required this.width, required this.height, required this.fontName, this.hasEol = false});
  

@override final  int pageIndex;
@override final  String str;
@override final  AtsTextMatrix transform;
/// The advance width along the text direction — an *advance* box, not
/// an *ink* box. Confirmed in the spike: a dropped/unmapped glyph
/// (e.g. a PUA bullet drawn with a non-embedded font) can leave a
/// nonzero [width] with no corresponding characters in [str] — see
/// `AtsAnalyzerService`'s phantom-glyph check, which exists because of
/// exactly that finding.
@override final  double width;
/// The rotation-invariant effective em size — `hypot(transform.c,
/// transform.d)` on every real content run in the spike's corpus.
/// `0` on synthetic empty/EOL marker runs (`str.isEmpty`); always
/// filter those out before using this for a font-size-based check.
@override final  double height;
/// `pdf.js`'s internal font id (e.g. `g_d0_f1`) — a key into
/// `AtsExtractedDocument.fonts`, not a user-facing name.
@override final  String fontName;
@override@JsonKey() final  bool hasEol;

/// Create a copy of AtsTextNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsTextNodeCopyWith<_AtsTextNode> get copyWith => __$AtsTextNodeCopyWithImpl<_AtsTextNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsTextNode&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.str, str) || other.str == str)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.fontName, fontName) || other.fontName == fontName)&&(identical(other.hasEol, hasEol) || other.hasEol == hasEol));
}


@override
int get hashCode => Object.hash(runtimeType,pageIndex,str,transform,width,height,fontName,hasEol);

@override
String toString() {
  return 'AtsTextNode(pageIndex: $pageIndex, str: $str, transform: $transform, width: $width, height: $height, fontName: $fontName, hasEol: $hasEol)';
}


}

/// @nodoc
abstract mixin class _$AtsTextNodeCopyWith<$Res> implements $AtsTextNodeCopyWith<$Res> {
  factory _$AtsTextNodeCopyWith(_AtsTextNode value, $Res Function(_AtsTextNode) _then) = __$AtsTextNodeCopyWithImpl;
@override @useResult
$Res call({
 int pageIndex, String str, AtsTextMatrix transform, double width, double height, String fontName, bool hasEol
});


@override $AtsTextMatrixCopyWith<$Res> get transform;

}
/// @nodoc
class __$AtsTextNodeCopyWithImpl<$Res>
    implements _$AtsTextNodeCopyWith<$Res> {
  __$AtsTextNodeCopyWithImpl(this._self, this._then);

  final _AtsTextNode _self;
  final $Res Function(_AtsTextNode) _then;

/// Create a copy of AtsTextNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageIndex = null,Object? str = null,Object? transform = null,Object? width = null,Object? height = null,Object? fontName = null,Object? hasEol = null,}) {
  return _then(_AtsTextNode(
pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,str: null == str ? _self.str : str // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as AtsTextMatrix,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,fontName: null == fontName ? _self.fontName : fontName // ignore: cast_nullable_to_non_nullable
as String,hasEol: null == hasEol ? _self.hasEol : hasEol // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AtsTextNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AtsTextMatrixCopyWith<$Res> get transform {
  
  return $AtsTextMatrixCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}
}

/// @nodoc
mixin _$AtsTextMatrix {

 double get a; double get b; double get c; double get d; double get e; double get f;
/// Create a copy of AtsTextMatrix
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsTextMatrixCopyWith<AtsTextMatrix> get copyWith => _$AtsTextMatrixCopyWithImpl<AtsTextMatrix>(this as AtsTextMatrix, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsTextMatrix&&(identical(other.a, a) || other.a == a)&&(identical(other.b, b) || other.b == b)&&(identical(other.c, c) || other.c == c)&&(identical(other.d, d) || other.d == d)&&(identical(other.e, e) || other.e == e)&&(identical(other.f, f) || other.f == f));
}


@override
int get hashCode => Object.hash(runtimeType,a,b,c,d,e,f);

@override
String toString() {
  return 'AtsTextMatrix(a: $a, b: $b, c: $c, d: $d, e: $e, f: $f)';
}


}

/// @nodoc
abstract mixin class $AtsTextMatrixCopyWith<$Res>  {
  factory $AtsTextMatrixCopyWith(AtsTextMatrix value, $Res Function(AtsTextMatrix) _then) = _$AtsTextMatrixCopyWithImpl;
@useResult
$Res call({
 double a, double b, double c, double d, double e, double f
});




}
/// @nodoc
class _$AtsTextMatrixCopyWithImpl<$Res>
    implements $AtsTextMatrixCopyWith<$Res> {
  _$AtsTextMatrixCopyWithImpl(this._self, this._then);

  final AtsTextMatrix _self;
  final $Res Function(AtsTextMatrix) _then;

/// Create a copy of AtsTextMatrix
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = null,Object? b = null,Object? c = null,Object? d = null,Object? e = null,Object? f = null,}) {
  return _then(_self.copyWith(
a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as double,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as double,c: null == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as double,d: null == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as double,e: null == e ? _self.e : e // ignore: cast_nullable_to_non_nullable
as double,f: null == f ? _self.f : f // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AtsTextMatrix].
extension AtsTextMatrixPatterns on AtsTextMatrix {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsTextMatrix value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsTextMatrix() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsTextMatrix value)  $default,){
final _that = this;
switch (_that) {
case _AtsTextMatrix():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsTextMatrix value)?  $default,){
final _that = this;
switch (_that) {
case _AtsTextMatrix() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double a,  double b,  double c,  double d,  double e,  double f)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsTextMatrix() when $default != null:
return $default(_that.a,_that.b,_that.c,_that.d,_that.e,_that.f);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double a,  double b,  double c,  double d,  double e,  double f)  $default,) {final _that = this;
switch (_that) {
case _AtsTextMatrix():
return $default(_that.a,_that.b,_that.c,_that.d,_that.e,_that.f);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double a,  double b,  double c,  double d,  double e,  double f)?  $default,) {final _that = this;
switch (_that) {
case _AtsTextMatrix() when $default != null:
return $default(_that.a,_that.b,_that.c,_that.d,_that.e,_that.f);case _:
  return null;

}
}

}

/// @nodoc


class _AtsTextMatrix extends AtsTextMatrix {
  const _AtsTextMatrix({required this.a, required this.b, required this.c, required this.d, required this.e, required this.f}): super._();
  

@override final  double a;
@override final  double b;
@override final  double c;
@override final  double d;
@override final  double e;
@override final  double f;

/// Create a copy of AtsTextMatrix
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsTextMatrixCopyWith<_AtsTextMatrix> get copyWith => __$AtsTextMatrixCopyWithImpl<_AtsTextMatrix>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsTextMatrix&&(identical(other.a, a) || other.a == a)&&(identical(other.b, b) || other.b == b)&&(identical(other.c, c) || other.c == c)&&(identical(other.d, d) || other.d == d)&&(identical(other.e, e) || other.e == e)&&(identical(other.f, f) || other.f == f));
}


@override
int get hashCode => Object.hash(runtimeType,a,b,c,d,e,f);

@override
String toString() {
  return 'AtsTextMatrix(a: $a, b: $b, c: $c, d: $d, e: $e, f: $f)';
}


}

/// @nodoc
abstract mixin class _$AtsTextMatrixCopyWith<$Res> implements $AtsTextMatrixCopyWith<$Res> {
  factory _$AtsTextMatrixCopyWith(_AtsTextMatrix value, $Res Function(_AtsTextMatrix) _then) = __$AtsTextMatrixCopyWithImpl;
@override @useResult
$Res call({
 double a, double b, double c, double d, double e, double f
});




}
/// @nodoc
class __$AtsTextMatrixCopyWithImpl<$Res>
    implements _$AtsTextMatrixCopyWith<$Res> {
  __$AtsTextMatrixCopyWithImpl(this._self, this._then);

  final _AtsTextMatrix _self;
  final $Res Function(_AtsTextMatrix) _then;

/// Create a copy of AtsTextMatrix
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = null,Object? b = null,Object? c = null,Object? d = null,Object? e = null,Object? f = null,}) {
  return _then(_AtsTextMatrix(
a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as double,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as double,c: null == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as double,d: null == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as double,e: null == e ? _self.e : e // ignore: cast_nullable_to_non_nullable
as double,f: null == f ? _self.f : f // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
