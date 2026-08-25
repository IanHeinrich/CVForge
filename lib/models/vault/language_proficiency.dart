/// How well someone speaks a language, on the Common European Framework
/// of Reference scale, plus a native band the scale itself doesn't have.
///
/// CEFR because it is the scale European employers already read, and the
/// one Europass prints — a self-invented "fluent / good / basic" ladder
/// means something different to every reader. It also costs almost nothing
/// to translate: a band's name is the same in every language, so only
/// [native] needs a word per document language. `CvComposer` is where that
/// formatting happens, alongside the date formatting, for the same reason.
///
/// The names are the persistence contract — stored by `.name` on
/// [LanguageItem] — and must never be renamed. Ordered strongest first,
/// which is the order a picker should offer them in.
enum LanguageProficiency { native, c2, c1, b2, b1, a2, a1 }
