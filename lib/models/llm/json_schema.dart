import 'package:freezed_annotation/freezed_annotation.dart';

part 'json_schema.freezed.dart';

/// A provider-agnostic JSON Schema, restricted on purpose to the
/// intersection every structured-output-capable provider's dialect
/// supports: object/array/string/number/boolean, `required`, and a
/// string `enum` — see plan.md's LLM provider and Copilot design notes for
/// why staying inside that intersection matters (an enum of real ids is
/// what makes a hallucinated
/// reference structurally impossible, and that trick has to survive
/// translation into whichever provider's dialect is calling
/// [LlmProvider.completeJson]). An [LlmProvider] adapter walks this tree
/// into its own wire format; nothing outside an adapter should need to
/// know what that wire format looks like.
///
/// [JsonSchema.object]'s `additionalProperties: false` is not a field
/// here — every adapter must emit it unconditionally for every object
/// node, per the same intersection reasoning, so there is nothing for a
/// caller to get wrong by omission.
@freezed
sealed class JsonSchema with _$JsonSchema {
  const factory JsonSchema.object({
    required Map<String, JsonSchema> properties,
    required List<String> required,
  }) = JsonSchemaObject;

  const factory JsonSchema.array({required JsonSchema items}) = JsonSchemaArray;

  const factory JsonSchema.string() = JsonSchemaString;

  const factory JsonSchema.stringEnum(List<String> values) =
      JsonSchemaStringEnum;

  const factory JsonSchema.number() = JsonSchemaNumber;

  const factory JsonSchema.boolean() = JsonSchemaBoolean;
}
