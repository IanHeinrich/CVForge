import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

/// The Vault content actually sent to an [LlmProvider] for a tailoring
/// pass — everything the model needs to select and rewrite bullets, and
/// nothing else. [ContactBasics]' identifying fields (full name, email,
/// phone, location, profile links) are deliberately never carried onto
/// this type: they contribute nothing to selecting or rewriting a bullet,
/// they're the most sensitive thing in the Vault, and building the
/// pre-send confirm off this type rather than the raw [CvVault] is what
/// keeps that confirm's claim ("your CV content, not your identity, is
/// sent") actually true instead of aspirational.
///
/// Not a `@freezed` domain model — this is a one-directional transform
/// into an outbound request body, not app state, so a hand-written
/// [toJson] is enough (mirrors how [LlmProvider] implementations
/// hand-build their own request maps rather than serializing a typed
/// model).
class AiAssistantVaultPayload {
  const AiAssistantVaultPayload._(this._json);

  factory AiAssistantVaultPayload.from(CvVault vault) {
    return AiAssistantVaultPayload._({
      if (vault.basics.headline.isNotEmpty) 'headline': vault.basics.headline,
      if (vault.basics.summary != null && vault.basics.summary!.isNotEmpty)
        'summary': vault.basics.summary,
      'experiences': [
        for (final e in vault.experiences)
          {
            'id': e.id,
            'role': e.role,
            'company': e.company,
            'location': e.location,
            // Pinned to English, and not the draft's own document
            // language. Everything in a prompt is English by policy —
            // the model is instructed in English, and translating what it
            // reads changes how it behaves — so these dates stay English
            // even when the CV they describe will be printed in German.
            // See CLAUDE.md's list of what is deliberately not localized.
            'start': e.start.toMonYyyy(DocumentLanguage.enGb),
            if (e.end != null) 'end': e.end!.toMonYyyy(DocumentLanguage.enGb),
            'isCurrent': e.isCurrent,
            'bullets': [
              for (final b in e.bullets) {'id': b.id, 'text': b.text},
            ],
          },
      ],
      'projects': [
        for (final p in vault.projects)
          {
            'id': p.id,
            'title': p.title,
            'bullets': [
              for (final b in p.bullets) {'id': b.id, 'text': b.text},
            ],
          },
      ],
      'skillCategories': [
        for (final c in vault.skillCategories)
          {
            'name': c.name,
            'skills': [
              for (final s in c.skills)
                {
                  'id': s.id,
                  'label': s.label,
                  // Bullets this skill is already evidenced by — see
                  // `aiAssistantSystemPrompt`'s guidance on how this should
                  // factor into selection. Omitted rather than sent as
                  // `[]` for a skill with no links.
                  if (s.linkedBulletIds.isNotEmpty)
                    'linkedBulletIds': s.linkedBulletIds,
                },
            ],
          },
      ],
      'education': [
        for (final ed in vault.education)
          {
            'id': ed.id,
            'qualification': ed.qualification,
            'institution': ed.institution,
            if (ed.year != null) 'year': ed.year,
            if (ed.grade != null) 'grade': ed.grade,
            if (ed.details != null) 'details': ed.details,
            'bullets': [
              for (final b in ed.bullets) {'id': b.id, 'text': b.text},
            ],
          },
      ],
      'hobbies': [
        for (final h in vault.hobbies) {'id': h.id, 'text': h.text},
      ],
      'publications': [
        for (final p in vault.publications)
          {
            'id': p.id,
            'title': p.title,
            if (p.citation != null) 'citation': p.citation,
            'bullets': [
              for (final b in p.bullets) {'id': b.id, 'text': b.text},
            ],
          },
      ],
    });
  }

  final Map<String, dynamic> _json;

  Map<String, dynamic> toJson() => _json;
}
