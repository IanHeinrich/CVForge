/// The Vault entity type a bullet list belongs to. Shared between
/// [VaultService]'s bullet CRUD and [DraftService]'s per-bullet draft
/// selection, both of which support all four.
///
/// Education was the odd one out until `CvDraft.educationBulletIds`
/// existed: its bullets printed wholesale, which meant they could not be
/// deselected, and — since the editor had no rows for them — could not be
/// reworded either, while the composer rendered and the translation pass
/// translated every one. See that field for the one way it still differs,
/// which is only about drafts saved before it existed.
enum BulletOwner { experience, project, education, publication }
