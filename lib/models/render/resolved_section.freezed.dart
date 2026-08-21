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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ResolvedSummarySection value)?  summary,TResult Function( ResolvedExperienceSection value)?  experience,TResult Function( ResolvedProjectsSection value)?  projects,TResult Function( ResolvedSkillsSection value)?  skills,TResult Function( ResolvedEducationSection value)?  education,TResult Function( ResolvedHobbiesSection value)?  hobbies,TResult Function( ResolvedReferencesSection value)?  references,TResult Function( ResolvedPublicationsSection value)?  publications,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that);case ResolvedExperienceSection() when experience != null:
return experience(_that);case ResolvedProjectsSection() when projects != null:
return projects(_that);case ResolvedSkillsSection() when skills != null:
return skills(_that);case ResolvedEducationSection() when education != null:
return education(_that);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that);case ResolvedReferencesSection() when references != null:
return references(_that);case ResolvedPublicationsSection() when publications != null:
return publications(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ResolvedSummarySection value)  summary,required TResult Function( ResolvedExperienceSection value)  experience,required TResult Function( ResolvedProjectsSection value)  projects,required TResult Function( ResolvedSkillsSection value)  skills,required TResult Function( ResolvedEducationSection value)  education,required TResult Function( ResolvedHobbiesSection value)  hobbies,required TResult Function( ResolvedReferencesSection value)  references,required TResult Function( ResolvedPublicationsSection value)  publications,}){
final _that = this;
switch (_that) {
case ResolvedSummarySection():
return summary(_that);case ResolvedExperienceSection():
return experience(_that);case ResolvedProjectsSection():
return projects(_that);case ResolvedSkillsSection():
return skills(_that);case ResolvedEducationSection():
return education(_that);case ResolvedHobbiesSection():
return hobbies(_that);case ResolvedReferencesSection():
return references(_that);case ResolvedPublicationsSection():
return publications(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ResolvedSummarySection value)?  summary,TResult? Function( ResolvedExperienceSection value)?  experience,TResult? Function( ResolvedProjectsSection value)?  projects,TResult? Function( ResolvedSkillsSection value)?  skills,TResult? Function( ResolvedEducationSection value)?  education,TResult? Function( ResolvedHobbiesSection value)?  hobbies,TResult? Function( ResolvedReferencesSection value)?  references,TResult? Function( ResolvedPublicationsSection value)?  publications,}){
final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that);case ResolvedExperienceSection() when experience != null:
return experience(_that);case ResolvedProjectsSection() when projects != null:
return projects(_that);case ResolvedSkillsSection() when skills != null:
return skills(_that);case ResolvedEducationSection() when education != null:
return education(_that);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that);case ResolvedReferencesSection() when references != null:
return references(_that);case ResolvedPublicationsSection() when publications != null:
return publications(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String title,  String text)?  summary,TResult Function( String title,  List<ResolvedCompanyGroup> groups)?  experience,TResult Function( String title,  List<ResolvedProject> items)?  projects,TResult Function( String title,  List<ResolvedSkillGroup> groups)?  skills,TResult Function( String title,  List<ResolvedQualification> items)?  education,TResult Function( String title,  List<String> items)?  hobbies,TResult Function( String title,  String text)?  references,TResult Function( String title,  List<ResolvedPublication> items)?  publications,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that.title,_that.text);case ResolvedExperienceSection() when experience != null:
return experience(_that.title,_that.groups);case ResolvedProjectsSection() when projects != null:
return projects(_that.title,_that.items);case ResolvedSkillsSection() when skills != null:
return skills(_that.title,_that.groups);case ResolvedEducationSection() when education != null:
return education(_that.title,_that.items);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that.title,_that.items);case ResolvedReferencesSection() when references != null:
return references(_that.title,_that.text);case ResolvedPublicationsSection() when publications != null:
return publications(_that.title,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String title,  String text)  summary,required TResult Function( String title,  List<ResolvedCompanyGroup> groups)  experience,required TResult Function( String title,  List<ResolvedProject> items)  projects,required TResult Function( String title,  List<ResolvedSkillGroup> groups)  skills,required TResult Function( String title,  List<ResolvedQualification> items)  education,required TResult Function( String title,  List<String> items)  hobbies,required TResult Function( String title,  String text)  references,required TResult Function( String title,  List<ResolvedPublication> items)  publications,}) {final _that = this;
switch (_that) {
case ResolvedSummarySection():
return summary(_that.title,_that.text);case ResolvedExperienceSection():
return experience(_that.title,_that.groups);case ResolvedProjectsSection():
return projects(_that.title,_that.items);case ResolvedSkillsSection():
return skills(_that.title,_that.groups);case ResolvedEducationSection():
return education(_that.title,_that.items);case ResolvedHobbiesSection():
return hobbies(_that.title,_that.items);case ResolvedReferencesSection():
return references(_that.title,_that.text);case ResolvedPublicationsSection():
return publications(_that.title,_that.items);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String title,  String text)?  summary,TResult? Function( String title,  List<ResolvedCompanyGroup> groups)?  experience,TResult? Function( String title,  List<ResolvedProject> items)?  projects,TResult? Function( String title,  List<ResolvedSkillGroup> groups)?  skills,TResult? Function( String title,  List<ResolvedQualification> items)?  education,TResult? Function( String title,  List<String> items)?  hobbies,TResult? Function( String title,  String text)?  references,TResult? Function( String title,  List<ResolvedPublication> items)?  publications,}) {final _that = this;
switch (_that) {
case ResolvedSummarySection() when summary != null:
return summary(_that.title,_that.text);case ResolvedExperienceSection() when experience != null:
return experience(_that.title,_that.groups);case ResolvedProjectsSection() when projects != null:
return projects(_that.title,_that.items);case ResolvedSkillsSection() when skills != null:
return skills(_that.title,_that.groups);case ResolvedEducationSection() when education != null:
return education(_that.title,_that.items);case ResolvedHobbiesSection() when hobbies != null:
return hobbies(_that.title,_that.items);case ResolvedReferencesSection() when references != null:
return references(_that.title,_that.text);case ResolvedPublicationsSection() when publications != null:
return publications(_that.title,_that.items);case _:
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
  const ResolvedExperienceSection({required this.title, required final  List<ResolvedCompanyGroup> groups}): _groups = groups;
  

@override final  String title;
 final  List<ResolvedCompanyGroup> _groups;
 List<ResolvedCompanyGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedExperienceSectionCopyWith<ResolvedExperienceSection> get copyWith => _$ResolvedExperienceSectionCopyWithImpl<ResolvedExperienceSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedExperienceSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._groups, _groups));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'ResolvedSection.experience(title: $title, groups: $groups)';
}


}

/// @nodoc
abstract mixin class $ResolvedExperienceSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedExperienceSectionCopyWith(ResolvedExperienceSection value, $Res Function(ResolvedExperienceSection) _then) = _$ResolvedExperienceSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ResolvedCompanyGroup> groups
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
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? groups = null,}) {
  return _then(ResolvedExperienceSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<ResolvedCompanyGroup>,
  ));
}


}

/// @nodoc


class ResolvedProjectsSection implements ResolvedSection {
  const ResolvedProjectsSection({required this.title, required final  List<ResolvedProject> items}): _items = items;
  

@override final  String title;
 final  List<ResolvedProject> _items;
 List<ResolvedProject> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedProjectsSectionCopyWith<ResolvedProjectsSection> get copyWith => _$ResolvedProjectsSectionCopyWithImpl<ResolvedProjectsSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedProjectsSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ResolvedSection.projects(title: $title, items: $items)';
}


}

/// @nodoc
abstract mixin class $ResolvedProjectsSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedProjectsSectionCopyWith(ResolvedProjectsSection value, $Res Function(ResolvedProjectsSection) _then) = _$ResolvedProjectsSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ResolvedProject> items
});




}
/// @nodoc
class _$ResolvedProjectsSectionCopyWithImpl<$Res>
    implements $ResolvedProjectsSectionCopyWith<$Res> {
  _$ResolvedProjectsSectionCopyWithImpl(this._self, this._then);

  final ResolvedProjectsSection _self;
  final $Res Function(ResolvedProjectsSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? items = null,}) {
  return _then(ResolvedProjectsSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ResolvedProject>,
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


class ResolvedPublicationsSection implements ResolvedSection {
  const ResolvedPublicationsSection({required this.title, required final  List<ResolvedPublication> items}): _items = items;
  

@override final  String title;
 final  List<ResolvedPublication> _items;
 List<ResolvedPublication> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedPublicationsSectionCopyWith<ResolvedPublicationsSection> get copyWith => _$ResolvedPublicationsSectionCopyWithImpl<ResolvedPublicationsSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedPublicationsSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ResolvedSection.publications(title: $title, items: $items)';
}


}

/// @nodoc
abstract mixin class $ResolvedPublicationsSectionCopyWith<$Res> implements $ResolvedSectionCopyWith<$Res> {
  factory $ResolvedPublicationsSectionCopyWith(ResolvedPublicationsSection value, $Res Function(ResolvedPublicationsSection) _then) = _$ResolvedPublicationsSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ResolvedPublication> items
});




}
/// @nodoc
class _$ResolvedPublicationsSectionCopyWithImpl<$Res>
    implements $ResolvedPublicationsSectionCopyWith<$Res> {
  _$ResolvedPublicationsSectionCopyWithImpl(this._self, this._then);

  final ResolvedPublicationsSection _self;
  final $Res Function(ResolvedPublicationsSection) _then;

/// Create a copy of ResolvedSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? items = null,}) {
  return _then(ResolvedPublicationsSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ResolvedPublication>,
  ));
}


}

/// @nodoc
mixin _$ResolvedCompanyGroup {

 String get company; String get location; List<ResolvedPosition> get positions;
/// Create a copy of ResolvedCompanyGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedCompanyGroupCopyWith<ResolvedCompanyGroup> get copyWith => _$ResolvedCompanyGroupCopyWithImpl<ResolvedCompanyGroup>(this as ResolvedCompanyGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedCompanyGroup&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.positions, positions));
}


@override
int get hashCode => Object.hash(runtimeType,company,location,const DeepCollectionEquality().hash(positions));

@override
String toString() {
  return 'ResolvedCompanyGroup(company: $company, location: $location, positions: $positions)';
}


}

/// @nodoc
abstract mixin class $ResolvedCompanyGroupCopyWith<$Res>  {
  factory $ResolvedCompanyGroupCopyWith(ResolvedCompanyGroup value, $Res Function(ResolvedCompanyGroup) _then) = _$ResolvedCompanyGroupCopyWithImpl;
@useResult
$Res call({
 String company, String location, List<ResolvedPosition> positions
});




}
/// @nodoc
class _$ResolvedCompanyGroupCopyWithImpl<$Res>
    implements $ResolvedCompanyGroupCopyWith<$Res> {
  _$ResolvedCompanyGroupCopyWithImpl(this._self, this._then);

  final ResolvedCompanyGroup _self;
  final $Res Function(ResolvedCompanyGroup) _then;

/// Create a copy of ResolvedCompanyGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? company = null,Object? location = null,Object? positions = null,}) {
  return _then(_self.copyWith(
company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<ResolvedPosition>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedCompanyGroup].
extension ResolvedCompanyGroupPatterns on ResolvedCompanyGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedCompanyGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedCompanyGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedCompanyGroup value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedCompanyGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedCompanyGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedCompanyGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String company,  String location,  List<ResolvedPosition> positions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedCompanyGroup() when $default != null:
return $default(_that.company,_that.location,_that.positions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String company,  String location,  List<ResolvedPosition> positions)  $default,) {final _that = this;
switch (_that) {
case _ResolvedCompanyGroup():
return $default(_that.company,_that.location,_that.positions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String company,  String location,  List<ResolvedPosition> positions)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedCompanyGroup() when $default != null:
return $default(_that.company,_that.location,_that.positions);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedCompanyGroup implements ResolvedCompanyGroup {
  const _ResolvedCompanyGroup({required this.company, required this.location, final  List<ResolvedPosition> positions = const <ResolvedPosition>[]}): _positions = positions;
  

@override final  String company;
@override final  String location;
 final  List<ResolvedPosition> _positions;
@override@JsonKey() List<ResolvedPosition> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}


/// Create a copy of ResolvedCompanyGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedCompanyGroupCopyWith<_ResolvedCompanyGroup> get copyWith => __$ResolvedCompanyGroupCopyWithImpl<_ResolvedCompanyGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedCompanyGroup&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._positions, _positions));
}


@override
int get hashCode => Object.hash(runtimeType,company,location,const DeepCollectionEquality().hash(_positions));

@override
String toString() {
  return 'ResolvedCompanyGroup(company: $company, location: $location, positions: $positions)';
}


}

/// @nodoc
abstract mixin class _$ResolvedCompanyGroupCopyWith<$Res> implements $ResolvedCompanyGroupCopyWith<$Res> {
  factory _$ResolvedCompanyGroupCopyWith(_ResolvedCompanyGroup value, $Res Function(_ResolvedCompanyGroup) _then) = __$ResolvedCompanyGroupCopyWithImpl;
@override @useResult
$Res call({
 String company, String location, List<ResolvedPosition> positions
});




}
/// @nodoc
class __$ResolvedCompanyGroupCopyWithImpl<$Res>
    implements _$ResolvedCompanyGroupCopyWith<$Res> {
  __$ResolvedCompanyGroupCopyWithImpl(this._self, this._then);

  final _ResolvedCompanyGroup _self;
  final $Res Function(_ResolvedCompanyGroup) _then;

/// Create a copy of ResolvedCompanyGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? company = null,Object? location = null,Object? positions = null,}) {
  return _then(_ResolvedCompanyGroup(
company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<ResolvedPosition>,
  ));
}


}

/// @nodoc
mixin _$ResolvedPosition {

 String get role;/// Pre-formatted, e.g. "01/2025 - current". Formatting happens in the
/// composer, not here and not in a template.
 String get dateRange; List<ResolvedBullet> get bullets;
/// Create a copy of ResolvedPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedPositionCopyWith<ResolvedPosition> get copyWith => _$ResolvedPositionCopyWithImpl<ResolvedPosition>(this as ResolvedPosition, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedPosition&&(identical(other.role, role) || other.role == role)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&const DeepCollectionEquality().equals(other.bullets, bullets));
}


@override
int get hashCode => Object.hash(runtimeType,role,dateRange,const DeepCollectionEquality().hash(bullets));

@override
String toString() {
  return 'ResolvedPosition(role: $role, dateRange: $dateRange, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class $ResolvedPositionCopyWith<$Res>  {
  factory $ResolvedPositionCopyWith(ResolvedPosition value, $Res Function(ResolvedPosition) _then) = _$ResolvedPositionCopyWithImpl;
@useResult
$Res call({
 String role, String dateRange, List<ResolvedBullet> bullets
});




}
/// @nodoc
class _$ResolvedPositionCopyWithImpl<$Res>
    implements $ResolvedPositionCopyWith<$Res> {
  _$ResolvedPositionCopyWithImpl(this._self, this._then);

  final ResolvedPosition _self;
  final $Res Function(ResolvedPosition) _then;

/// Create a copy of ResolvedPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? dateRange = null,Object? bullets = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as String,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedPosition].
extension ResolvedPositionPatterns on ResolvedPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedPosition value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedPosition value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedPosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  String dateRange,  List<ResolvedBullet> bullets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedPosition() when $default != null:
return $default(_that.role,_that.dateRange,_that.bullets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  String dateRange,  List<ResolvedBullet> bullets)  $default,) {final _that = this;
switch (_that) {
case _ResolvedPosition():
return $default(_that.role,_that.dateRange,_that.bullets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  String dateRange,  List<ResolvedBullet> bullets)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedPosition() when $default != null:
return $default(_that.role,_that.dateRange,_that.bullets);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedPosition implements ResolvedPosition {
  const _ResolvedPosition({required this.role, required this.dateRange, final  List<ResolvedBullet> bullets = const <ResolvedBullet>[]}): _bullets = bullets;
  

@override final  String role;
/// Pre-formatted, e.g. "01/2025 - current". Formatting happens in the
/// composer, not here and not in a template.
@override final  String dateRange;
 final  List<ResolvedBullet> _bullets;
@override@JsonKey() List<ResolvedBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}


/// Create a copy of ResolvedPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedPositionCopyWith<_ResolvedPosition> get copyWith => __$ResolvedPositionCopyWithImpl<_ResolvedPosition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedPosition&&(identical(other.role, role) || other.role == role)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&const DeepCollectionEquality().equals(other._bullets, _bullets));
}


@override
int get hashCode => Object.hash(runtimeType,role,dateRange,const DeepCollectionEquality().hash(_bullets));

@override
String toString() {
  return 'ResolvedPosition(role: $role, dateRange: $dateRange, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class _$ResolvedPositionCopyWith<$Res> implements $ResolvedPositionCopyWith<$Res> {
  factory _$ResolvedPositionCopyWith(_ResolvedPosition value, $Res Function(_ResolvedPosition) _then) = __$ResolvedPositionCopyWithImpl;
@override @useResult
$Res call({
 String role, String dateRange, List<ResolvedBullet> bullets
});




}
/// @nodoc
class __$ResolvedPositionCopyWithImpl<$Res>
    implements _$ResolvedPositionCopyWith<$Res> {
  __$ResolvedPositionCopyWithImpl(this._self, this._then);

  final _ResolvedPosition _self;
  final $Res Function(_ResolvedPosition) _then;

/// Create a copy of ResolvedPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? dateRange = null,Object? bullets = null,}) {
  return _then(_ResolvedPosition(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
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
mixin _$ResolvedProject {

 String get title; String? get link; List<ResolvedBullet> get bullets;
/// Create a copy of ResolvedProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedProjectCopyWith<ResolvedProject> get copyWith => _$ResolvedProjectCopyWithImpl<ResolvedProject>(this as ResolvedProject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedProject&&(identical(other.title, title) || other.title == title)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other.bullets, bullets));
}


@override
int get hashCode => Object.hash(runtimeType,title,link,const DeepCollectionEquality().hash(bullets));

@override
String toString() {
  return 'ResolvedProject(title: $title, link: $link, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class $ResolvedProjectCopyWith<$Res>  {
  factory $ResolvedProjectCopyWith(ResolvedProject value, $Res Function(ResolvedProject) _then) = _$ResolvedProjectCopyWithImpl;
@useResult
$Res call({
 String title, String? link, List<ResolvedBullet> bullets
});




}
/// @nodoc
class _$ResolvedProjectCopyWithImpl<$Res>
    implements $ResolvedProjectCopyWith<$Res> {
  _$ResolvedProjectCopyWithImpl(this._self, this._then);

  final ResolvedProject _self;
  final $Res Function(ResolvedProject) _then;

/// Create a copy of ResolvedProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? link = freezed,Object? bullets = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedProject].
extension ResolvedProjectPatterns on ResolvedProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedProject value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedProject value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? link,  List<ResolvedBullet> bullets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedProject() when $default != null:
return $default(_that.title,_that.link,_that.bullets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? link,  List<ResolvedBullet> bullets)  $default,) {final _that = this;
switch (_that) {
case _ResolvedProject():
return $default(_that.title,_that.link,_that.bullets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? link,  List<ResolvedBullet> bullets)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedProject() when $default != null:
return $default(_that.title,_that.link,_that.bullets);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedProject implements ResolvedProject {
  const _ResolvedProject({required this.title, this.link, final  List<ResolvedBullet> bullets = const <ResolvedBullet>[]}): _bullets = bullets;
  

@override final  String title;
@override final  String? link;
 final  List<ResolvedBullet> _bullets;
@override@JsonKey() List<ResolvedBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}


/// Create a copy of ResolvedProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedProjectCopyWith<_ResolvedProject> get copyWith => __$ResolvedProjectCopyWithImpl<_ResolvedProject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedProject&&(identical(other.title, title) || other.title == title)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other._bullets, _bullets));
}


@override
int get hashCode => Object.hash(runtimeType,title,link,const DeepCollectionEquality().hash(_bullets));

@override
String toString() {
  return 'ResolvedProject(title: $title, link: $link, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class _$ResolvedProjectCopyWith<$Res> implements $ResolvedProjectCopyWith<$Res> {
  factory _$ResolvedProjectCopyWith(_ResolvedProject value, $Res Function(_ResolvedProject) _then) = __$ResolvedProjectCopyWithImpl;
@override @useResult
$Res call({
 String title, String? link, List<ResolvedBullet> bullets
});




}
/// @nodoc
class __$ResolvedProjectCopyWithImpl<$Res>
    implements _$ResolvedProjectCopyWith<$Res> {
  __$ResolvedProjectCopyWithImpl(this._self, this._then);

  final _ResolvedProject _self;
  final $Res Function(_ResolvedProject) _then;

/// Create a copy of ResolvedProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? link = freezed,Object? bullets = null,}) {
  return _then(_ResolvedProject(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
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
mixin _$ResolvedPublication {

 String get title; String? get citation; String? get link; List<ResolvedBullet> get bullets;
/// Create a copy of ResolvedPublication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedPublicationCopyWith<ResolvedPublication> get copyWith => _$ResolvedPublicationCopyWithImpl<ResolvedPublication>(this as ResolvedPublication, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedPublication&&(identical(other.title, title) || other.title == title)&&(identical(other.citation, citation) || other.citation == citation)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other.bullets, bullets));
}


@override
int get hashCode => Object.hash(runtimeType,title,citation,link,const DeepCollectionEquality().hash(bullets));

@override
String toString() {
  return 'ResolvedPublication(title: $title, citation: $citation, link: $link, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class $ResolvedPublicationCopyWith<$Res>  {
  factory $ResolvedPublicationCopyWith(ResolvedPublication value, $Res Function(ResolvedPublication) _then) = _$ResolvedPublicationCopyWithImpl;
@useResult
$Res call({
 String title, String? citation, String? link, List<ResolvedBullet> bullets
});




}
/// @nodoc
class _$ResolvedPublicationCopyWithImpl<$Res>
    implements $ResolvedPublicationCopyWith<$Res> {
  _$ResolvedPublicationCopyWithImpl(this._self, this._then);

  final ResolvedPublication _self;
  final $Res Function(ResolvedPublication) _then;

/// Create a copy of ResolvedPublication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? citation = freezed,Object? link = freezed,Object? bullets = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,citation: freezed == citation ? _self.citation : citation // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedPublication].
extension ResolvedPublicationPatterns on ResolvedPublication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedPublication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedPublication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedPublication value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedPublication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedPublication value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedPublication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? citation,  String? link,  List<ResolvedBullet> bullets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedPublication() when $default != null:
return $default(_that.title,_that.citation,_that.link,_that.bullets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? citation,  String? link,  List<ResolvedBullet> bullets)  $default,) {final _that = this;
switch (_that) {
case _ResolvedPublication():
return $default(_that.title,_that.citation,_that.link,_that.bullets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? citation,  String? link,  List<ResolvedBullet> bullets)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedPublication() when $default != null:
return $default(_that.title,_that.citation,_that.link,_that.bullets);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedPublication implements ResolvedPublication {
  const _ResolvedPublication({required this.title, this.citation, this.link, final  List<ResolvedBullet> bullets = const <ResolvedBullet>[]}): _bullets = bullets;
  

@override final  String title;
@override final  String? citation;
@override final  String? link;
 final  List<ResolvedBullet> _bullets;
@override@JsonKey() List<ResolvedBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}


/// Create a copy of ResolvedPublication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedPublicationCopyWith<_ResolvedPublication> get copyWith => __$ResolvedPublicationCopyWithImpl<_ResolvedPublication>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedPublication&&(identical(other.title, title) || other.title == title)&&(identical(other.citation, citation) || other.citation == citation)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other._bullets, _bullets));
}


@override
int get hashCode => Object.hash(runtimeType,title,citation,link,const DeepCollectionEquality().hash(_bullets));

@override
String toString() {
  return 'ResolvedPublication(title: $title, citation: $citation, link: $link, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class _$ResolvedPublicationCopyWith<$Res> implements $ResolvedPublicationCopyWith<$Res> {
  factory _$ResolvedPublicationCopyWith(_ResolvedPublication value, $Res Function(_ResolvedPublication) _then) = __$ResolvedPublicationCopyWithImpl;
@override @useResult
$Res call({
 String title, String? citation, String? link, List<ResolvedBullet> bullets
});




}
/// @nodoc
class __$ResolvedPublicationCopyWithImpl<$Res>
    implements _$ResolvedPublicationCopyWith<$Res> {
  __$ResolvedPublicationCopyWithImpl(this._self, this._then);

  final _ResolvedPublication _self;
  final $Res Function(_ResolvedPublication) _then;

/// Create a copy of ResolvedPublication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? citation = freezed,Object? link = freezed,Object? bullets = null,}) {
  return _then(_ResolvedPublication(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,citation: freezed == citation ? _self.citation : citation // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
  ));
}


}

/// @nodoc
mixin _$ResolvedQualification {

 String get qualification; String get institution; String? get location;/// Pre-formatted (e.g. "2021"), not a raw int — same reasoning as
/// [ResolvedPosition.dateRange].
 String? get yearLabel; String? get grade; String? get details; List<ResolvedBullet> get bullets;
/// Create a copy of ResolvedQualification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedQualificationCopyWith<ResolvedQualification> get copyWith => _$ResolvedQualificationCopyWithImpl<ResolvedQualification>(this as ResolvedQualification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedQualification&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.location, location) || other.location == location)&&(identical(other.yearLabel, yearLabel) || other.yearLabel == yearLabel)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.bullets, bullets));
}


@override
int get hashCode => Object.hash(runtimeType,qualification,institution,location,yearLabel,grade,details,const DeepCollectionEquality().hash(bullets));

@override
String toString() {
  return 'ResolvedQualification(qualification: $qualification, institution: $institution, location: $location, yearLabel: $yearLabel, grade: $grade, details: $details, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class $ResolvedQualificationCopyWith<$Res>  {
  factory $ResolvedQualificationCopyWith(ResolvedQualification value, $Res Function(ResolvedQualification) _then) = _$ResolvedQualificationCopyWithImpl;
@useResult
$Res call({
 String qualification, String institution, String? location, String? yearLabel, String? grade, String? details, List<ResolvedBullet> bullets
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
@pragma('vm:prefer-inline') @override $Res call({Object? qualification = null,Object? institution = null,Object? location = freezed,Object? yearLabel = freezed,Object? grade = freezed,Object? details = freezed,Object? bullets = null,}) {
  return _then(_self.copyWith(
qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String,institution: null == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,yearLabel: freezed == yearLabel ? _self.yearLabel : yearLabel // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String qualification,  String institution,  String? location,  String? yearLabel,  String? grade,  String? details,  List<ResolvedBullet> bullets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedQualification() when $default != null:
return $default(_that.qualification,_that.institution,_that.location,_that.yearLabel,_that.grade,_that.details,_that.bullets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String qualification,  String institution,  String? location,  String? yearLabel,  String? grade,  String? details,  List<ResolvedBullet> bullets)  $default,) {final _that = this;
switch (_that) {
case _ResolvedQualification():
return $default(_that.qualification,_that.institution,_that.location,_that.yearLabel,_that.grade,_that.details,_that.bullets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String qualification,  String institution,  String? location,  String? yearLabel,  String? grade,  String? details,  List<ResolvedBullet> bullets)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedQualification() when $default != null:
return $default(_that.qualification,_that.institution,_that.location,_that.yearLabel,_that.grade,_that.details,_that.bullets);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedQualification implements ResolvedQualification {
  const _ResolvedQualification({required this.qualification, required this.institution, this.location, this.yearLabel, this.grade, this.details, final  List<ResolvedBullet> bullets = const <ResolvedBullet>[]}): _bullets = bullets;
  

@override final  String qualification;
@override final  String institution;
@override final  String? location;
/// Pre-formatted (e.g. "2021"), not a raw int — same reasoning as
/// [ResolvedPosition.dateRange].
@override final  String? yearLabel;
@override final  String? grade;
@override final  String? details;
 final  List<ResolvedBullet> _bullets;
@override@JsonKey() List<ResolvedBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}


/// Create a copy of ResolvedQualification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedQualificationCopyWith<_ResolvedQualification> get copyWith => __$ResolvedQualificationCopyWithImpl<_ResolvedQualification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedQualification&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.location, location) || other.location == location)&&(identical(other.yearLabel, yearLabel) || other.yearLabel == yearLabel)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other._bullets, _bullets));
}


@override
int get hashCode => Object.hash(runtimeType,qualification,institution,location,yearLabel,grade,details,const DeepCollectionEquality().hash(_bullets));

@override
String toString() {
  return 'ResolvedQualification(qualification: $qualification, institution: $institution, location: $location, yearLabel: $yearLabel, grade: $grade, details: $details, bullets: $bullets)';
}


}

/// @nodoc
abstract mixin class _$ResolvedQualificationCopyWith<$Res> implements $ResolvedQualificationCopyWith<$Res> {
  factory _$ResolvedQualificationCopyWith(_ResolvedQualification value, $Res Function(_ResolvedQualification) _then) = __$ResolvedQualificationCopyWithImpl;
@override @useResult
$Res call({
 String qualification, String institution, String? location, String? yearLabel, String? grade, String? details, List<ResolvedBullet> bullets
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
@override @pragma('vm:prefer-inline') $Res call({Object? qualification = null,Object? institution = null,Object? location = freezed,Object? yearLabel = freezed,Object? grade = freezed,Object? details = freezed,Object? bullets = null,}) {
  return _then(_ResolvedQualification(
qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String,institution: null == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,yearLabel: freezed == yearLabel ? _self.yearLabel : yearLabel // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResolvedBullet>,
  ));
}


}

// dart format on
