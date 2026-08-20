// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ats_font_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AtsFontInfo {

/// The real PDF base font name, e.g. `Helvetica-Bold` or a subset
/// font's `ABCDEF+Calibri`. The `ABCDEF+` subset prefix is the
/// strongest available correlate of a missing/wrong ToUnicode map —
/// see `AtsAnalyzerService`'s garbled-text heuristic.
 String get name; bool get bold; bool get italic;/// `true` when the font isn't embedded and `pdf.js` substituted a
/// fallback to render it — confirmed via the spike's synthetic
/// Helvetica corpus (non-embedded, `missingFile: true`) vs cv-forge's
/// own embedded Roboto (`missingFile: false`).
 bool get missingFile; bool get isType3Font; bool get isInvalidPDFjsFont;/// Fraction of em, PDF font-metric convention (ascent positive,
/// descent negative). `null` when `pdf.js` doesn't report it for this
/// font — the X-Ray overlay's ink-box derivation falls back to
/// typical defaults in that case rather than requiring these
/// (`AtsMatrixMath.atsInkBoxRect`, see `docs/
/// ats-xray-overlay-handover.md` §5.4).
 double? get ascent; double? get descent;
/// Create a copy of AtsFontInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsFontInfoCopyWith<AtsFontInfo> get copyWith => _$AtsFontInfoCopyWithImpl<AtsFontInfo>(this as AtsFontInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsFontInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.bold, bold) || other.bold == bold)&&(identical(other.italic, italic) || other.italic == italic)&&(identical(other.missingFile, missingFile) || other.missingFile == missingFile)&&(identical(other.isType3Font, isType3Font) || other.isType3Font == isType3Font)&&(identical(other.isInvalidPDFjsFont, isInvalidPDFjsFont) || other.isInvalidPDFjsFont == isInvalidPDFjsFont)&&(identical(other.ascent, ascent) || other.ascent == ascent)&&(identical(other.descent, descent) || other.descent == descent));
}


@override
int get hashCode => Object.hash(runtimeType,name,bold,italic,missingFile,isType3Font,isInvalidPDFjsFont,ascent,descent);

@override
String toString() {
  return 'AtsFontInfo(name: $name, bold: $bold, italic: $italic, missingFile: $missingFile, isType3Font: $isType3Font, isInvalidPDFjsFont: $isInvalidPDFjsFont, ascent: $ascent, descent: $descent)';
}


}

/// @nodoc
abstract mixin class $AtsFontInfoCopyWith<$Res>  {
  factory $AtsFontInfoCopyWith(AtsFontInfo value, $Res Function(AtsFontInfo) _then) = _$AtsFontInfoCopyWithImpl;
@useResult
$Res call({
 String name, bool bold, bool italic, bool missingFile, bool isType3Font, bool isInvalidPDFjsFont, double? ascent, double? descent
});




}
/// @nodoc
class _$AtsFontInfoCopyWithImpl<$Res>
    implements $AtsFontInfoCopyWith<$Res> {
  _$AtsFontInfoCopyWithImpl(this._self, this._then);

  final AtsFontInfo _self;
  final $Res Function(AtsFontInfo) _then;

/// Create a copy of AtsFontInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? bold = null,Object? italic = null,Object? missingFile = null,Object? isType3Font = null,Object? isInvalidPDFjsFont = null,Object? ascent = freezed,Object? descent = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,missingFile: null == missingFile ? _self.missingFile : missingFile // ignore: cast_nullable_to_non_nullable
as bool,isType3Font: null == isType3Font ? _self.isType3Font : isType3Font // ignore: cast_nullable_to_non_nullable
as bool,isInvalidPDFjsFont: null == isInvalidPDFjsFont ? _self.isInvalidPDFjsFont : isInvalidPDFjsFont // ignore: cast_nullable_to_non_nullable
as bool,ascent: freezed == ascent ? _self.ascent : ascent // ignore: cast_nullable_to_non_nullable
as double?,descent: freezed == descent ? _self.descent : descent // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AtsFontInfo].
extension AtsFontInfoPatterns on AtsFontInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsFontInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsFontInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsFontInfo value)  $default,){
final _that = this;
switch (_that) {
case _AtsFontInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsFontInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AtsFontInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool bold,  bool italic,  bool missingFile,  bool isType3Font,  bool isInvalidPDFjsFont,  double? ascent,  double? descent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsFontInfo() when $default != null:
return $default(_that.name,_that.bold,_that.italic,_that.missingFile,_that.isType3Font,_that.isInvalidPDFjsFont,_that.ascent,_that.descent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool bold,  bool italic,  bool missingFile,  bool isType3Font,  bool isInvalidPDFjsFont,  double? ascent,  double? descent)  $default,) {final _that = this;
switch (_that) {
case _AtsFontInfo():
return $default(_that.name,_that.bold,_that.italic,_that.missingFile,_that.isType3Font,_that.isInvalidPDFjsFont,_that.ascent,_that.descent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool bold,  bool italic,  bool missingFile,  bool isType3Font,  bool isInvalidPDFjsFont,  double? ascent,  double? descent)?  $default,) {final _that = this;
switch (_that) {
case _AtsFontInfo() when $default != null:
return $default(_that.name,_that.bold,_that.italic,_that.missingFile,_that.isType3Font,_that.isInvalidPDFjsFont,_that.ascent,_that.descent);case _:
  return null;

}
}

}

/// @nodoc


class _AtsFontInfo implements AtsFontInfo {
  const _AtsFontInfo({required this.name, required this.bold, required this.italic, required this.missingFile, required this.isType3Font, required this.isInvalidPDFjsFont, this.ascent, this.descent});
  

/// The real PDF base font name, e.g. `Helvetica-Bold` or a subset
/// font's `ABCDEF+Calibri`. The `ABCDEF+` subset prefix is the
/// strongest available correlate of a missing/wrong ToUnicode map —
/// see `AtsAnalyzerService`'s garbled-text heuristic.
@override final  String name;
@override final  bool bold;
@override final  bool italic;
/// `true` when the font isn't embedded and `pdf.js` substituted a
/// fallback to render it — confirmed via the spike's synthetic
/// Helvetica corpus (non-embedded, `missingFile: true`) vs cv-forge's
/// own embedded Roboto (`missingFile: false`).
@override final  bool missingFile;
@override final  bool isType3Font;
@override final  bool isInvalidPDFjsFont;
/// Fraction of em, PDF font-metric convention (ascent positive,
/// descent negative). `null` when `pdf.js` doesn't report it for this
/// font — the X-Ray overlay's ink-box derivation falls back to
/// typical defaults in that case rather than requiring these
/// (`AtsMatrixMath.atsInkBoxRect`, see `docs/
/// ats-xray-overlay-handover.md` §5.4).
@override final  double? ascent;
@override final  double? descent;

/// Create a copy of AtsFontInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsFontInfoCopyWith<_AtsFontInfo> get copyWith => __$AtsFontInfoCopyWithImpl<_AtsFontInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsFontInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.bold, bold) || other.bold == bold)&&(identical(other.italic, italic) || other.italic == italic)&&(identical(other.missingFile, missingFile) || other.missingFile == missingFile)&&(identical(other.isType3Font, isType3Font) || other.isType3Font == isType3Font)&&(identical(other.isInvalidPDFjsFont, isInvalidPDFjsFont) || other.isInvalidPDFjsFont == isInvalidPDFjsFont)&&(identical(other.ascent, ascent) || other.ascent == ascent)&&(identical(other.descent, descent) || other.descent == descent));
}


@override
int get hashCode => Object.hash(runtimeType,name,bold,italic,missingFile,isType3Font,isInvalidPDFjsFont,ascent,descent);

@override
String toString() {
  return 'AtsFontInfo(name: $name, bold: $bold, italic: $italic, missingFile: $missingFile, isType3Font: $isType3Font, isInvalidPDFjsFont: $isInvalidPDFjsFont, ascent: $ascent, descent: $descent)';
}


}

/// @nodoc
abstract mixin class _$AtsFontInfoCopyWith<$Res> implements $AtsFontInfoCopyWith<$Res> {
  factory _$AtsFontInfoCopyWith(_AtsFontInfo value, $Res Function(_AtsFontInfo) _then) = __$AtsFontInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, bool bold, bool italic, bool missingFile, bool isType3Font, bool isInvalidPDFjsFont, double? ascent, double? descent
});




}
/// @nodoc
class __$AtsFontInfoCopyWithImpl<$Res>
    implements _$AtsFontInfoCopyWith<$Res> {
  __$AtsFontInfoCopyWithImpl(this._self, this._then);

  final _AtsFontInfo _self;
  final $Res Function(_AtsFontInfo) _then;

/// Create a copy of AtsFontInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? bold = null,Object? italic = null,Object? missingFile = null,Object? isType3Font = null,Object? isInvalidPDFjsFont = null,Object? ascent = freezed,Object? descent = freezed,}) {
  return _then(_AtsFontInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,missingFile: null == missingFile ? _self.missingFile : missingFile // ignore: cast_nullable_to_non_nullable
as bool,isType3Font: null == isType3Font ? _self.isType3Font : isType3Font // ignore: cast_nullable_to_non_nullable
as bool,isInvalidPDFjsFont: null == isInvalidPDFjsFont ? _self.isInvalidPDFjsFont : isInvalidPDFjsFont // ignore: cast_nullable_to_non_nullable
as bool,ascent: freezed == ascent ? _self.ascent : ascent // ignore: cast_nullable_to_non_nullable
as double?,descent: freezed == descent ? _self.descent : descent // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
