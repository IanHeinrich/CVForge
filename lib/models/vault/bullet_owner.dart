/// The Vault entity type a bullet list belongs to. Shared between
/// [VaultService]'s bullet CRUD, which supports all four owners, and
/// [DraftService]'s per-bullet draft selection, which supports only
/// [experience], [project], and [publication] — `CvDraft` has no
/// education equivalent of `bulletIds`/`projectBulletIds`/
/// `publicationBulletIds`, since education bullets are shown wholesale
/// rather than individually selectable.
enum BulletOwner { experience, project, education, publication }
