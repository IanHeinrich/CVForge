import 'package:cv_forge/models/llm/cv_translation_payload.dart';
import 'package:cv_forge/models/llm/json_schema.dart';

/// Builds the [JsonSchema] a translation pass must answer in, generated
/// fresh from [payload] on every call so every id in every enum is one
/// this exact request actually asked about.
///
/// The response mirrors the request key for key: an id-keyed object per
/// field group, legal under `additionalProperties: false` because the
/// property set is closed to the ids we sent. Scoping each enum to the
/// ids in that group — rather than one flat enum of every id in the Vault
/// — is what makes it structurally impossible for a translated role to
/// land on an education entry, the same guarantee
/// `buildAiAssistantResponseSchema` gets from its per-entry bullet enums.
///
/// **Nothing is `required`, at any level, and that is the whole
/// mechanism.** [JsonSchema] has no null type (see its own doc comment on
/// staying inside every provider's dialect intersection), so "leave this
/// one alone — it is already in the target language, or it is a product
/// name that should not be translated" can only be expressed as *the key
/// is absent*. Requiring a key would force the model to invent a
/// translation for a term that should have kept its name.
JsonSchema buildCvTranslationResponseSchema(CvTranslationPayload payload) {
  final request = payload.toJson();

  /// The response half of one id-keyed request group: the same ids, each
  /// mapping to its translation.
  JsonSchema? group(String key) {
    final value = request[key];
    if (value is! Map<String, dynamic> || value.isEmpty) return null;
    return JsonSchema.object(
      properties: {for (final id in value.keys) id: const JsonSchema.string()},
      required: const [],
    );
  }

  return JsonSchema.object(
    properties: {
      if (request.containsKey('headline'))
        'headline': const JsonSchema.string(),
      if (request.containsKey('summary')) 'summary': const JsonSchema.string(),
      if (request.containsKey('referencesNote'))
        'referencesNote': const JsonSchema.string(),
      for (final key in const [
        'roles',
        'projectTitles',
        'skillCategories',
        'skills',
        'qualifications',
        'grades',
        'educationDetails',
        'hobbies',
        'bullets',
      ])
        key: ?group(key),
    },
    required: const [],
  );
}
