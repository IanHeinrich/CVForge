import 'package:freezed_annotation/freezed_annotation.dart';

part 'hobby_item.freezed.dart';
part 'hobby_item.g.dart';

@freezed
abstract class HobbyItem with _$HobbyItem {
  const factory HobbyItem({required String id, required String text}) =
      _HobbyItem;

  factory HobbyItem.fromJson(Map<String, dynamic> json) =>
      _$HobbyItemFromJson(json);
}
