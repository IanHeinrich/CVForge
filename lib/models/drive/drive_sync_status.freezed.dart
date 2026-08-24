// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DriveSyncStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DriveSyncStatus()';
}


}

/// @nodoc
class $DriveSyncStatusCopyWith<$Res>  {
$DriveSyncStatusCopyWith(DriveSyncStatus _, $Res Function(DriveSyncStatus) __);
}


/// Adds pattern-matching-related methods to [DriveSyncStatus].
extension DriveSyncStatusPatterns on DriveSyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DriveSyncDisconnected value)?  disconnected,TResult Function( DriveSyncConnecting value)?  connecting,TResult Function( DriveSyncIdle value)?  idle,TResult Function( DriveSyncPending value)?  pending,TResult Function( DriveSyncSyncing value)?  syncing,TResult Function( DriveSyncMerged value)?  merged,TResult Function( DriveSyncNeedsReauth value)?  needsReauth,TResult Function( DriveSyncErrorState value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DriveSyncDisconnected() when disconnected != null:
return disconnected(_that);case DriveSyncConnecting() when connecting != null:
return connecting(_that);case DriveSyncIdle() when idle != null:
return idle(_that);case DriveSyncPending() when pending != null:
return pending(_that);case DriveSyncSyncing() when syncing != null:
return syncing(_that);case DriveSyncMerged() when merged != null:
return merged(_that);case DriveSyncNeedsReauth() when needsReauth != null:
return needsReauth(_that);case DriveSyncErrorState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DriveSyncDisconnected value)  disconnected,required TResult Function( DriveSyncConnecting value)  connecting,required TResult Function( DriveSyncIdle value)  idle,required TResult Function( DriveSyncPending value)  pending,required TResult Function( DriveSyncSyncing value)  syncing,required TResult Function( DriveSyncMerged value)  merged,required TResult Function( DriveSyncNeedsReauth value)  needsReauth,required TResult Function( DriveSyncErrorState value)  error,}){
final _that = this;
switch (_that) {
case DriveSyncDisconnected():
return disconnected(_that);case DriveSyncConnecting():
return connecting(_that);case DriveSyncIdle():
return idle(_that);case DriveSyncPending():
return pending(_that);case DriveSyncSyncing():
return syncing(_that);case DriveSyncMerged():
return merged(_that);case DriveSyncNeedsReauth():
return needsReauth(_that);case DriveSyncErrorState():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DriveSyncDisconnected value)?  disconnected,TResult? Function( DriveSyncConnecting value)?  connecting,TResult? Function( DriveSyncIdle value)?  idle,TResult? Function( DriveSyncPending value)?  pending,TResult? Function( DriveSyncSyncing value)?  syncing,TResult? Function( DriveSyncMerged value)?  merged,TResult? Function( DriveSyncNeedsReauth value)?  needsReauth,TResult? Function( DriveSyncErrorState value)?  error,}){
final _that = this;
switch (_that) {
case DriveSyncDisconnected() when disconnected != null:
return disconnected(_that);case DriveSyncConnecting() when connecting != null:
return connecting(_that);case DriveSyncIdle() when idle != null:
return idle(_that);case DriveSyncPending() when pending != null:
return pending(_that);case DriveSyncSyncing() when syncing != null:
return syncing(_that);case DriveSyncMerged() when merged != null:
return merged(_that);case DriveSyncNeedsReauth() when needsReauth != null:
return needsReauth(_that);case DriveSyncErrorState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  disconnected,TResult Function()?  connecting,TResult Function( String accountEmail,  DateTime? lastSyncedAt)?  idle,TResult Function( String accountEmail)?  pending,TResult Function( String accountEmail)?  syncing,TResult Function( String accountEmail,  DateTime? lastSyncedAt)?  merged,TResult Function( String accountEmail)?  needsReauth,TResult Function( String accountEmail,  String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DriveSyncDisconnected() when disconnected != null:
return disconnected();case DriveSyncConnecting() when connecting != null:
return connecting();case DriveSyncIdle() when idle != null:
return idle(_that.accountEmail,_that.lastSyncedAt);case DriveSyncPending() when pending != null:
return pending(_that.accountEmail);case DriveSyncSyncing() when syncing != null:
return syncing(_that.accountEmail);case DriveSyncMerged() when merged != null:
return merged(_that.accountEmail,_that.lastSyncedAt);case DriveSyncNeedsReauth() when needsReauth != null:
return needsReauth(_that.accountEmail);case DriveSyncErrorState() when error != null:
return error(_that.accountEmail,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  disconnected,required TResult Function()  connecting,required TResult Function( String accountEmail,  DateTime? lastSyncedAt)  idle,required TResult Function( String accountEmail)  pending,required TResult Function( String accountEmail)  syncing,required TResult Function( String accountEmail,  DateTime? lastSyncedAt)  merged,required TResult Function( String accountEmail)  needsReauth,required TResult Function( String accountEmail,  String message)  error,}) {final _that = this;
switch (_that) {
case DriveSyncDisconnected():
return disconnected();case DriveSyncConnecting():
return connecting();case DriveSyncIdle():
return idle(_that.accountEmail,_that.lastSyncedAt);case DriveSyncPending():
return pending(_that.accountEmail);case DriveSyncSyncing():
return syncing(_that.accountEmail);case DriveSyncMerged():
return merged(_that.accountEmail,_that.lastSyncedAt);case DriveSyncNeedsReauth():
return needsReauth(_that.accountEmail);case DriveSyncErrorState():
return error(_that.accountEmail,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  disconnected,TResult? Function()?  connecting,TResult? Function( String accountEmail,  DateTime? lastSyncedAt)?  idle,TResult? Function( String accountEmail)?  pending,TResult? Function( String accountEmail)?  syncing,TResult? Function( String accountEmail,  DateTime? lastSyncedAt)?  merged,TResult? Function( String accountEmail)?  needsReauth,TResult? Function( String accountEmail,  String message)?  error,}) {final _that = this;
switch (_that) {
case DriveSyncDisconnected() when disconnected != null:
return disconnected();case DriveSyncConnecting() when connecting != null:
return connecting();case DriveSyncIdle() when idle != null:
return idle(_that.accountEmail,_that.lastSyncedAt);case DriveSyncPending() when pending != null:
return pending(_that.accountEmail);case DriveSyncSyncing() when syncing != null:
return syncing(_that.accountEmail);case DriveSyncMerged() when merged != null:
return merged(_that.accountEmail,_that.lastSyncedAt);case DriveSyncNeedsReauth() when needsReauth != null:
return needsReauth(_that.accountEmail);case DriveSyncErrorState() when error != null:
return error(_that.accountEmail,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DriveSyncDisconnected implements DriveSyncStatus {
  const DriveSyncDisconnected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncDisconnected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DriveSyncStatus.disconnected()';
}


}




/// @nodoc


class DriveSyncConnecting implements DriveSyncStatus {
  const DriveSyncConnecting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncConnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DriveSyncStatus.connecting()';
}


}




/// @nodoc


class DriveSyncIdle implements DriveSyncStatus {
  const DriveSyncIdle({required this.accountEmail, this.lastSyncedAt});
  

 final  String accountEmail;
 final  DateTime? lastSyncedAt;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveSyncIdleCopyWith<DriveSyncIdle> get copyWith => _$DriveSyncIdleCopyWithImpl<DriveSyncIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncIdle&&(identical(other.accountEmail, accountEmail) || other.accountEmail == accountEmail)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,accountEmail,lastSyncedAt);

@override
String toString() {
  return 'DriveSyncStatus.idle(accountEmail: $accountEmail, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $DriveSyncIdleCopyWith<$Res> implements $DriveSyncStatusCopyWith<$Res> {
  factory $DriveSyncIdleCopyWith(DriveSyncIdle value, $Res Function(DriveSyncIdle) _then) = _$DriveSyncIdleCopyWithImpl;
@useResult
$Res call({
 String accountEmail, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$DriveSyncIdleCopyWithImpl<$Res>
    implements $DriveSyncIdleCopyWith<$Res> {
  _$DriveSyncIdleCopyWithImpl(this._self, this._then);

  final DriveSyncIdle _self;
  final $Res Function(DriveSyncIdle) _then;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accountEmail = null,Object? lastSyncedAt = freezed,}) {
  return _then(DriveSyncIdle(
accountEmail: null == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class DriveSyncPending implements DriveSyncStatus {
  const DriveSyncPending({required this.accountEmail});
  

 final  String accountEmail;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveSyncPendingCopyWith<DriveSyncPending> get copyWith => _$DriveSyncPendingCopyWithImpl<DriveSyncPending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncPending&&(identical(other.accountEmail, accountEmail) || other.accountEmail == accountEmail));
}


@override
int get hashCode => Object.hash(runtimeType,accountEmail);

@override
String toString() {
  return 'DriveSyncStatus.pending(accountEmail: $accountEmail)';
}


}

/// @nodoc
abstract mixin class $DriveSyncPendingCopyWith<$Res> implements $DriveSyncStatusCopyWith<$Res> {
  factory $DriveSyncPendingCopyWith(DriveSyncPending value, $Res Function(DriveSyncPending) _then) = _$DriveSyncPendingCopyWithImpl;
@useResult
$Res call({
 String accountEmail
});




}
/// @nodoc
class _$DriveSyncPendingCopyWithImpl<$Res>
    implements $DriveSyncPendingCopyWith<$Res> {
  _$DriveSyncPendingCopyWithImpl(this._self, this._then);

  final DriveSyncPending _self;
  final $Res Function(DriveSyncPending) _then;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accountEmail = null,}) {
  return _then(DriveSyncPending(
accountEmail: null == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DriveSyncSyncing implements DriveSyncStatus {
  const DriveSyncSyncing({required this.accountEmail});
  

 final  String accountEmail;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveSyncSyncingCopyWith<DriveSyncSyncing> get copyWith => _$DriveSyncSyncingCopyWithImpl<DriveSyncSyncing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncSyncing&&(identical(other.accountEmail, accountEmail) || other.accountEmail == accountEmail));
}


@override
int get hashCode => Object.hash(runtimeType,accountEmail);

@override
String toString() {
  return 'DriveSyncStatus.syncing(accountEmail: $accountEmail)';
}


}

/// @nodoc
abstract mixin class $DriveSyncSyncingCopyWith<$Res> implements $DriveSyncStatusCopyWith<$Res> {
  factory $DriveSyncSyncingCopyWith(DriveSyncSyncing value, $Res Function(DriveSyncSyncing) _then) = _$DriveSyncSyncingCopyWithImpl;
@useResult
$Res call({
 String accountEmail
});




}
/// @nodoc
class _$DriveSyncSyncingCopyWithImpl<$Res>
    implements $DriveSyncSyncingCopyWith<$Res> {
  _$DriveSyncSyncingCopyWithImpl(this._self, this._then);

  final DriveSyncSyncing _self;
  final $Res Function(DriveSyncSyncing) _then;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accountEmail = null,}) {
  return _then(DriveSyncSyncing(
accountEmail: null == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DriveSyncMerged implements DriveSyncStatus {
  const DriveSyncMerged({required this.accountEmail, this.lastSyncedAt});
  

 final  String accountEmail;
 final  DateTime? lastSyncedAt;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveSyncMergedCopyWith<DriveSyncMerged> get copyWith => _$DriveSyncMergedCopyWithImpl<DriveSyncMerged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncMerged&&(identical(other.accountEmail, accountEmail) || other.accountEmail == accountEmail)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,accountEmail,lastSyncedAt);

@override
String toString() {
  return 'DriveSyncStatus.merged(accountEmail: $accountEmail, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $DriveSyncMergedCopyWith<$Res> implements $DriveSyncStatusCopyWith<$Res> {
  factory $DriveSyncMergedCopyWith(DriveSyncMerged value, $Res Function(DriveSyncMerged) _then) = _$DriveSyncMergedCopyWithImpl;
@useResult
$Res call({
 String accountEmail, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$DriveSyncMergedCopyWithImpl<$Res>
    implements $DriveSyncMergedCopyWith<$Res> {
  _$DriveSyncMergedCopyWithImpl(this._self, this._then);

  final DriveSyncMerged _self;
  final $Res Function(DriveSyncMerged) _then;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accountEmail = null,Object? lastSyncedAt = freezed,}) {
  return _then(DriveSyncMerged(
accountEmail: null == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class DriveSyncNeedsReauth implements DriveSyncStatus {
  const DriveSyncNeedsReauth({required this.accountEmail});
  

 final  String accountEmail;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveSyncNeedsReauthCopyWith<DriveSyncNeedsReauth> get copyWith => _$DriveSyncNeedsReauthCopyWithImpl<DriveSyncNeedsReauth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncNeedsReauth&&(identical(other.accountEmail, accountEmail) || other.accountEmail == accountEmail));
}


@override
int get hashCode => Object.hash(runtimeType,accountEmail);

@override
String toString() {
  return 'DriveSyncStatus.needsReauth(accountEmail: $accountEmail)';
}


}

/// @nodoc
abstract mixin class $DriveSyncNeedsReauthCopyWith<$Res> implements $DriveSyncStatusCopyWith<$Res> {
  factory $DriveSyncNeedsReauthCopyWith(DriveSyncNeedsReauth value, $Res Function(DriveSyncNeedsReauth) _then) = _$DriveSyncNeedsReauthCopyWithImpl;
@useResult
$Res call({
 String accountEmail
});




}
/// @nodoc
class _$DriveSyncNeedsReauthCopyWithImpl<$Res>
    implements $DriveSyncNeedsReauthCopyWith<$Res> {
  _$DriveSyncNeedsReauthCopyWithImpl(this._self, this._then);

  final DriveSyncNeedsReauth _self;
  final $Res Function(DriveSyncNeedsReauth) _then;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accountEmail = null,}) {
  return _then(DriveSyncNeedsReauth(
accountEmail: null == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DriveSyncErrorState implements DriveSyncStatus {
  const DriveSyncErrorState({required this.accountEmail, required this.message});
  

 final  String accountEmail;
 final  String message;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveSyncErrorStateCopyWith<DriveSyncErrorState> get copyWith => _$DriveSyncErrorStateCopyWithImpl<DriveSyncErrorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveSyncErrorState&&(identical(other.accountEmail, accountEmail) || other.accountEmail == accountEmail)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,accountEmail,message);

@override
String toString() {
  return 'DriveSyncStatus.error(accountEmail: $accountEmail, message: $message)';
}


}

/// @nodoc
abstract mixin class $DriveSyncErrorStateCopyWith<$Res> implements $DriveSyncStatusCopyWith<$Res> {
  factory $DriveSyncErrorStateCopyWith(DriveSyncErrorState value, $Res Function(DriveSyncErrorState) _then) = _$DriveSyncErrorStateCopyWithImpl;
@useResult
$Res call({
 String accountEmail, String message
});




}
/// @nodoc
class _$DriveSyncErrorStateCopyWithImpl<$Res>
    implements $DriveSyncErrorStateCopyWith<$Res> {
  _$DriveSyncErrorStateCopyWithImpl(this._self, this._then);

  final DriveSyncErrorState _self;
  final $Res Function(DriveSyncErrorState) _then;

/// Create a copy of DriveSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accountEmail = null,Object? message = null,}) {
  return _then(DriveSyncErrorState(
accountEmail: null == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
