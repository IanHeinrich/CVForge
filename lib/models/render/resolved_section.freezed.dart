// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resolved_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResolvedSection {

 String get title;
/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedSectionCopyWith<ResolvedSection> get copyWith => _$ResolvedSectionCopyWithImpl<ResolvedSection>(this as ResolvedSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedSection&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode => Object.hash(runtimeType,title);

@override
String toString() {
  return 'ResolvedSection(title: $title)';
}


}

/// @nodoc
abstract mixin class $ResolvedSectionCopyWith<$Res>  {
  factory $ResolvedSectionCopyWith(ResolvedSection value, $Res Function(ResolvedSection) _then) = _$ResolvedSectionCopyWithImpl;
@useResult
$Res call({
 String title
});




}
/// @nodoc
class _$ResolvedSectionCopyWithImpl<$Res>
    implements $ResolvedSectionCopyWith<$Res> {
  _$ResolvedSectionCopyWithImpl(this._self, this._then);

  final ResolvedSection _self;
  final $Res Function(ResolvedSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedSection].
extension ResolvedSectionPatterns on ResolvedSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ResolvedSummarySection value)?  summary,TResult Function( ResolvedExperienceSection value)?  experience,TResult Function( ResolvedSkillsSection value)?  skills,TResult Function( ResolvedEducationSection value)?  education,TResult Function( ResolvedHobbiesSection value)?  hobbies,TResult Function( ResolvedReferencesSection value)?  references,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that);case ResolvedExperienceSection() when experience != null:
return experience(_that);case ResolvedSkillsSection() when skills != null:
return skills(_that);case ResolvedEducationSection() when education != null:
return education(_that);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that);case ResolvedReferencesSection() when references != null:
return references(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ResolvedSummarySection value)  summary,required TResult Function( ResolvedExperienceSection value)  experience,required TResult Function( ResolvedSkillsSection value)  skills,required TResult Function( ResolvedEducationSection value)  education,required TResult Function( ResolvedHobbiesSection value)  hobbies,required TResult Function( ResolvedReferencesSection value)  references,}){
final _that = this;
switch (_that) {
case ResolvedSummarySection():
return summary(_that);case ResolvedExperienceSection():
return experience(_that);case ResolvedSkillsSection():
return skills(_that);case ResolvedEducationSection():
return education(_that);case ResolvedHobbiesSection():
return hobbies(_that);case ResolvedReferencesSection():
return references(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ResolvedSummarySection value)?  summary,TResult? Function( ResolvedExperienceSection value)?  experience,TResult? Function( ResolvedSkillsSection value)?  skills,TResult? Function( ResolvedEducationSection value)?  education,TResult? Function( ResolvedHobbiesSection value)?  hobbies,TResult? Function( ResolvedReferencesSection value)?  references,}){
final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that);case ResolvedExperienceSection() when experience != null:
return experience(_that);case ResolvedSkillsSection() when skills != null:
return skills(_that);case ResolvedEducationSection() when education != null:
return education(_that);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that);case ResolvedReferencesSection() when references != null:
return references(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String title,  String text)?  summary,TResult Function( String title,  List<ResolvedRole> roles)?  experience,TResult Function( String title,  List<ResolvedSkillGroup> groups)?  skills,TResult Function( String title,  List<ResolvedQualification> items)?  education,TResult Function( String title,  List<String> items)?  hobbies,TResult Function( String title,  String text)?  references,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that.title,_that.text);case ResolvedExperienceSection() when experience != null:
return experience(_that.title,_that.roles);case ResolvedSkillsSection() when skills != null:
return skills(_that.title,_that.groups);case ResolvedEducationSection() when education != null:
return education(_that.title,_that.items);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that.title,_that.items);case ResolvedReferencesSection() when references != null:
return references(_that.title,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String title,  String text)  summary,required TResult Function( String title,  List<ResolvedRole> roles)  experience,required TResult Function( String title,  List<ResolvedSkillGroup> groups)  skills,required TResult Function( String title,  List<ResolvedQualification> items)  education,required TResult Function( String title,  List<String> items)  hobbies,required TResult Function( String title,  String text)  references,}) {final _that = this;
switch (_that) {
case ResolvedSummarySection():
return summary(_that.title,_that.text);case ResolvedExperienceSection():
return experience(_that.title,_that.roles);case ResolvedSkillsSection():
return skills(_that.title,_that.groups);case ResolvedEducationSection():
return education(_that.title,_that.items);case ResolvedHobbiesSection():
return hobbies(_that.title,_that.items);case ResolvedReferencesSection():
return references(_that.title,_that.text);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String title,  String text)?  summary,TResult? Function( String title,  List<ResolvedRole> roles)?  experience,TResult? Function( String title,  List<ResolvedSkillGroup> groups)?  skills,TResult? Function( String title,  List<ResolvedQualification> items)?  education,TResult? Function( String title,  List<String> items)?  hobbies,TResult? Function( String title,  String text)?  references,}) {final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that.title,_that.text);case ResolvedExperienceSection() when experience != null:
return experience(_that.title,_that.roles);case ResolvedSkillsSection() when skills != null:
return skills(_that.title,_that.groups);case ResolvedEducationSection() when education != null:
return education(_that.title,_that.items);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that.title,_that.items);case ResolvedReferencesSection() when references != null:
return references(_that.title,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class ResolvedSummarySection implements ResolvedSection {
  const ResolvedSummarySection({required this.title, required this.text});
  

@override final  String title;
 final  String text;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedSummarySectionCopyWith<ResolvedSummarySection> get copyWith => _$ResolvedSummarySectionCopyWithImpl<ResolvedSummarySection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedSummarySection&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,title,text);

@override
String toString() {
  return 'ResolvedSection.summary(title: $title, text: $text)';
}


}

/// @nodoc
abstract mixin class $ResolvedSummarySectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedSummarySectionCopyWith(ResolvedSummarySection value, $Res Function(ResolvedSummarySection) _then) = _$ResolvedSummarySectionCopyWithImpl;
@override @useResult
$Res call({
 String title, String text
});




}
/// @nodoc
class _$ResolvedSummarySectionCopyWithImpl<$Res>
    implements $ResolvedSummarySectionCopyWith<$Res> {
  _$ResolvedSummarySectionCopyWithImpl(this._self, this._then);

  final ResolvedSummarySection _self;
  final $Res Function(ResolvedSummarySection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? text = null,}) {
  return _then(ResolvedSummarySection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ResolvedExperienceSection implements ResolvedSection {
  const ResolvedExperienceSection({required this.title, required final  List<ResolvedRole> roles}): _roles = roles;
  

@override final  String title;
 final  List<ResolvedRole> _roles;
 List<ResolvedRole> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}


/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedExperienceSectionCopyWith<ResolvedExperienceSection> get copyWith => _$ResolvedExperienceSectionCopyWithImpl<ResolvedExperienceSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedExperienceSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._roles, _roles));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_roles));

@override
String toString() {
  return 'ResolvedSection.experience(title: $title, roles: $roles)';
}


}

/// @nodoc
abstract mixin class $ResolvedExperienceSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedExperienceSectionCopyWith(ResolvedExperienceSection value, $Res Function(ResolvedExperienceSection) _then) = _$ResolvedExperienceSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ResolvedRole> roles
});




}
/// @nodoc
class _$ResolvedExperienceSectionCopyWithImpl<$Res>
    implements $ResolvedExperienceSectionCopyWith<$Res> {
  _$ResolvedExperienceSectionCopyWithImpl(this._self, this._then);

  final ResolvedExperienceSection _self;
  final $Res Function(ResolvedExperienceSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? roles = null,}) {
  return _then(ResolvedExperienceSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<ResolvedRole>,
  ));
}


}

/// @nodoc


class ResolvedSkillsSection implements ResolvedSection {
  const ResolvedSkillsSection({required this.title, required final  List<ResolvedSkillGroup> groups}): _groups = groups;
  

@override final  String title;
 final  List<ResolvedSkillGroup> _groups;
 List<ResolvedSkillGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedSkillsSectionCopyWith<ResolvedSkillsSection> get copyWith => _$ResolvedSkillsSectionCopyWithImpl<ResolvedSkillsSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedSkillsSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._groups, _groups));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'ResolvedSection.skills(title: $title, groups: $groups)';
}


}

/// @nodoc
abstract mixin class $ResolvedSkillsSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedSkillsSectionCopyWith(ResolvedSkillsSection value, $Res Function(ResolvedSkillsSection) _then) = _$ResolvedSkillsSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ResolvedSkillGroup> groups
});




}
/// @nodoc
class _$ResolvedSkillsSectionCopyWithImpl<$Res>
    implements $ResolvedSkillsSectionCopyWith<$Res> {
  _$ResolvedSkillsSectionCopyWithImpl(this._self, this._then);

  final ResolvedSkillsSection _self;
  final $Res Function(ResolvedSkillsSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? groups = null,}) {
  return _then(ResolvedSkillsSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<ResolvedSkillGroup>,
  ));
}


}

/// @nodoc


class ResolvedEducationSection implements ResolvedSection {
  const ResolvedEducationSection({required this.title, required final  List<ResolvedQualification> items}): _items = items;
  

@override final  String title;
 final  List<ResolvedQualification> _items;
 List<ResolvedQualification> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedEducationSectionCopyWith<ResolvedEducationSection> get copyWith => _$ResolvedEducationSectionCopyWithImpl<ResolvedEducationSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedEducationSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ResolvedSection.education(title: $title, items: $items)';
}


}

/// @nodoc
abstract mixin class $ResolvedEducationSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedEducationSectionCopyWith(ResolvedEducationSection value, $Res Function(ResolvedEducationSection) _then) = _$ResolvedEducationSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ResolvedQualification> items
});




}
/// @nodoc
class _$ResolvedEducationSectionCopyWithImpl<$Res>
    implements $ResolvedEducationSectionCopyWith<$Res> {
  _$ResolvedEducationSectionCopyWithImpl(this._self, this._then);

  final ResolvedEducationSection _self;
  final $Res Function(ResolvedEducationSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? items = null,}) {
  return _then(ResolvedEducationSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ResolvedQualification>,
  ));
}


}

/// @nodoc


class ResolvedHobbiesSection implements ResolvedSection {
  const ResolvedHobbiesSection({required this.title, required final  List<String> items}): _items = items;
  

@override final  String title;
 final  List<String> _items;
 List<String> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedHobbiesSectionCopyWith<ResolvedHobbiesSection> get copyWith => _$ResolvedHobbiesSectionCopyWithImpl<ResolvedHobbiesSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedHobbiesSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ResolvedSection.hobbies(title: $title, items: $items)';
}


}

/// @nodoc
abstract mixin class $ResolvedHobbiesSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedHobbiesSectionCopyWith(ResolvedHobbiesSection value, $Res Function(ResolvedHobbiesSection) _then) = _$ResolvedHobbiesSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<String> items
});




}
/// @nodoc
class _$ResolvedHobbiesSectionCopyWithImpl<$Res>
    implements $ResolvedHobbiesSectionCopyWith<$Res> {
  _$ResolvedHobbiesSectionCopyWithImpl(this._self, this._then);

  final ResolvedHobbiesSection _self;
  final $Res Function(ResolvedHobbiesSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? items = null,}) {
  return _then(ResolvedHobbiesSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ResolvedReferencesSection implements ResolvedSection {
  const ResolvedReferencesSection({required this.title, required this.text});
  

@override final  String title;
 final  String text;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedReferencesSectionCopyWith<ResolvedReferencesSection> get copyWith => _$ResolvedReferencesSectionCopyWithImpl<ResolvedReferencesSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedReferencesSection&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,title,text);

@override
String toString() {
  return 'ResolvedSection.references(title: $title, text: $text)';
}


}

/// @nodoc
abstract mixin class $ResolvedReferencesSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedReferencesSectionCopyWith(ResolvedReferencesSection value, $Res Function(ResolvedReferencesSection) _then) = _$ResolvedReferencesSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, String text
});




}
/// @nodoc
class _$ResolvedReferencesSectionCopyWithImpl<$Res>
    implements $ResolvedReferencesSectionCopyWith<$Res> {
  _$ResolvedReferencesSectionCopyWithImpl(this._self, this._then);

  final ResolvedReferencesSection _self;
  final $Res Function(ResolvedReferencesSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? text = null,}) {
  return _then(ResolvedReferencesSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ResolvedRole {

 String get role; String get company; String get location;/// Pre-formatted, e.g. "01/2025 - current". Formatting happens in the
/// composer, not here and not in a template.
 String get dateRange; List<ResolvedBullet> get bullets;
/// Create a copy of ResolvedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedRoleCopyWith<ResolvedRole> get copyWith => _$ResolvedRoleCopyWithImpl<ResolvedRole>(this as ResolvedRole, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedRole&&(identical(other.role, role) || other.role == role)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&const DeepCollectionEquality().equals(other.bullets, bullets));
}


@override
int get hashCode => Object.hash(runtimeType,role,company,location,dateRange,const DeepCollectionEquality().hash(bullets));

@override
String toString() {
  return 'ResolvedRole(role: $role, company: $company, location: $location, dateRange: $dateRange, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class $ResolvedRoleCopyWith<$Res>  {
  factory $ResolvedRoleCopyWith(ResolvedRole value, $Res Function(ResolvedRole) _then) = _$ResolvedRoleCopyWithImpl;
@useResult
$Res call({
 String role, String company, String location, String dateRange, List<ResolvedBullet> bullets
});




}
/// @nodoc
class _$ResolvedRoleCopyWithImpl<$Res>
    implements $ResolvedRoleCopyWith<$Res> {
  _$ResolvedRoleCopyWithImpl(this._self, this._then);

  final ResolvedRole _self;
  final $Res Function(ResolvedRole) _then;

/// Create a copy of ResolvedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? company = null,Object? location = null,Object? dateRange = null,Object? bullets = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as String,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedRole].
extension ResolvedRolePatterns on ResolvedRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedRole value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedRole value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  String company,  String location,  String dateRange,  List<ResolvedBullet> bullets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedRole() when $default != null:
return $default(_that.role,_that.company,_that.location,_that.dateRange,_that.bullets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  String company,  String location,  String dateRange,  List<ResolvedBullet> bullets)  $default,) {final _that = this;
switch (_that) {
case _ResolvedRole():
return $default(_that.role,_that.company,_that.location,_that.dateRange,_that.bullets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  String company,  String location,  String dateRange,  List<ResolvedBullet> bullets)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedRole() when $default != null:
return $default(_that.role,_that.company,_that.location,_that.dateRange,_that.bullets);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedRole implements ResolvedRole {
  const _ResolvedRole({required this.role, required this.company, required this.location, required this.dateRange, final  List<ResolvedBullet> bullets = const <ResolvedBullet>[]}): _bullets = bullets;
  

@override final  String role;
@override final  String company;
@override final  String location;
/// Pre-formatted, e.g. "01/2025 - current". Formatting happens in the
/// composer, not here and not in a template.
@override final  String dateRange;
 final  List<ResolvedBullet> _bullets;
@override@JsonKey() List<ResolvedBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}


/// Create a copy of ResolvedRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedRoleCopyWith<_ResolvedRole> get copyWith => __$ResolvedRoleCopyWithImpl<_ResolvedRole>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedRole&&(identical(other.role, role) || other.role == role)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&const DeepCollectionEquality().equals(other._bullets, _bullets));
}


@override
int get hashCode => Object.hash(runtimeType,role,company,location,dateRange,const DeepCollectionEquality().hash(_bullets));

@override
String toString() {
  return 'ResolvedRole(role: $role, company: $company, location: $location, dateRange: $dateRange, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class _$ResolvedRoleCopyWith<$Res> implements $ResolvedRoleCopyWith<$Res> {
  factory _$ResolvedRoleCopyWith(_ResolvedRole value, $Res Function(_ResolvedRole) _then) = __$ResolvedRoleCopyWithImpl;
@override @useResult
$Res call({
 String role, String company, String location, String dateRange, List<ResolvedBullet> bullets
});




}
/// @nodoc
class __$ResolvedRoleCopyWithImpl<$Res>
    implements _$ResolvedRoleCopyWith<$Res> {
  __$ResolvedRoleCopyWithImpl(this._self, this._then);

  final _ResolvedRole _self;
  final $Res Function(_ResolvedRole) _then;

/// Create a copy of ResolvedRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? company = null,Object? location = null,Object? dateRange = null,Object? bullets = null,}) {
  return _then(_ResolvedRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as String,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
  ));
}


}

/// @nodoc
mixin _$ResolvedBullet {

 String? get label; String get text;
/// Create a copy of ResolvedBullet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedBulletCopyWith<ResolvedBullet> get copyWith => _$ResolvedBulletCopyWithImpl<ResolvedBullet>(this as ResolvedBullet, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedBullet&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,text);

@override
String toString() {
  return 'ResolvedBullet(label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class $ResolvedBulletCopyWith<$Res>  {
  factory $ResolvedBulletCopyWith(ResolvedBullet value, $Res Function(ResolvedBullet) _then) = _$ResolvedBulletCopyWithImpl;
@useResult
$Res call({
 String? label, String text
});




}
/// @nodoc
class _$ResolvedBulletCopyWithImpl<$Res>
    implements $ResolvedBulletCopyWith<$Res> {
  _$ResolvedBulletCopyWithImpl(this._self, this._then);

  final ResolvedBullet _self;
  final $Res Function(ResolvedBullet) _then;

/// Create a copy of ResolvedBullet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = freezed,Object? text = null,}) {
  return _then(_self.copyWith(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedBullet].
extension ResolvedBulletPatterns on ResolvedBullet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedBullet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedBullet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedBullet value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedBullet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedBullet value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedBullet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? label,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedBullet() when $default != null:
return $default(_that.label,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? label,  String text)  $default,) {final _that = this;
switch (_that) {
case _ResolvedBullet():
return $default(_that.label,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? label,  String text)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedBullet() when $default != null:
return $default(_that.label,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedBullet implements ResolvedBullet {
  const _ResolvedBullet({this.label, required this.text});
  

@override final  String? label;
@override final  String text;

/// Create a copy of ResolvedBullet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedBulletCopyWith<_ResolvedBullet> get copyWith => __$ResolvedBulletCopyWithImpl<_ResolvedBullet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedBullet&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,text);

@override
String toString() {
  return 'ResolvedBullet(label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class _$ResolvedBulletCopyWith<$Res> implements $ResolvedBulletCopyWith<$Res> {
  factory _$ResolvedBulletCopyWith(_ResolvedBullet value, $Res Function(_ResolvedBullet) _then) = __$ResolvedBulletCopyWithImpl;
@override @useResult
$Res call({
 String? label, String text
});




}
/// @nodoc
class __$ResolvedBulletCopyWithImpl<$Res>
    implements _$ResolvedBulletCopyWith<$Res> {
  __$ResolvedBulletCopyWithImpl(this._self, this._then);

  final _ResolvedBullet _self;
  final $Res Function(_ResolvedBullet) _then;

/// Create a copy of ResolvedBullet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = freezed,Object? text = null,}) {
  return _then(_ResolvedBullet(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ResolvedSkillGroup {

 String get category; List<String> get skills;
/// Create a copy of ResolvedSkillGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedSkillGroupCopyWith<ResolvedSkillGroup> get copyWith => _$ResolvedSkillGroupCopyWithImpl<ResolvedSkillGroup>(this as ResolvedSkillGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedSkillGroup&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.skills, skills));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(skills));

@override
String toString() {
  return 'ResolvedSkillGroup(category: $category, skills: $skills)';
}


}

/// @nodoc
abstract mixin class $ResolvedSkillGroupCopyWith<$Res>  {
  factory $ResolvedSkillGroupCopyWith(ResolvedSkillGroup value, $Res Function(ResolvedSkillGroup) _then) = _$ResolvedSkillGroupCopyWithImpl;
@useResult
$Res call({
 String category, List<String> skills
});




}
/// @nodoc
class _$ResolvedSkillGroupCopyWithImpl<$Res>
    implements $ResolvedSkillGroupCopyWith<$Res> {
  _$ResolvedSkillGroupCopyWithImpl(this._self, this._then);

  final ResolvedSkillGroup _self;
  final $Res Function(ResolvedSkillGroup) _then;

/// Create a copy of ResolvedSkillGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? skills = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedSkillGroup].
extension ResolvedSkillGroupPatterns on ResolvedSkillGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedSkillGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedSkillGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedSkillGroup value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedSkillGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedSkillGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedSkillGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  List<String> skills)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedSkillGroup() when $default != null:
return $default(_that.category,_that.skills);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  List<String> skills)  $default,) {final _that = this;
switch (_that) {
case _ResolvedSkillGroup():
return $default(_that.category,_that.skills);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  List<String> skills)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedSkillGroup() when $default != null:
return $default(_that.category,_that.skills);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedSkillGroup implements ResolvedSkillGroup {
  const _ResolvedSkillGroup({required this.category, final  List<String> skills = const <String>[]}): _skills = skills;
  

@override final  String category;
 final  List<String> _skills;
@override@JsonKey() List<String> get skills {
  if (_skills is EqualUnmodifiableListView) return _skills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skills);
}


/// Create a copy of ResolvedSkillGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedSkillGroupCopyWith<_ResolvedSkillGroup> get copyWith => __$ResolvedSkillGroupCopyWithImpl<_ResolvedSkillGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedSkillGroup&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._skills, _skills));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(_skills));

@override
String toString() {
  return 'ResolvedSkillGroup(category: $category, skills: $skills)';
}


}

/// @nodoc
abstract mixin class _$ResolvedSkillGroupCopyWith<$Res> implements $ResolvedSkillGroupCopyWith<$Res> {
  factory _$ResolvedSkillGroupCopyWith(_ResolvedSkillGroup value, $Res Function(_ResolvedSkillGroup) _then) = __$ResolvedSkillGroupCopyWithImpl;
@override @useResult
$Res call({
 String category, List<String> skills
});




}
/// @nodoc
class __$ResolvedSkillGroupCopyWithImpl<$Res>
    implements _$ResolvedSkillGroupCopyWith<$Res> {
  __$ResolvedSkillGroupCopyWithImpl(this._self, this._then);

  final _ResolvedSkillGroup _self;
  final $Res Function(_ResolvedSkillGroup) _then;

/// Create a copy of ResolvedSkillGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? skills = null,}) {
  return _then(_ResolvedSkillGroup(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$ResolvedQualification {

 String get qualification; String get institution; String? get location;/// Pre-formatted (e.g. "2021"), not a raw int — same reasoning as
/// [ResolvedRole.dateRange].
 String? get yearLabel; String? get grade; String? get details;
/// Create a copy of ResolvedQualification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedQualificationCopyWith<ResolvedQualification> get copyWith => _$ResolvedQualificationCopyWithImpl<ResolvedQualification>(this as ResolvedQualification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedQualification&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.location, location) || other.location == location)&&(identical(other.yearLabel, yearLabel) || other.yearLabel == yearLabel)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,qualification,institution,location,yearLabel,grade,details);

@override
String toString() {
  return 'ResolvedQualification(qualification: $qualification, institution: $institution, location: $location, yearLabel: $yearLabel, grade: $grade, details: $details)';
}


}

/// @nodoc
abstract mixin class $ResolvedQualificationCopyWith<$Res>  {
  factory $ResolvedQualificationCopyWith(ResolvedQualification value, $Res Function(ResolvedQualification) _then) = _$ResolvedQualificationCopyWithImpl;
@useResult
$Res call({
 String qualification, String institution, String? location, String? yearLabel, String? grade, String? details
});




}
/// @nodoc
class _$ResolvedQualificationCopyWithImpl<$Res>
    implements $ResolvedQualificationCopyWith<$Res> {
  _$ResolvedQualificationCopyWithImpl(this._self, this._then);

  final ResolvedQualification _self;
  final $Res Function(ResolvedQualification) _then;

/// Create a copy of ResolvedQualification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? qualification = null,Object? institution = null,Object? location = freezed,Object? yearLabel = freezed,Object? grade = freezed,Object? details = freezed,}) {
  return _then(_self.copyWith(
qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String,institution: null == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,yearLabel: freezed == yearLabel ? _self.yearLabel : yearLabel // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedQualification].
extension ResolvedQualificationPatterns on ResolvedQualification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedQualification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedQualification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedQualification value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedQualification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedQualification value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedQualification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String qualification,  String institution,  String? location,  String? yearLabel,  String? grade,  String? details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedQualification() when $default != null:
return $default(_that.qualification,_that.institution,_that.location,_that.yearLabel,_that.grade,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String qualification,  String institution,  String? location,  String? yearLabel,  String? grade,  String? details)  $default,) {final _that = this;
switch (_that) {
case _ResolvedQualification():
return $default(_that.qualification,_that.institution,_that.location,_that.yearLabel,_that.grade,_that.details);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String qualification,  String institution,  String? location,  String? yearLabel,  String? grade,  String? details)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedQualification() when $default != null:
return $default(_that.qualification,_that.institution,_that.location,_that.yearLabel,_that.grade,_that.details);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedQualification implements ResolvedQualification {
  const _ResolvedQualification({required this.qualification, required this.institution, this.location, this.yearLabel, this.grade, this.details});
  

@override final  String qualification;
@override final  String institution;
@override final  String? location;
/// Pre-formatted (e.g. "2021"), not a raw int — same reasoning as
/// [ResolvedRole.dateRange].
@override final  String? yearLabel;
@override final  String? grade;
@override final  String? details;

/// Create a copy of ResolvedQualification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedQualificationCopyWith<_ResolvedQualification> get copyWith => __$ResolvedQualificationCopyWithImpl<_ResolvedQualification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedQualification&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.location, location) || other.location == location)&&(identical(other.yearLabel, yearLabel) || other.yearLabel == yearLabel)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,qualification,institution,location,yearLabel,grade,details);

@override
String toString() {
  return 'ResolvedQualification(qualification: $qualification, institution: $institution, location: $location, yearLabel: $yearLabel, grade: $grade, details: $details)';
}


}

/// @nodoc
abstract mixin class _$ResolvedQualificationCopyWith<$Res> implements $ResolvedQualificationCopyWith<$Res> {
  factory _$ResolvedQualificationCopyWith(_ResolvedQualification value, $Res Function(_ResolvedQualification) _then) = __$ResolvedQualificationCopyWithImpl;
@override @useResult
$Res call({
 String qualification, String institution, String? location, String? yearLabel, String? grade, String? details
});




}
/// @nodoc
class __$ResolvedQualificationCopyWithImpl<$Res>
    implements _$ResolvedQualificationCopyWith<$Res> {
  __$ResolvedQualificationCopyWithImpl(this._self, this._then);

  final _ResolvedQualification _self;
  final $Res Function(_ResolvedQualification) _then;

/// Create a copy of ResolvedQualification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? qualification = null,Object? institution = null,Object? location = freezed,Object? yearLabel = freezed,Object? grade = freezed,Object? details = freezed,}) {
  return _then(_ResolvedQualification(
qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String,institution: null == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,yearLabel: freezed == yearLabel ? _self.yearLabel : yearLabel // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
