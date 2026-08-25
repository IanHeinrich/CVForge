import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

/// Builds the per-request [JsonSchema] an AI Assistant tailoring pass must answer
/// in, generated fresh from [vault] on every call so every id referenced
/// anywhere in the schema is one this exact Vault actually has. It's an
/// id-keyed object rather than an array so that's legal under
/// `additionalProperties: false`.
///
/// `headline`/`summary` are deliberately left out of the top-level
/// `required` list rather than modelled as nullable — [JsonSchema] has no
/// null type (see its own doc comment on staying inside every provider's
/// dialect intersection), so "the model chose not to rewrite this" is
/// expressed as "the key is simply absent from the response", which is
/// exactly [AiAssistantResult]'s null-means-inherit reading of them anyway.
JsonSchema buildAiAssistantResponseSchema(CvVault vault) {
  return JsonSchema.object(
    properties: {
      'headline': const JsonSchema.string(),
      'summary': const JsonSchema.string(),
      'experiences': JsonSchema.object(
        properties: {
          for (final e in vault.experiences)
            e.id: _entryBulletsSchema(e.bullets.map((b) => b.id).toList()),
        },
        // Nothing is required here — an experience id simply not present
        // as a key means "not selected", the same reading as every other
        // opt-in id list in `CvDraft`.
        required: const [],
      ),
      'projects': JsonSchema.object(
        properties: {
          for (final p in vault.projects)
            p.id: _entryBulletsSchema(p.bullets.map((b) => b.id).toList()),
        },
        required: const [],
      ),
      'skillIds': JsonSchema.array(
        items: JsonSchema.stringEnum([
          for (final c in vault.skillCategories)
            for (final s in c.skills) s.id,
        ]),
      ),
      // Same key-presence-means-selected shape as experiences/projects/
      // publications, rather than the flat id list this used to be: an
      // education entry's bullets are as selectable and as rewritable as
      // any other entry's, and four identical shapes is a pattern the
      // model follows more reliably than three plus a special case.
      'education': JsonSchema.object(
        properties: {
          for (final e in vault.education)
            e.id: _entryBulletsSchema(e.bullets.map((b) => b.id).toList()),
        },
        required: const [],
      ),
      'hobbyIds': JsonSchema.array(
        items: JsonSchema.stringEnum([for (final h in vault.hobbies) h.id]),
      ),
      'publications': JsonSchema.object(
        properties: {
          for (final p in vault.publications)
            p.id: _entryBulletsSchema(p.bullets.map((b) => b.id).toList()),
        },
        required: const [],
      ),
      'hiddenSections': JsonSchema.array(
        items: JsonSchema.stringEnum([
          for (final s in CvSectionType.values) s.name,
        ]),
      ),
      'rationale': const JsonSchema.string(),
      'keywordGaps': const JsonSchema.array(items: JsonSchema.string()),
    },
    required: const [
      'experiences',
      'projects',
      'skillIds',
      'education',
      'hobbyIds',
      'publications',
      'hiddenSections',
      'rationale',
      'keywordGaps',
    ],
  );
}

/// Shared by every entity entry: which of *this* entry's own
/// bullets are selected, plus optional rewrites of them. Scoping the enum
/// to [bulletIds] (rather than one flat enum of every bullet id in the
/// Vault) is what makes it structurally impossible for the model to
/// attach one experience's bullet to another.
JsonSchema _entryBulletsSchema(List<String> bulletIds) => JsonSchema.object(
  properties: {
    'bulletIds': JsonSchema.array(items: JsonSchema.stringEnum(bulletIds)),
    'rewrites': JsonSchema.array(
      items: JsonSchema.object(
        properties: {
          'id': JsonSchema.stringEnum(bulletIds),
          'text': const JsonSchema.string(),
        },
        required: const ['id', 'text'],
      ),
    ),
  },
  required: const ['bulletIds', 'rewrites'],
);
