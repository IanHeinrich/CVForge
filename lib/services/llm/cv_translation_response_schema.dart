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
/// **Every key is `required`, at both levels, and that is the whole
/// mechanism.** An optional key is one the model may decline to fill, and
/// given a request of twenty optional strings it will routinely fill only
/// some — which is exactly what a translation pass must not do. The
/// symptom was a first pass that translated part of a CV and a second
/// pass that finished the job: nothing was failing, the model was simply
/// answering as much of an optional request as it felt like.
///
/// The old objection to requiring keys was that it forces a translation
/// for a term that should keep its name. It doesn't: the prompt asks for
/// the term back **unchanged**, which is a correct answer rather than an
/// invented one, and a value that comes back identical to what was sent
/// is not counted as translated (see
/// [CvTranslationResult.translatedCount]). What it costs is a few echoed
/// output tokens; what it buys is a pass that answers all of what it was
/// asked.
JsonSchema buildCvTranslationResponseSchema(CvTranslationPayload payload) {
  final request = payload.toJson();

  /// The response half of one id-keyed request group: the same ids, each
  /// mapping to its translation.
  JsonSchema? group(String key) {
    final value = request[key];
    if (value is! Map<String, dynamic> || value.isEmpty) return null;
    return JsonSchema.object(
      properties: {for (final id in value.keys) id: const JsonSchema.string()},
      required: value.keys.toList(),
    );
  }

  final properties = <String, JsonSchema>{
    if (request.containsKey('headline')) 'headline': const JsonSchema.string(),
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
  };

  return JsonSchema.object(
    properties: properties,
    required: properties.keys.toList(),
  );
}
