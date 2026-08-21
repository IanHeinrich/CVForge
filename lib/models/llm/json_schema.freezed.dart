// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'json_schema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JsonSchema {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JsonSchema);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JsonSchema()';
}


}

/// @nodoc
class $JsonSchemaCopyWith<$Res>  {
$JsonSchemaCopyWith(JsonSchema _, $Res Function(JsonSchema) __);
}


/// Adds pattern-matching-related methods to [JsonSchema].
extension JsonSchemaPatterns on JsonSchema {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( JsonSchemaObject value)?  object,TResult Function( JsonSchemaArray value)?  array,TResult Function( JsonSchemaString value)?  string,TResult Function( JsonSchemaStringEnum value)?  stringEnum,TResult Function( JsonSchemaNumber value)?  number,TResult Function( JsonSchemaBoolean value)?  boolean,required TResult orElse(),}){
final _that = this;
switch (_that) {
case JsonSchemaObject() when object != null:
return object(_that);case JsonSchemaArray() when array != null:
return array(_that);case JsonSchemaString() when string != null:
return string(_that);case JsonSchemaStringEnum() when stringEnum != null:
return stringEnum(_that);case JsonSchemaNumber() when number != null:
return number(_that);case JsonSchemaBoolean() when boolean != null:
return boolean(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( JsonSchemaObject value)  object,required TResult Function( JsonSchemaArray value)  array,required TResult Function( JsonSchemaString value)  string,required TResult Function( JsonSchemaStringEnum value)  stringEnum,required TResult Function( JsonSchemaNumber value)  number,required TResult Function( JsonSchemaBoolean value)  boolean,}){
final _that = this;
switch (_that) {
case JsonSchemaObject():
return object(_that);case JsonSchemaArray():
return array(_that);case JsonSchemaString():
return string(_that);case JsonSchemaStringEnum():
return stringEnum(_that);case JsonSchemaNumber():
return number(_that);case JsonSchemaBoolean():
return boolean(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( JsonSchemaObject value)?  object,TResult? Function( JsonSchemaArray value)?  array,TResult? Function( JsonSchemaString value)?  string,TResult? Function( JsonSchemaStringEnum value)?  stringEnum,TResult? Function( JsonSchemaNumber value)?  number,TResult? Function( JsonSchemaBoolean value)?  boolean,}){
final _that = this;
switch (_that) {
case JsonSchemaObject() when object != null:
return object(_that);case JsonSchemaArray() when array != null:
return array(_that);case JsonSchemaString() when string != null:
return string(_that);case JsonSchemaStringEnum() when stringEnum != null:
return stringEnum(_that);case JsonSchemaNumber() when number != null:
return number(_that);case JsonSchemaBoolean() when boolean != null:
return boolean(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Map<String, JsonSchema> properties,  List<String> required)?  object,TResult Function( JsonSchema items)?  array,TResult Function()?  string,TResult Function( List<String> values)?  stringEnum,TResult Function()?  number,TResult Function()?  boolean,required TResult orElse(),}) {final _that = this;
switch (_that) {
case JsonSchemaObject() when object != null:
return object(_that.properties,_that.required);case JsonSchemaArray() when array != null:
return array(_that.items);case JsonSchemaString() when string != null:
return string();case JsonSchemaStringEnum() when stringEnum != null:
return stringEnum(_that.values);case JsonSchemaNumber() when number != null:
return number();case JsonSchemaBoolean() when boolean != null:
return boolean();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Map<String, JsonSchema> properties,  List<String> required)  object,required TResult Function( JsonSchema items)  array,required TResult Function()  string,required TResult Function( List<String> values)  stringEnum,required TResult Function()  number,required TResult Function()  boolean,}) {final _that = this;
switch (_that) {
case JsonSchemaObject():
return object(_that.properties,_that.required);case JsonSchemaArray():
return array(_that.items);case JsonSchemaString():
return string();case JsonSchemaStringEnum():
return stringEnum(_that.values);case JsonSchemaNumber():
return number();case JsonSchemaBoolean():
return boolean();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Map<String, JsonSchema> properties,  List<String> required)?  object,TResult? Function( JsonSchema items)?  array,TResult? Function()?  string,TResult? Function( List<String> values)?  stringEnum,TResult? Function()?  number,TResult? Function()?  boolean,}) {final _that = this;
switch (_that) {
case JsonSchemaObject() when object != null:
return object(_that.properties,_that.required);case JsonSchemaArray() when array != null:
return array(_that.items);case JsonSchemaString() when string != null:
return string();case JsonSchemaStringEnum() when stringEnum != null:
return stringEnum(_that.values);case JsonSchemaNumber() when number != null:
return number();case JsonSchemaBoolean() when boolean != null:
return boolean();case _:
  return null;

}
}

}

/// @nodoc


class JsonSchemaObject implements JsonSchema {
  const JsonSchemaObject({required final  Map<String, JsonSchema> properties, required final  List<String> required}): _properties = properties,_required = required;
  

 final  Map<String, JsonSchema> _properties;
 Map<String, JsonSchema> get properties {
  if (_properties is EqualUnmodifiableMapView) return _properties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_properties);
}

 final  List<String> _required;
 List<String> get required {
  if (_required is EqualUnmodifiableListView) return _required;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_required);
}


/// Create a copy of JsonSchema
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JsonSchemaObjectCopyWith<JsonSchemaObject> get copyWith => _$JsonSchemaObjectCopyWithImpl<JsonSchemaObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JsonSchemaObject&&const DeepCollectionEquality().equals(other._properties, _properties)&&const DeepCollectionEquality().equals(other._required, _required));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_properties),const DeepCollectionEquality().hash(_required));

@override
String toString() {
  return 'JsonSchema.object(properties: $properties, required: $required)';
}


}

/// @nodoc
abstract mixin class $JsonSchemaObjectCopyWith<$Res> implements $JsonSchemaCopyWith<$Res> {
  factory $JsonSchemaObjectCopyWith(JsonSchemaObject value, $Res Function(JsonSchemaObject) _then) = _$JsonSchemaObjectCopyWithImpl;
@useResult
$Res call({
 Map<String, JsonSchema> properties, List<String> required
});




}
/// @nodoc
class _$JsonSchemaObjectCopyWithImpl<$Res>
    implements $JsonSchemaObjectCopyWith<$Res> {
  _$JsonSchemaObjectCopyWithImpl(this._self, this._then);

  final JsonSchemaObject _self;
  final $Res Function(JsonSchemaObject) _then;

/// Create a copy of JsonSchema
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? properties = null,Object? required = null,}) {
  return _then(JsonSchemaObject(
properties: null == properties ? _self._properties : properties // ignore: cast_nullable_to_non_nullable
as Map<String, JsonSchema>,required: null == required ? _self._required : required // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class JsonSchemaArray implements JsonSchema {
  const JsonSchemaArray({required this.items});
  

 final  JsonSchema items;

/// Create a copy of JsonSchema
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JsonSchemaArrayCopyWith<JsonSchemaArray> get copyWith => _$JsonSchemaArrayCopyWithImpl<JsonSchemaArray>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JsonSchemaArray&&(identical(other.items, items) || other.items == items));
}


@override
int get hashCode => Object.hash(runtimeType,items);

@override
String toString() {
  return 'JsonSchema.array(items: $items)';
}


}

/// @nodoc
abstract mixin class $JsonSchemaArrayCopyWith<$Res> implements $JsonSchemaCopyWith<$Res> {
  factory $JsonSchemaArrayCopyWith(JsonSchemaArray value, $Res Function(JsonSchemaArray) _then) = _$JsonSchemaArrayCopyWithImpl;
@useResult
$Res call({
 JsonSchema items
});


$JsonSchemaCopyWith<$Res> get items;

}
/// @nodoc
class _$JsonSchemaArrayCopyWithImpl<$Res>
    implements $JsonSchemaArrayCopyWith<$Res> {
  _$JsonSchemaArrayCopyWithImpl(this._self, this._then);

  final JsonSchemaArray _self;
  final $Res Function(JsonSchemaArray) _then;

/// Create a copy of JsonSchema
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(JsonSchemaArray(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as JsonSchema,
  ));
}

/// Create a copy of JsonSchema
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JsonSchemaCopyWith<$Res> get items {
  
  return $JsonSchemaCopyWith<$Res>(_self.items, (value) {
    return _then(_self.copyWith(items: value));
  });
}
}

/// @nodoc


class JsonSchemaString implements JsonSchema {
  const JsonSchemaString();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JsonSchemaString);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JsonSchema.string()';
}


}




/// @nodoc


class JsonSchemaStringEnum implements JsonSchema {
  const JsonSchemaStringEnum(final  List<String> values): _values = values;
  

 final  List<String> _values;
 List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of JsonSchema
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JsonSchemaStringEnumCopyWith<JsonSchemaStringEnum> get copyWith => _$JsonSchemaStringEnumCopyWithImpl<JsonSchemaStringEnum>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JsonSchemaStringEnum&&const DeepCollectionEquality().equals(other._values, _values));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'JsonSchema.stringEnum(values: $values)';
}


}

/// @nodoc
abstract mixin class $JsonSchemaStringEnumCopyWith<$Res> implements $JsonSchemaCopyWith<$Res> {
  factory $JsonSchemaStringEnumCopyWith(JsonSchemaStringEnum value, $Res Function(JsonSchemaStringEnum) _then) = _$JsonSchemaStringEnumCopyWithImpl;
@useResult
$Res call({
 List<String> values
});




}
/// @nodoc
class _$JsonSchemaStringEnumCopyWithImpl<$Res>
    implements $JsonSchemaStringEnumCopyWith<$Res> {
  _$JsonSchemaStringEnumCopyWithImpl(this._self, this._then);

  final JsonSchemaStringEnum _self;
  final $Res Function(JsonSchemaStringEnum) _then;

/// Create a copy of JsonSchema
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? values = null,}) {
  return _then(JsonSchemaStringEnum(
null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class JsonSchemaNumber implements JsonSchema {
  const JsonSchemaNumber();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JsonSchemaNumber);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JsonSchema.number()';
}


}




/// @nodoc


class JsonSchemaBoolean implements JsonSchema {
  const JsonSchemaBoolean();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JsonSchemaBoolean);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JsonSchema.boolean()';
}


}




// dart format on
