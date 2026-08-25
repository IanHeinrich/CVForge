// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get analyzerAnalyzingBody =>
      'Leyendo el PDF y buscando problemas de interpretación para los ATS.';

  @override
  String get analyzerAnalyzingTitle => 'Analizando…';

  @override
  String get analyzerErrorEngineLoad =>
      'No se pudo cargar el motor de PDF — revisa tu conexión e intenta de nuevo.';

  @override
  String get analyzerErrorGeneric =>
      'No se pudo analizar ese archivo — intenta de nuevo.';

  @override
  String get analyzerErrorInteractiveForm =>
      'Este es un formulario PDF interactivo, que funciona de forma distinta a un currículum normal y no se puede analizar igual.';

  @override
  String get analyzerErrorInvalidPdf =>
      'Ese archivo no parece un PDF válido, o está protegido con contraseña.';

  @override
  String get analyzerErrorTitle => 'No se pudo analizar ese archivo';

  @override
  String analyzerFindingLocationsAcrossPages(int count, int pages) {
    return '$count ubicaciones en $pages páginas';
  }

  @override
  String analyzerFindingLocationsOnPage(int count, int page) {
    return '$count ubicaciones en la página $page';
  }

  @override
  String analyzerFindingStepOf(int index, int total) {
    return '$index de $total';
  }

  @override
  String get analyzerMachineEmptyBody =>
      'Este PDF no produjo ningún bloque de texto extraíble.';

  @override
  String get analyzerMachineEmptyTitle => 'No se extrajo texto';

  @override
  String analyzerPageLabel(int page) {
    return 'Página $page';
  }

  @override
  String get analyzerResultsAnalyzeAnother => 'Analizar otro archivo';

  @override
  String analyzerResultsExtractionSummary(int pages, int runs) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages páginas',
      one: '1 página',
    );
    String _temp1 = intl.Intl.pluralLogic(
      runs,
      locale: localeName,
      other: '$runs bloques de texto extraídos',
      one: '1 bloque de texto extraído',
    );
    return '$_temp0, $_temp1.';
  }

  @override
  String get analyzerResultsTitle => 'Resultados';

  @override
  String get analyzerTabMachineIngestion => 'Lectura automática';

  @override
  String get analyzerTabXray => 'Radiografía';

  @override
  String analyzerUploadBody(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv':
          'Sube un CV en PDF para detectar formatos que los sistemas de seguimiento de candidatos suelen leer mal',
      'resume':
          'Sube un currículum en PDF para detectar formatos que los sistemas de seguimiento de candidatos suelen leer mal',
      'other':
          'Sube un documento en PDF para detectar formatos que los sistemas de seguimiento de candidatos suelen leer mal',
    });
    return '$_temp0 — falta de capa de texto, diseños en varias columnas, caracteres corruptos y más. Nada sale de tu navegador.';
  }

  @override
  String get analyzerUploadCta => 'Subir PDF';

  @override
  String analyzerUploadTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Revisa tu CV en busca de problemas con los ATS',
      'resume': 'Revisa tu currículum en busca de problemas con los ATS',
      'other': 'Revisa tu documento en busca de problemas con los ATS',
    });
    return '$_temp0';
  }

  @override
  String get analyzerXrayDocumentLevel => 'A nivel de documento';

  @override
  String get analyzerXrayEmptyBody => 'Analiza un PDF para ver su radiografía.';

  @override
  String get analyzerXrayEmptyTitle => 'Aún no hay nada que mostrar';

  @override
  String get analyzerXrayFindings => 'Hallazgos';

  @override
  String get analyzerXrayNoIssuesBody =>
      'Nada en este PDF coincide con un problema conocido de interpretación para los ATS.';

  @override
  String get analyzerXrayNoIssuesTitle => 'No se encontraron problemas';

  @override
  String get analyzerXrayPageEmptyBody =>
      'No hay bloques de texto extraíbles sobre los que dibujar recuadros.';

  @override
  String get analyzerXrayPageEmptyTitle =>
      'No hay nada que mostrar en esta página';

  @override
  String analyzerXrayPageOf(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String get analyzerXrayPageTab => 'Página';

  @override
  String get analyzerXrayReadingOrder => 'Orden de lectura';

  @override
  String get appNavAnalyzer => 'Revisión ATS';

  @override
  String appNavDrafts(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'CV',
      'resume': 'Currículums',
      'other': 'Documentos',
    });
    return '$_temp0';
  }

  @override
  String get appNavSettings => 'Configuración';

  @override
  String get appNavVault => 'Bóveda';

  @override
  String atsFindingColumnCrushBody(String left, String right, String merged) {
    return '\"$left\" y \"$right\" están en la misma línea con un espacio ancho entre ellos. Un extractor de texto que lea por posición en lugar de por la estructura del documento podría fusionarlos en un solo bloque, p. ej. \"$merged\".';
  }

  @override
  String get atsFindingColumnCrushTitle => 'Posible diseño en varias columnas';

  @override
  String atsFindingDroppedCharsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se encontraron $count bloques cortos que ocupan más espacio del que justifican los caracteres extraídos',
      one:
          'Se encontró 1 bloque corto que ocupa más espacio del que justifican los caracteres extraídos',
    );
    return '$_temp0 — señal de que algún símbolo (a menudo una viñeta) no llegó a extraerse.';
  }

  @override
  String get atsFindingDroppedCharsTitle => 'Posibles caracteres perdidos';

  @override
  String atsFindingGarbledBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se encontraron $count caracteres que no se pudieron descodificar como texto legible',
      one:
          'Se encontró 1 carácter que no se pudo descodificar como texto legible',
    );
    return '$_temp0 — probablemente la tipografía usada tiene un mapa de caracteres roto o incompleto. Un ATS verá este texto como basura.';
  }

  @override
  String get atsFindingGarbledTitle => 'Se encontraron caracteres ilegibles';

  @override
  String atsFindingIconFontBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se encontraron $count caracteres de un rango de uso privado',
      one: 'Se encontró 1 carácter de un rango de uso privado',
    );
    return '$_temp0 incrustados dentro de las palabras — una señal habitual de una tipografía de iconos o símbolos (p. ej. Wingdings) en lugar de texto real, que la mayoría de los ATS mostrarán como espacios en blanco o galimatías.';
  }

  @override
  String get atsFindingIconFontTitle =>
      'Posibles glifos de una tipografía de iconos en el texto';

  @override
  String atsFindingMissingHeadingBody(String section) {
    String _temp0 = intl.Intl.selectLogic(section, {
      'experience':
          'No se encontró ningún encabezado de experiencia en el documento.',
      'education':
          'No se encontró ningún encabezado de formación académica en el documento.',
      'skills':
          'No se encontró ningún encabezado de habilidades en el documento.',
      'other': 'No se encontró ningún encabezado de $section en el documento.',
    });
    return '$_temp0 Algunos sistemas ATS estructuran un currículum buscando los encabezados de sección habituales, y pueden archivar este contenido como texto sin estructura si falta el encabezado o está redactado de forma poco común.';
  }

  @override
  String atsFindingMissingHeadingTitle(String section) {
    String _temp0 = intl.Intl.selectLogic(section, {
      'experience': 'No se detectó una sección de experiencia',
      'education': 'No se detectó una sección de formación académica',
      'skills': 'No se detectó una sección de habilidades',
      'other': 'No se detectó una sección de $section',
    });
    return '$_temp0';
  }

  @override
  String get atsFindingNoEmailBody =>
      'No se encontró ninguna dirección de correo en el texto extraído ni en ningún enlace. La mayoría de los sistemas ATS necesitan una dirección de correo legible para registrar una postulación.';

  @override
  String get atsFindingNoEmailTitle =>
      'No se encontró ninguna dirección de correo';

  @override
  String get atsFindingNonEmbeddedFontBody =>
      'Este PDF depende de al menos una tipografía que no está incrustada en el archivo. Junto con el texto ilegible detectado arriba, es una causa probable.';

  @override
  String get atsFindingNonEmbeddedFontTitle =>
      'Se usa una tipografía no incrustada';

  @override
  String get atsFindingNoPhoneBody =>
      'No se encontró ningún número de teléfono en el texto extraído ni en ningún enlace.';

  @override
  String get atsFindingNoPhoneTitle =>
      'No se encontró ningún número de teléfono';

  @override
  String get atsFindingNoTextLayerBody =>
      'Este PDF no tiene ninguna capa de texto — probablemente es una imagen escaneada. La mayoría de los sistemas ATS lo leerán como un currículum completamente en blanco.';

  @override
  String get atsFindingNoTextLayerTitle => 'No se encontró texto extraíble';

  @override
  String atsFindingPageNoTextBody(int page) {
    return 'La página $page no aportó nada de texto, mientras que otras páginas sí — es probable que un ATS se la salte por completo.';
  }

  @override
  String atsFindingPageNoTextTitle(int page) {
    return 'La página $page no tiene texto extraíble';
  }

  @override
  String get chromeStorageUnavailableBody =>
      'El almacenamiento local no está disponible en este navegador o en este modo de navegación. CVForge guarda todo en tu dispositivo, así que necesita acceso para funcionar. Prueba con una ventana normal (no privada) o con otro navegador.';

  @override
  String get chromeStorageUnavailableTitle =>
      'CVForge no pudo cargar tus datos';

  @override
  String get commonAdd => 'Agregar';

  @override
  String commonAddAll(int count) {
    return 'Agregar todo ($count)';
  }

  @override
  String get commonBeta => 'BETA';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClear => 'Borrar';

  @override
  String get commonClearSearch => 'Limpiar búsqueda';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCreate => 'Crear';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonDisconnect => 'Desconectar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonFormatBold => 'Negrita';

  @override
  String get commonFormatItalic => 'Cursiva';

  @override
  String commonLengthBudgetLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count caracteres',
      one: 'Queda 1 carácter',
    );
    return '$_temp0';
  }

  @override
  String get commonLengthBudgetOver =>
      'Demasiado largo para caber en una página';

  @override
  String commonVaultOriginal(String text) {
    return 'Baúl: $text';
  }

  @override
  String get commonMore => 'Más';

  @override
  String commonRelativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String commonRelativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String commonRelativeOnDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'dd/MM/yyyy',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'el $dateString';
  }

  @override
  String get commonRelativeUnderAnHour => 'hace < 1 hora';

  @override
  String get commonRelativeYesterday => 'ayer';

  @override
  String get commonRemove => 'Quitar';

  @override
  String commonRemoveAll(int count) {
    return 'Quitar todo ($count)';
  }

  @override
  String get commonReplace => 'Reemplazar';

  @override
  String get commonReset => 'Restablecer';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonRun => 'Ejecutar';

  @override
  String get commonRunning => 'Ejecutando…';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSelect => 'Seleccionar';

  @override
  String get commonTryAgain => 'Intentar de nuevo';

  @override
  String get documentLanguageDaName => 'Dansk';

  @override
  String get documentLanguageDeAtName => 'Deutsch (Österreich)';

  @override
  String get documentLanguageDeName => 'Deutsch';

  @override
  String get documentLanguageEnAuName => 'English (Australia)';

  @override
  String get documentLanguageEnGbName => 'English (United Kingdom)';

  @override
  String get documentLanguageEnUsName => 'English (United States)';

  @override
  String get documentLanguageEs419Name => 'Español (Latinoamérica)';

  @override
  String get documentLanguageEsName => 'Español (España)';

  @override
  String get documentLanguageFiName => 'Suomi';

  @override
  String get documentLanguageFrCaName => 'Français (Canada)';

  @override
  String get documentLanguageFrName => 'Français';

  @override
  String get documentLanguageItName => 'Italiano';

  @override
  String get documentLanguageNbName => 'Norsk bokmål';

  @override
  String get documentLanguageNlName => 'Nederlands';

  @override
  String get documentLanguagePtBrName => 'Português (Brasil)';

  @override
  String get documentLanguagePtPtName => 'Português (Portugal)';

  @override
  String get documentLanguageSvName => 'Svenska';

  @override
  String draftCopySuffix(String name) {
    return '$name (copia)';
  }

  @override
  String get draftDefaultName => 'Mi CV';

  @override
  String get driveSyncAccountFallback => 'tu cuenta de Google';

  @override
  String get driveSyncErrorCorrupted =>
      'La copia en Drive parecía dañada. Este dispositivo quedó como estaba.';

  @override
  String get driveSyncErrorFileGone =>
      'Tu archivo de CVForge en Drive ya no existe. Al sincronizar de nuevo se volverá a crear.';

  @override
  String get driveSyncErrorNetwork =>
      'No se pudo conectar con Google Drive. Se guardó en este dispositivo.';

  @override
  String get driveSyncErrorNewerVersion =>
      'Otro dispositivo usa una versión más reciente de CVForge. Actualiza este dispositivo para volver a sincronizar.';

  @override
  String get driveSyncErrorUnknown =>
      'Algo salió mal al sincronizar con Drive. Se guardó en este dispositivo.';

  @override
  String get driveSyncMerged =>
      'Se combinaron los cambios de tu otro dispositivo';

  @override
  String get driveSyncNeedsReauth =>
      'Vuelve a conectar Google Drive en Configuración para seguir sincronizando';

  @override
  String get driveSyncPending => 'Esperando para sincronizar con Google Drive…';

  @override
  String get driveSyncSynced => 'Sincronizado con Google Drive';

  @override
  String driveSyncSyncedAt(String relative) {
    return 'Sincronizado con Google Drive · $relative';
  }

  @override
  String get driveSyncSyncing => 'Sincronizando con Google Drive…';

  @override
  String get localeDisplayName => 'Español';

  @override
  String get pageFormatA4 => 'A4 (210 × 297 mm)';

  @override
  String get pageFormatLetter => 'Carta EE. UU. (8,5 × 11 pulg)';

  @override
  String get personalDetailsMinimal => 'Nombre, contacto y ciudad';

  @override
  String get personalDetailsOmit => 'Solo nombre y datos de contacto';

  @override
  String get personalDetailsTraditional =>
      'Nombre, contacto, fecha de nacimiento y nacionalidad';

  @override
  String get photoStanceDiscouraged => 'No — se desaconseja firmemente';

  @override
  String get photoStanceExpected => 'Normalmente se espera';

  @override
  String get photoStanceOptional => 'Opcional';

  @override
  String get photoStanceProhibited => 'No — motivo de descarte automático';

  @override
  String get regionAnzConvention1 =>
      'Dos o tres páginas es lo normal y lo esperado. Un currículum de una sola página se percibe aquí como escaso.';

  @override
  String get regionAnzConvention2 =>
      'Sin fotografía, fecha de nacimiento ni estado civil.';

  @override
  String get regionAnzConvention3 =>
      'Indica tu situación laboral en el encabezado — \"Australian citizen\", \"NZ permanent resident\", \"482 visa\". El personal de selección filtra por esto primero.';

  @override
  String get regionAnzConvention4 =>
      'Incluye una sección específica de \"Referees\" con dos referencias nombradas, o indica que los datos están disponibles a solicitud.';

  @override
  String get regionAnzConvention5 =>
      'Si escribes en inglés, usa ortografía australiana: organised, centre, analyse. Sé coherente: algunos sectores aceptan -ize, pero lo que se nota es mezclar las dos.';

  @override
  String get regionAnzConvention6 =>
      'Da más contexto por puesto del que daría un currículum estadounidense: alcance de la empresa, a quién reportabas, tamaño del equipo, presupuesto.';

  @override
  String get regionAnzCoverage => 'Australia, Nueva Zelanda';

  @override
  String get regionAnzDisplayName => 'Australia y Nueva Zelanda';

  @override
  String get regionAnzLengthNote =>
      'Dos a tres páginas a media carrera; tres a cinco para puestos directivos.';

  @override
  String get regionAnzToneNote =>
      'Rico en contexto y concreto. Explica a qué se dedica la organización, el alcance de tu responsabilidad y luego el resultado — quienes leen en Australasia esperan más detalle de contexto del que da un currículum estadounidense.';

  @override
  String get regionDachConvention1 =>
      'Alrededor de dos tercios de los empleadores de habla alemana siguen esperando una foto profesional, arriba a la derecha. Súbela en la Bóveda y elige una plantilla que la incluya; las demás la omiten.';

  @override
  String get regionDachConvention2 =>
      'La fecha y el lugar de nacimiento, la nacionalidad y a veces el estado civil son tradicionales en el bloque de datos personales, y CVForge no tiene ningún campo para ellos. Los empleadores más jóvenes e internacionales los omiten cada vez más: omitirlos es seguro, incluirlos es lo convencional.';

  @override
  String get regionDachConvention3 =>
      'La cronología debe ser continua y precisa al mes. Un vacío sin explicar se percibe como ocultamiento; identifícalo con claridad (\"Licencia parental\", \"Formación continua\").';

  @override
  String get regionDachConvention4 =>
      'La formación académica sigue siendo prominente durante toda tu carrera, con la institución nombrada y las calificaciones indicadas.';

  @override
  String get regionDachConvention5 =>
      'Los certificados (Zeugnisse) se adjuntan como documento aparte; el Lebenslauf los menciona en lugar de reproducirlos.';

  @override
  String get regionDachConvention6 =>
      'Si escribes en inglés, usa ortografía británica.';

  @override
  String get regionDachCoverage => 'Alemania, Austria, Suiza';

  @override
  String get regionDachDisplayName => 'DACH';

  @override
  String get regionDachLengthNote =>
      'Dos o tres páginas, en formato tabular y completo.';

  @override
  String get regionDachToneNote =>
      'Formal, objetivo y completo. Mejor la contención que el argumento de venta, y los hechos verificables que los adjetivos.';

  @override
  String get regionEuropeConvention1 =>
      'Una o dos páginas. Francia en particular espera una sola página para menos de unos quince años de experiencia.';

  @override
  String get regionEuropeConvention2 =>
      'La fotografía es habitual en Francia, España, Italia y Portugal, e inusual en el resto. Para una postulación internacional o en una multinacional, omítela.';

  @override
  String get regionEuropeConvention3 =>
      'Mantén al mínimo los datos personales si postulas a una multinacional. Un empleador local francés o del sur de Europa puede seguir esperando fecha de nacimiento y nacionalidad.';

  @override
  String get regionEuropeConvention4 =>
      'Indica tu nivel de idiomas con los niveles del MCER (A1–C2). El personal de selección europeo los lee con precisión.';

  @override
  String get regionEuropeConvention5 =>
      'Los empleadores del sur de Europa toleran CV más largos — se ven de cuatro o cinco páginas — pero un documento más ajustado sigue leyéndose mejor.';

  @override
  String get regionEuropeConvention6 =>
      'Si escribes en inglés, usa ortografía británica. Para una postulación local, vale la pena preparar una versión en el idioma del país.';

  @override
  String get regionEuropeCoverage =>
      'Francia, Benelux, Europa del Sur y multinacionales';

  @override
  String get regionEuropeDisplayName => 'Europa — internacional';

  @override
  String get regionEuropeLengthNote =>
      'Una o dos páginas. Francia prefiere una; Europa del Sur admite más.';

  @override
  String get regionEuropeToneNote =>
      'Profesional y comedido. Resultados concretos, sin el registro comercial de un currículum estadounidense.';

  @override
  String get regionLatamA4Convention1 =>
      'El tamaño A4 es el estándar en Brasil, Argentina, Uruguay y Perú. Para México, Colombia, Chile o Centroamérica, elige \"México, Colombia y Chile\" — esos mercados usan tamaño Carta.';

  @override
  String get regionLatamA4Convention2 =>
      'El documento es un \"Currículo\" en Brasil y un \"Curriculum Vitae\" en el Cono Sur.';

  @override
  String get regionLatamA4Convention3 =>
      'La fotografía, la fecha de nacimiento, el estado civil y el número de identificación (CPF, DNI/CUIL) son habituales en las empresas locales, y se excluyen deliberadamente en las multinacionales y sus filiales. Guíate por el empleador, no por el país. CVForge incluye la fotografía cuando la plantilla la admite; no tiene campo para el resto.';

  @override
  String get regionLatamA4Convention4 => 'Dos o tres páginas es lo normal.';

  @override
  String get regionLatamA4Convention5 =>
      'La certificación de idiomas es un filtro de selección de primer orden, sobre todo en Brasil: indica tus puntajes de TOEFL, IELTS, DELE o CELPE-Bras con la fecha en que los obtuviste.';

  @override
  String get regionLatamA4Convention6 =>
      'Nombra la institución de cada título; la reputación de la universidad se lee con atención.';

  @override
  String get regionLatamA4Convention7 =>
      'Si escribes en inglés, la ortografía estadounidense es la norma regional.';

  @override
  String get regionLatamA4Coverage => 'Brasil, Argentina, Uruguay, Perú';

  @override
  String get regionLatamA4DisplayName => 'Brasil y Cono Sur';

  @override
  String get regionLatamA4LengthNote => 'Dos o tres páginas.';

  @override
  String get regionLatamA4ToneNote =>
      'Formal y con las credenciales por delante. Los títulos, las instituciones y las certificaciones pesan de verdad — indícalos por completo.';

  @override
  String get regionLatamLetterConvention1 =>
      'El tamaño Carta es el estándar en México, Colombia, Chile y Centroamérica. Para Brasil, Argentina, Uruguay o Perú, elige \"Brasil y Cono Sur\" — esos mercados usan A4.';

  @override
  String get regionLatamLetterConvention2 =>
      'El documento es una \"Hoja de Vida\" en Colombia y los países andinos, y un \"Currículum Vitae\" en México y Centroamérica.';

  @override
  String get regionLatamLetterConvention3 =>
      'La fotografía, la fecha de nacimiento, el estado civil y el número de identificación (CURP/RFC, Cédula) son habituales en las empresas locales, y se excluyen deliberadamente en las multinacionales y sus filiales. Guíate por el empleador, no por el país. CVForge incluye la fotografía cuando la plantilla la admite; no tiene campo para el resto.';

  @override
  String get regionLatamLetterConvention4 => 'Dos o tres páginas es lo normal.';

  @override
  String get regionLatamLetterConvention5 =>
      'La certificación de idiomas pesa de verdad: indica tus puntajes de TOEFL, IELTS o DELE con la fecha en que los obtuviste.';

  @override
  String get regionLatamLetterConvention6 =>
      'Nombra la institución de cada título; la reputación de la universidad se lee con atención.';

  @override
  String get regionLatamLetterConvention7 =>
      'Si escribes en inglés, la ortografía estadounidense es la norma regional.';

  @override
  String get regionLatamLetterCoverage =>
      'México, Colombia, Chile, Centroamérica';

  @override
  String get regionLatamLetterDisplayName => 'México, Colombia y Chile';

  @override
  String get regionLatamLetterLengthNote => 'Dos o tres páginas.';

  @override
  String get regionLatamLetterToneNote =>
      'Formal y con las credenciales por delante. Los títulos, las instituciones y las certificaciones pesan de verdad — indícalos por completo.';

  @override
  String get regionNordicsConvention1 =>
      'Una o dos páginas. Un CV largo se percibe como falta de criterio al editar.';

  @override
  String get regionNordicsConvention2 =>
      'La fotografía ni se espera ni se rechaza. Inclúyela solo si es realmente profesional.';

  @override
  String get regionNordicsConvention3 =>
      'Mantén al mínimo los datos personales: nombre, contacto, ciudad. Sin fecha de nacimiento, estado civil ni número de identificación.';

  @override
  String get regionNordicsConvention4 =>
      'Enmarca tus logros en torno al equipo y al resultado, más que a hazañas personales.';

  @override
  String get regionNordicsConvention5 =>
      'Indica explícitamente tu nivel de idiomas escandinavos (\"Sueco — B2\"). Marca la diferencia.';

  @override
  String get regionNordicsConvention6 =>
      'Los CV en inglés se aceptan ampliamente; si escribes en inglés, usa ortografía británica.';

  @override
  String get regionNordicsCoverage => 'Suecia, Noruega, Dinamarca, Finlandia';

  @override
  String get regionNordicsDisplayName => 'Países nórdicos';

  @override
  String get regionNordicsLengthNote =>
      'Una o dos páginas. Aquí la concisión se lee como una virtud.';

  @override
  String get regionNordicsToneNote =>
      'Objetivo y enmarcado en el equipo. Di qué logró el equipo y cuál fue tu parte en ello; el \"yo solo conseguí\" se percibe mal en toda la región nórdica.';

  @override
  String get regionUkConvention1 =>
      'Dos páginas es la norma. Una página para alguien recién egresado; tres solo para puestos académicos o de mucha antigüedad.';

  @override
  String get regionUkConvention2 =>
      'Sin fotografía, fecha de nacimiento, estado civil ni nacionalidad. La legislación británica de igualdad los convierte en un riesgo tanto para el empleador como para ti.';

  @override
  String get regionUkConvention3 =>
      'Si escribes en inglés, usa ortografía británica en todo el documento: organised, programme, centre, analyse.';

  @override
  String get regionUkConvention4 =>
      'Sigue esperándose un \"References available on request\" al pie. No incluyas los datos de contacto de tus referencias.';

  @override
  String get regionUkConvention5 =>
      'Abre con una breve declaración personal o perfil.';

  @override
  String get regionUkConvention6 =>
      'Irlanda sigue las mismas convenciones. Indica tu autorización de trabajo si no eres ciudadano de la UE o del Reino Unido.';

  @override
  String get regionUkCoverage => 'Reino Unido, Irlanda';

  @override
  String get regionUkDisplayName => 'Reino Unido e Irlanda';

  @override
  String get regionUkLengthNote =>
      'Dos páginas es lo estándar. Una página está bien para alguien recién egresado.';

  @override
  String get regionUkToneNote =>
      'Sobrio y objetivo. Expón tus logros con sencillez y con la evidencia que los respalda; la autopromoción explícita se percibe como presuntuosa.';

  @override
  String get regionUsConvention1 =>
      'Una página hasta unos diez años de experiencia, dos a partir de ahí. Tres páginas significa un CV académico, que es otro documento.';

  @override
  String get regionUsConvention2 =>
      'Nunca incluyas fotografía, fecha de nacimiento, estado civil ni género. Los empleadores estadounidenses suelen descartar los currículums que los llevan para evitar reclamos por discriminación.';

  @override
  String get regionUsConvention3 =>
      'Una sola columna. Sin tablas, cuadros de texto, encabezados ni pies de página — los sistemas ATS estadounidenses son los más estrictos que hay e interpretan mal todo lo demás.';

  @override
  String get regionUsConvention4 =>
      'Si escribes en inglés, usa ortografía estadounidense: organized, program, center, analyze.';

  @override
  String get regionUsConvention5 =>
      'Cuantifica todo lo que puedas. Un logro sin cifras se lee como una descripción de funciones, no como un logro.';

  @override
  String get regionUsConvention6 =>
      'No agregues una línea de referencias; se dan por supuestas.';

  @override
  String get regionUsConvention7 =>
      'Canadá sigue las mismas convenciones. Los puestos en Quebec pueden esperar además una versión en francés.';

  @override
  String get regionUsCoverage => 'Estados Unidos, Canadá';

  @override
  String get regionUsDisplayName => 'EE. UU. y Canadá';

  @override
  String get regionUsLengthNote =>
      'Una página con menos de unos diez años de experiencia; dos páginas a partir de ahí.';

  @override
  String get regionUsToneNote =>
      'Cuantificado y orientado a resultados. Empieza cada logro con el resultado y una cifra — ingresos, porcentaje, tamaño de equipo, tiempo ahorrado.';

  @override
  String get sectionLabelEducation => 'Formación académica';

  @override
  String get sectionLabelExperience => 'Experiencia laboral';

  @override
  String get sectionLabelHobbies => 'Intereses y pasatiempos';

  @override
  String get sectionLabelLanguages => 'Idiomas';

  @override
  String get sectionLabelProjects => 'Proyectos';

  @override
  String get sectionLabelPublications => 'Publicaciones';

  @override
  String get sectionLabelReferences => 'Referencias';

  @override
  String get sectionLabelSkills => 'Habilidades';

  @override
  String get sectionLabelSummary => 'Perfil profesional';

  @override
  String get settingsAiBody =>
      'Usa tu propia clave de API para habilitar la adaptación asistida por IA. Tu clave nunca sale de este dispositivo, salvo para llamar directamente a la API del proveedor. No hay ningún servidor de CVForge.';

  @override
  String settingsAiConfiguredElsewhere(String provider) {
    return 'Configuraste el Asistente de IA en otro dispositivo. Tus CV se sincronizaron, pero tu clave se quedó allá a propósito — pega tu clave de $provider abajo para usar el asistente aquí también.';
  }

  @override
  String get settingsAiConnected => 'Conectado.';

  @override
  String settingsAiErrorInvalidRequest(String provider) {
    return '$provider rechazó la solicitud. Es un error de CVForge, no de tu clave.';
  }

  @override
  String get settingsAiErrorMalformedResponse =>
      'Se recibió una respuesta inesperada. Intenta de nuevo.';

  @override
  String settingsAiErrorNetwork(String provider) {
    return 'No se pudo conectar con $provider. Revisa tu conexión.';
  }

  @override
  String get settingsAiErrorNoKey => 'Primero ingresa una clave de API.';

  @override
  String settingsAiErrorOverloaded(String provider) {
    return 'La API de $provider no está disponible temporalmente. Intenta de nuevo en un rato.';
  }

  @override
  String get settingsAiErrorRateLimited =>
      'Tu cuenta de API alcanzó el límite de solicitudes. Intenta de nuevo en un momento.';

  @override
  String get settingsAiErrorRefusal =>
      'Se rechazó la comprobación de conexión.';

  @override
  String get settingsAiErrorTimeout =>
      'Se agotó el tiempo de espera. Intenta de nuevo.';

  @override
  String get settingsAiErrorUnauthorized =>
      'Esa clave fue rechazada. Revísala e intenta de nuevo.';

  @override
  String get settingsAiHelpDedicatedKey =>
      'Usa una clave creada solo para CVForge, así podrás revocarla sin afectar nada más.';

  @override
  String get settingsAiHelpNoAutoTopUp =>
      'DESACTIVA la recarga automática. Si queda activa, una clave descontrolada o filtrada puede recargarse indefinidamente.';

  @override
  String get settingsAiHelpOpenBilling =>
      'Abrir facturación y límites de gasto';

  @override
  String settingsAiHelpOpenKeySettings(String provider) {
    return 'Abrir la configuración de claves de $provider';
  }

  @override
  String get settingsAiHelpProtectTitle => 'Protégete de cobros inesperados';

  @override
  String get settingsAiHelpSpendCap =>
      'Fija un límite de gasto mensual estricto, tan bajo como estés dispuesto a pagar.';

  @override
  String settingsAiHelpStepNumber(int number) {
    return '$number.';
  }

  @override
  String settingsAiHelpTitle(String provider) {
    return '¿Cómo consigo una clave de API de $provider?';
  }

  @override
  String get settingsAiKeepCurrentKey => 'Conservar mi clave actual';

  @override
  String get settingsAiKeyFieldHint => 'Pega tu clave de API';

  @override
  String settingsAiKeyFieldLabel(String provider) {
    return 'Clave de API de $provider';
  }

  @override
  String settingsAiKeyNone(String provider) {
    return 'Aún no hay clave de $provider. El Asistente de IA está desactivado.';
  }

  @override
  String settingsAiKeySaved(String provider) {
    return 'Tu clave de $provider está guardada en este dispositivo.';
  }

  @override
  String get settingsAiKeySavedOnSuccess =>
      'Tu clave se guarda solo si la prueba de conexión funciona.';

  @override
  String settingsAiKeySession(String provider) {
    return 'Tu clave de $provider está configurada solo para esta sesión. Se perderá al recargar la página.';
  }

  @override
  String get settingsAiModelLabel => 'Modelo';

  @override
  String settingsAiPriceLabel(String provider, String price) {
    return 'Tarifa propia de $provider, no cobrada por CVForge: $price';
  }

  @override
  String settingsAiPriceRate(double input, double output) {
    final intl.NumberFormat inputNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
      symbol: '\$',
      decimalDigits: 2,
    );
    final String inputString = inputNumberFormat.format(input);
    final intl.NumberFormat outputNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
      symbol: '\$',
      decimalDigits: 2,
    );
    final String outputString = outputNumberFormat.format(output);

    return '$inputString entrada / $outputString salida por millón de tokens';
  }

  @override
  String get settingsAiProviderLabel => 'Proveedor';

  @override
  String get settingsAiRemoveKey => 'Quitar clave';

  @override
  String settingsAiRemoveKeyConfirmBody(String provider) {
    return '$provider no volverá a mostrarte esta clave, así que tendrías que crear una nueva en su consola para usar el Asistente de IA en este dispositivo. Tus CV y tu Bóveda no se ven afectados.';
  }

  @override
  String settingsAiRemoveKeyConfirmTitle(String provider) {
    return '¿Quitar tu clave de $provider?';
  }

  @override
  String get settingsAiReplaceKey => 'Reemplazar clave';

  @override
  String get settingsAiStorageWarning =>
      'Tu clave se guarda en este dispositivo, sin cifrar, en el almacenamiento de este navegador — igual que tu Bóveda y tus CV. Cualquiera con acceso a este dispositivo puede leerla.';

  @override
  String get settingsAiTestAndSave => 'Probar y guardar';

  @override
  String get settingsAiTestConnection => 'Probar conexión';

  @override
  String get settingsAiTitle => 'Asistente de IA';

  @override
  String get settingsAppearanceBody =>
      'Se aplica a la interfaz de CVForge. Tu CV siempre se genera sobre papel blanco, sea cual sea el tema que elijas.';

  @override
  String get settingsAppearanceTitle => 'Apariencia';

  @override
  String get settingsBackupBody =>
      'Exporta toda tu Bóveda y cada CV en un solo archivo JSON, o restaura desde una exportación anterior. Restaurar reemplaza todo lo que hay actualmente en este dispositivo. Tus datos actuales se descargan primero como copia de seguridad.';

  @override
  String get settingsBackupExport => 'Exportar copia';

  @override
  String get settingsBackupImport => 'Importar copia';

  @override
  String settingsBackupLast(String relative) {
    return 'Última copia $relative';
  }

  @override
  String settingsBackupLastWithChanges(String relative) {
    return 'Última copia $relative, y tienes cambios desde entonces';
  }

  @override
  String get settingsBackupNever => 'Nunca se ha hecho una copia';

  @override
  String get settingsBackupTitle => 'Copia de seguridad manual';

  @override
  String get settingsClearVault => 'Borrar la Bóveda';

  @override
  String get settingsClearVaultConfirmBody =>
      'Esto elimina cada experiencia, proyecto, habilidad, formación académica, pasatiempo y publicación. No se puede deshacer.';

  @override
  String get settingsClearVaultConfirmTitle => '¿Borrar toda tu Bóveda?';

  @override
  String get settingsDangerZone => 'Zona de riesgo';

  @override
  String get settingsDriveBody =>
      'Inicia sesión con Google para mantener tu Bóveda y cada CV sincronizados con tu propio Google Drive. Inicia sesión de nuevo en otro navegador y ahí estarán todos. CVForge nunca ve ni almacena tus credenciales de Google, solo un único archivo oculto que esta aplicación crea para sí misma.';

  @override
  String get settingsDriveConnect => 'Conectar Google Drive';

  @override
  String settingsDriveConnectedAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get settingsDriveConnecting => 'Conectando…';

  @override
  String get settingsDriveDisconnectConfirmBody =>
      'Tu Bóveda y tus CV quedan exactamente como están en este dispositivo. Esto solo detiene su sincronización con Drive. Puedes volver a conectarte cuando quieras.';

  @override
  String get settingsDriveDisconnectConfirmTitle =>
      '¿Desconectar Google Drive?';

  @override
  String get settingsDriveErrorCancelled => 'Conexión cancelada.';

  @override
  String get settingsDriveErrorNotConfigured =>
      'La sincronización con Google Drive no está configurada.';

  @override
  String get settingsDriveErrorScriptLoad =>
      'No se pudo conectar con Google. Revisa tu conexión e intenta de nuevo.';

  @override
  String get settingsDriveErrorUnknown =>
      'No se pudo conectar con Google Drive. Intenta de nuevo.';

  @override
  String settingsDriveLastSynced(String relative) {
    return 'Última sincronización $relative';
  }

  @override
  String get settingsDriveMerged =>
      'Se combinaron los cambios de tu otro dispositivo';

  @override
  String get settingsDriveNotYetSynced => 'Aún sin sincronizar';

  @override
  String get settingsDriveReconnect => 'Reconectar';

  @override
  String settingsDriveReconnectPrompt(String email) {
    return 'Conectado como $email. Vuelve a conectar para seguir sincronizando.';
  }

  @override
  String get settingsDriveSyncing => 'Sincronizando…';

  @override
  String get settingsDriveSyncNow => 'Sincronizar ahora';

  @override
  String get settingsDriveTitle => 'Google Drive';

  @override
  String get settingsDriveWaiting => 'Esperando para sincronizar…';

  @override
  String settingsImportConfirmBody(String noun, int current, int incoming) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv':
          'Esto reemplazará tu Bóveda y tus $current CV por los $incoming CV de este archivo.',
      'resume':
          'Esto reemplazará tu Bóveda y tus $current currículums por los $incoming currículums de este archivo.',
      'other':
          'Esto reemplazará tu Bóveda y tus $current documentos por los $incoming documentos de este archivo.',
    });
    return '$_temp0 Tus datos actuales se descargan primero como copia de seguridad.';
  }

  @override
  String get settingsImportConfirmTitle => '¿Reemplazar tus datos?';

  @override
  String get settingsImportErrorIo =>
      'No se pudo leer ese archivo. Intenta de nuevo.';

  @override
  String get settingsImportErrorMalformed =>
      'Ese archivo no es una copia de seguridad válida de CVForge.';

  @override
  String get settingsImportErrorNewerVersion =>
      'Esta copia se creó con una versión más reciente de CVForge.';

  @override
  String get settingsLanguageCardBody =>
      'El idioma en el que se muestran los botones y las etiquetas de CVForge. El idioma en el que está escrito tu CV es aparte y se elige en la Bóveda.';

  @override
  String get settingsLanguageCardTitle => 'Idioma';

  @override
  String get settingsLanguageFollowSystem => 'Usar el idioma de mi navegador';

  @override
  String get settingsLinkPrivacy => 'Política de privacidad';

  @override
  String get settingsLinkTerms => 'Términos del servicio';

  @override
  String get skillCategoryUnnamed => 'Categoría sin nombre';

  @override
  String get spellingEnAu => 'Inglés australiano';

  @override
  String get spellingEnGb => 'Inglés británico';

  @override
  String get spellingEnUs => 'Inglés estadounidense';

  @override
  String get studioAiCardBody =>
      'Pega aquí la oferta de empleo para seleccionar y reescribir este CV en función de ella.';

  @override
  String get studioAiCardBodyNoKey =>
      'Usa tu propia clave de API en Configuración y luego pega aquí una oferta de empleo para seleccionar y reescribir este CV en función de ella.';

  @override
  String get studioAiCardTitle => 'Adaptar con IA';

  @override
  String get studioAiClearJobDescription => 'Borrar la descripción del puesto';

  @override
  String studioAiCostEstimate(int cents) {
    String _temp0 = intl.Intl.pluralLogic(
      cents,
      locale: localeName,
      other: 'Aproximadamente $cents¢ a las tarifas actuales.',
      one: 'Aproximadamente 1¢ a las tarifas actuales.',
      zero: 'Menos de 1¢ a las tarifas actuales.',
    );
    return '$_temp0';
  }

  @override
  String studioAiDialogLanguageNote(String language) {
    return 'Redactado en $language: el asistente traduce tus viñetas si tu Bóveda está en otro idioma.';
  }

  @override
  String studioAiDialogPrivacy(String provider) {
    return 'Esto envía la descripción del puesto que está abajo y el contenido de tu CV — no tu nombre, correo, teléfono ni enlaces — a $provider, usando tu propia clave de API. No hay ningún servidor de CVForge de por medio. Puede tardar hasta unos minutos: el modelo razona sobre toda tu Bóveda antes de responder.';
  }

  @override
  String studioAiDialogRegionNote(String region) {
    return 'Adaptado para $region: el asistente sigue las convenciones de extensión y tono de ese mercado.';
  }

  @override
  String get studioAiDialogTitle => 'Adaptar con IA';

  @override
  String get studioAiEditJobDescription => 'Editar la descripción del puesto';

  @override
  String get studioAiErrorGeneric => 'Algo salió mal — intenta de nuevo.';

  @override
  String studioAiErrorInvalidRequest(String provider) {
    return '$provider rechazó la solicitud. Es un error de CVForge, no de lo que ingresaste.';
  }

  @override
  String get studioAiErrorMalformedResponse =>
      'Se recibió una respuesta inesperada — intenta de nuevo.';

  @override
  String studioAiErrorNetwork(String provider) {
    return 'No se pudo conectar con $provider — revisa tu conexión.';
  }

  @override
  String get studioAiErrorNoKey =>
      'Primero agrega una clave de API del Asistente de IA en Configuración.';

  @override
  String studioAiErrorOverloaded(String provider) {
    return 'La API de $provider no está disponible temporalmente — intenta de nuevo en un rato.';
  }

  @override
  String get studioAiErrorRateLimited =>
      'Tu cuenta de API alcanzó el límite de solicitudes — intenta de nuevo en un momento.';

  @override
  String get studioAiErrorRefusal =>
      'El modelo se negó a responder — prueba a reformular la descripción del puesto.';

  @override
  String get studioAiErrorTimeout =>
      'Se agotó el tiempo de espera — intenta de nuevo.';

  @override
  String get studioAiErrorUnauthorized =>
      'Tu clave de API fue rechazada — revísala en Configuración.';

  @override
  String get studioAiFailedTitle => 'Algo salió mal.';

  @override
  String studioAiGapItem(String gap) {
    return '• $gap';
  }

  @override
  String get studioAiJobAdHint =>
      'Pega la oferta de empleo para la que estás adaptando este CV.';

  @override
  String get studioAiKeywordGaps => 'Sin respaldo en tu Bóveda';

  @override
  String get studioAiRationale => 'Justificación';

  @override
  String get studioAiRunningBody =>
      'Puede tardar hasta unos minutos. Por favor, mantén abierta esta ventana.';

  @override
  String get studioAiRunningTitle => 'Adaptando tu CV';

  @override
  String get studioAiSetUpInSettings => 'Configurar en Configuración';

  @override
  String get studioAiUndo => 'Deshacer los cambios de la IA';

  @override
  String get studioAiWarning =>
      'Escrito por IA. Revisa cada logro reescrito y compáralo con lo que realmente hiciste.';

  @override
  String studioBackToDrafts(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Volver a tus CV',
      'resume': 'Volver a tus currículums',
      'other': 'Volver a tus documentos',
    });
    return '$_temp0';
  }

  @override
  String get studioBackToSections => 'Volver a las secciones';

  @override
  String studioBulletsSelected(int selected, int total) {
    return '$selected/$total logros';
  }

  @override
  String studioBulletsSelectedTailored(int selected, int total, int tailored) {
    return '$selected/$total logros · $tailored adaptados';
  }

  @override
  String get studioDeleteDraftBody => 'No se puede deshacer.';

  @override
  String studioDeleteDraftTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get studioDraftDuplicate => 'Duplicar';

  @override
  String get studioDraftRename => 'Renombrar / editar notas';

  @override
  String studioDraftsEmptyBody(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv':
          'Crea un CV para empezar a adaptar tu Bóveda a una postulación concreta.',
      'resume':
          'Crea un currículum para empezar a adaptar tu Bóveda a una postulación concreta.',
      'other':
          'Crea un documento para empezar a adaptar tu Bóveda a una postulación concreta.',
    });
    return '$_temp0';
  }

  @override
  String studioDraftsEmptyTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Aún no hay CV',
      'resume': 'Aún no hay currículums',
      'other': 'Aún no hay documentos',
    });
    return '$_temp0';
  }

  @override
  String studioDraftsNoMatches(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Ningún CV coincide con tu búsqueda.',
      'resume': 'Ningún currículum coincide con tu búsqueda.',
      'other': 'Ningún documento coincide con tu búsqueda.',
    });
    return '$_temp0';
  }

  @override
  String get studioDraftsPersistError => 'No se pudo guardar tu último cambio.';

  @override
  String studioDraftsSearch(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Buscar CV…',
      'resume': 'Buscar currículums…',
      'other': 'Buscar documentos…',
    });
    return '$_temp0';
  }

  @override
  String get studioDraftTailoredMarker => 'Adaptado a una oferta';

  @override
  String studioDraftUntitled(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'CV sin título',
      'resume': 'Currículum sin título',
      'other': 'Documento sin título',
    });
    return '$_temp0';
  }

  @override
  String studioDraftUpdated(String relative) {
    return 'Actualizado $relative';
  }

  @override
  String studioDraftUpdatedExact(DateTime timestamp) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat(
      'dd/MM/yyyy HH:mm',
      localeName,
    );
    final String timestampString = timestampDateFormat.format(timestamp);

    return '$timestampString';
  }

  @override
  String studioEditDetailsTooltip(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Editar detalles del CV',
      'resume': 'Editar detalles del currículum',
      'other': 'Editar detalles del documento',
    });
    return '$_temp0';
  }

  @override
  String studioEditDraftDetailsTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Editar detalles del CV',
      'resume': 'Editar detalles del currículum',
      'other': 'Editar detalles del documento',
    });
    return '$_temp0';
  }

  @override
  String get studioEditDraftName => 'Nombre';

  @override
  String studioEditDraftNameHelper(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Ponle un nombre a este CV',
      'resume': 'Ponle un nombre a este currículum',
      'other': 'Ponle un nombre a este documento',
    });
    return '$_temp0';
  }

  @override
  String get studioEditDraftNameHint =>
      'p. ej. \"Acme — Ingeniera de backend\"';

  @override
  String get studioEditDraftNotes => 'Notas';

  @override
  String studioEditDraftNotesHelper(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Para qué es este CV, o cualquier cosa que quieras recordar',
      'resume':
          'Para qué es este currículum, o cualquier cosa que quieras recordar',
      'other':
          'Para qué es este documento, o cualquier cosa que quieras recordar',
    });
    return '$_temp0';
  }

  @override
  String studioEditDraftTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Detalles del CV',
      'resume': 'Detalles del currículum',
      'other': 'Detalles del documento',
    });
    return '$_temp0';
  }

  @override
  String get studioExportErrorFonts =>
      'No se pudieron cargar las tipografías necesarias para exportar — revisa tu conexión e intenta de nuevo.';

  @override
  String get studioExportErrorGeneric =>
      'No se pudo exportar el PDF — intenta de nuevo.';

  @override
  String get studioExportErrorRender =>
      'No se pudo generar el PDF — intenta de nuevo y, si sigue fallando, revisa tu CV en busca de caracteres o formatos inusuales.';

  @override
  String get studioExportErrorSave =>
      'No se pudo guardar el archivo — revisa la configuración de descargas de tu navegador e intenta de nuevo.';

  @override
  String get studioExporting => 'Exportando…';

  @override
  String get studioExportPdf => 'Exportar PDF';

  @override
  String get studioFieldCitation => 'Cita';

  @override
  String get studioFieldCompany => 'Empleador';

  @override
  String get studioFieldDates => 'Fechas';

  @override
  String get studioFieldDetails => 'Detalles';

  @override
  String get studioFieldDoNotPrint => 'No imprimir esto en este CV';

  @override
  String get studioFieldGrade => 'Calificación';

  @override
  String get studioFieldInstitution => 'Institución';

  @override
  String get studioFieldLink => 'Enlace';

  @override
  String get studioFieldLocation => 'Ubicación';

  @override
  String get studioFieldPrintAgain => 'Imprimir esto en este CV';

  @override
  String get studioFieldProjectTitle => 'Título del proyecto';

  @override
  String get studioFieldPublicationTitle => 'Título';

  @override
  String get studioFieldQualification => 'Titulación';

  @override
  String get studioFieldRole => 'Puesto';

  @override
  String get studioFieldSkill => 'Competencia';

  @override
  String get studioFieldSkillCategory => 'Categoría';

  @override
  String get studioFieldYear => 'Año';

  @override
  String get studioHeadlineInclude => 'Incluir el titular';

  @override
  String studioLengthWarning(String region, String note) {
    return 'Más largo de lo que $region suele esperar. $note Prueba a recortar contenido o usar una plantilla más densa.';
  }

  @override
  String get studioLockedDates =>
      'Las fechas se mantienen como las registra tu Bóveda — son lo que verifica una comprobación de empleo y determinan el orden en que se imprime esta sección.';

  @override
  String get studioLockedFromVault =>
      'Se imprime desde tu Bóveda. Edítalo allí para cambiarlo en todos los CV.';

  @override
  String studioNewDraftTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Nuevo CV',
      'resume': 'Nuevo currículum',
      'other': 'Nuevo documento',
    });
    return '$_temp0';
  }

  @override
  String get studioNoCitation => 'Aún no hay cita en tu Bóveda.';

  @override
  String get studioNoEducationDetails => 'Aún no hay detalles en tu Bóveda.';

  @override
  String get studioNoGrade => 'Aún no hay calificación en tu Bóveda.';

  @override
  String get studioNoHeadline => 'Aún no hay titular en tu Bóveda.';

  @override
  String get studioNoLocation => 'Aún no hay ubicación en tu Bóveda.';

  @override
  String get studioNoReferences =>
      'Aún no hay nota de referencias en tu Bóveda.';

  @override
  String get studioNoSectionSelectedBody =>
      'Elige una sección a la izquierda para editar su contenido.';

  @override
  String get studioNoSectionSelectedTitle => 'Nada seleccionado';

  @override
  String get studioNoSummary => 'Aún no hay perfil profesional en tu Bóveda.';

  @override
  String studioPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return '$_temp0';
  }

  @override
  String studioPhotoRegionWarning(String stance, String region) {
    String _temp0 = intl.Intl.selectLogic(stance, {
      'prohibited':
          'Esta plantilla imprime una foto, y $region no espera ninguna — motivo de descarte automático. Cambia de plantilla o de región.',
      'discouraged':
          'Esta plantilla imprime una foto, y $region no espera ninguna — se desaconseja firmemente. Cambia de plantilla o de región.',
      'other':
          'Esta plantilla imprime una foto, y $region no espera ninguna. Cambia de plantilla o de región.',
    });
    return '$_temp0';
  }

  @override
  String get studioPreviewAddAll => 'Agregar todo';

  @override
  String get studioPreviewEmptyBody =>
      'Agrega algo a tu Bóveda y luego vuelve para armar un CV.';

  @override
  String get studioPreviewEmptyTitle => 'Aún no hay nada que previsualizar';

  @override
  String get studioPreviewErrorBody =>
      'El botón Exportar PDF de arriba usa la misma generación de PDF y puede que sí funcione — pruébalo o recarga la página.';

  @override
  String get studioPreviewErrorContext =>
      'rasterizando la vista previa de Studio';

  @override
  String get studioPreviewErrorTitle => 'No se pudo mostrar la vista previa';

  @override
  String get studioPreviewGoToVault => 'Ir a la Bóveda';

  @override
  String studioPreviewNothingSelectedBody(int count) {
    return 'Tu Bóveda tiene $count elementos, pero ninguno está incluido en este CV.';
  }

  @override
  String get studioPreviewNothingSelectedTitle =>
      'Aún no hay nada seleccionado';

  @override
  String studioRegionDetailRow(String label) {
    return '$label: ';
  }

  @override
  String get studioRegionLocalName => 'Allá se le llama';

  @override
  String get studioRegionPageSize => 'Tamaño de página';

  @override
  String get studioRegionPersonalDetails => 'Datos personales';

  @override
  String get studioRegionPhoto => 'Foto';

  @override
  String get studioRegionPickerBody =>
      'Las convenciones varían según el mercado. Esto define el tamaño de página, la extensión esperada y las recomendaciones de abajo. No define el idioma en el que está escrito tu CV, y nunca reescribe el contenido de tu carrera.';

  @override
  String get studioRegionPickerDefaultBody =>
      'Define la región con la que empieza cada CV nuevo. Cambiarla nunca afecta a un CV que ya hayas creado: esos se cambian de uno en uno desde el Estudio.';

  @override
  String get studioRegionPickerDefaultTitle => 'Región predeterminada';

  @override
  String get studioRegionPickerSetDefault => 'Definir como predeterminada';

  @override
  String get studioRegionPickerTitle => 'Elige una región';

  @override
  String get studioRegionPickerUse => 'Usar esta región';

  @override
  String get studioRegionSpelling => 'Ortografía del inglés';

  @override
  String get studioRegionTypicalLength => 'Extensión habitual';

  @override
  String get studioResetWording => 'Restablecer el texto al de la Bóveda';

  @override
  String get studioResetWordingConfirm =>
      'Cada línea volverá a como la redacta tu Bóveda, descartando tus ediciones, las reescrituras de IA y cualquier traducción de este CV. No afecta a qué entradas se incluyen.';

  @override
  String get studioSectionHeadline => 'Titular';

  @override
  String get studioSectionNavPersistError =>
      'No se pudo guardar tu último cambio de selección.';

  @override
  String get studioSectionsResetDefault =>
      'Restablecer las secciones a la Bóveda';

  @override
  String get studioSectionsResetDefaultConfirm =>
      'Las secciones de este CV volverán al orden y la visibilidad guardados en tu Bóveda, descartando cómo has organizado este. No afecta a lo que dice cada línea.';

  @override
  String get studioSectionsTitle => 'Secciones';

  @override
  String get studioSectionSummary => 'Perfil';

  @override
  String studioSkillLinkedBullets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vinculada a $count logros de este CV',
      one: 'Vinculada a 1 logro de este CV',
    );
    return '$_temp0';
  }

  @override
  String studioSkillsEvidenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vinculada a $count logros en este CV',
      one: 'Vinculada a 1 logro en este CV',
    );
    return '$_temp0';
  }

  @override
  String get studioSkillsFilter => 'Filtrar habilidades…';

  @override
  String get studioSkillsNoLinks =>
      'Vincula habilidades con logros en la Bóveda para poder usar esto';

  @override
  String get studioSkillsNoNewEvidenced =>
      'No hay nuevas habilidades respaldadas por agregar — todas las vinculadas a un logro incluido ya están seleccionadas';

  @override
  String get studioSkillsRename => 'Renombrar para este CV';

  @override
  String get studioSkillsRenameDone => 'Terminar de renombrar';

  @override
  String studioSkillsSelectedCount(int selected, int total) {
    return '$selected de $total seleccionadas';
  }

  @override
  String studioSkillsSelectEvidenced(int count) {
    return 'Seleccionar $count habilidades respaldadas';
  }

  @override
  String get studioSkillsSelectEvidencedTooltip =>
      'Selecciona todas las habilidades vinculadas a un logro ya incluido en este CV';

  @override
  String get studioSkillsTitle => 'Habilidades';

  @override
  String get studioSortLabel => 'Ordenar';

  @override
  String get studioSortNameAtoZ => 'Nombre A–Z';

  @override
  String get studioSortRecentlyUpdated => 'Actualizados recientemente';

  @override
  String get studioTabConfigure => 'Configurar';

  @override
  String get studioTabPreview => 'Vista previa';

  @override
  String get studioTailoringEditText => 'Editar texto';

  @override
  String get studioTailoringFromVault => 'De tu Bóveda — aún sin adaptar';

  @override
  String get studioTailoringOnlyThisCv => 'Solo afecta a este CV.';

  @override
  String get studioTailoringPaneNote =>
      'Los cambios aquí solo afectan a este CV. Tu Bóveda conserva su propia redacción.';

  @override
  String get studioTailoringReverted =>
      'Volver a la Bóveda — adaptado para este CV';

  @override
  String get studioTemplateCurrent => 'Actual';

  @override
  String get studioTemplatePickerTitle => 'Elige una plantilla';

  @override
  String get studioTemplatePickerUse => 'Usar esta plantilla';

  @override
  String get studioTranslateCardBody =>
      'Reescribe todo lo que imprime este CV al idioma del documento, dejando tu Bóveda en el idioma en que lo escribiste.';

  @override
  String get studioTranslateCardBodyNoKey =>
      'Traducir un CV usa el mismo proveedor de IA que la adaptación. Añade una clave en Ajustes para activarlo.';

  @override
  String studioTranslateCardStale(String translated, String current) {
    return 'Traducido a $translated, pero este CV ahora está configurado en $current.';
  }

  @override
  String studioTranslateCardTarget(String language) {
    return 'El idioma de este CV es $language.';
  }

  @override
  String get studioTranslateCardTitle => 'Traducir';

  @override
  String studioTranslateCardTranslated(String language) {
    return 'Traducido a $language.';
  }

  @override
  String studioTranslateDialogLanguageNote(String language) {
    return 'Cada línea que imprime este CV se reescribirá en $language: puestos, viñetas, competencias y el contenido de las secciones. Los nombres de empresas, centros de estudios y publicaciones se dejan tal cual.';
  }

  @override
  String get studioTranslateDialogReplaceNote =>
      'Este CV ya tiene una traducción. Volver a ejecutarla la reemplaza.';

  @override
  String get studioTranslateDialogTitle => 'Traducir este CV';

  @override
  String get studioTranslateErrorGeneric =>
      'No se pudo traducir este CV: inténtalo de nuevo.';

  @override
  String studioTranslateErrorInvalidRequest(String provider) {
    return '$provider rechazó la solicitud. Puede que este CV sea demasiado largo para traducirlo de una vez.';
  }

  @override
  String get studioTranslateErrorMalformedResponse =>
      'La traducción llegó en un formato que CVForge no pudo leer: inténtalo de nuevo.';

  @override
  String studioTranslateErrorNetwork(String provider) {
    return 'No se pudo contactar con $provider: revisa tu conexión e inténtalo de nuevo.';
  }

  @override
  String get studioTranslateErrorNoKey =>
      'Aún no hay ninguna clave de API configurada: añade una en Ajustes.';

  @override
  String studioTranslateErrorOverloaded(String provider) {
    return '$provider está saturado ahora mismo: inténtalo dentro de un momento.';
  }

  @override
  String get studioTranslateErrorRateLimited =>
      'Has alcanzado el límite de peticiones de tu proveedor: espera un momento e inténtalo de nuevo.';

  @override
  String get studioTranslateErrorRefusal =>
      'El proveedor se negó a traducir este CV.';

  @override
  String get studioTranslateErrorTimeout =>
      'La traducción tardó demasiado y se agotó el tiempo: inténtalo de nuevo.';

  @override
  String get studioTranslateErrorUnauthorized =>
      'Tu clave de API fue rechazada: revísala en Ajustes.';

  @override
  String get studioTranslateFailedTitle => 'La traducción falló';

  @override
  String get studioTranslateRemove => 'Quitar la traducción';

  @override
  String get studioTranslateRemoveConfirm =>
      'Esto restaura cada línea a como estaba antes de traducir, incluido lo que hayas editado desde entonces. ¿Quitarla?';

  @override
  String studioTranslateResultBody(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se tradujeron $count líneas de $total.',
      one: 'Se tradujo 1 línea de $total.',
    );
    return '$_temp0';
  }

  @override
  String get studioTranslateRunAgain => 'Traducir de nuevo';

  @override
  String get studioTranslateRunningBody =>
      'Traduciendo cada línea que imprime este CV. Puede tardar unos minutos.';

  @override
  String studioTranslateRunningProgress(int completed, int total) {
    return 'Sección $completed de $total.';
  }

  @override
  String get studioTranslateRunningTitle => 'Traduciendo tu CV';

  @override
  String get studioTranslateTailorFirst =>
      'Adapta antes de traducir: una pasada de adaptación reescribe en inglés y deshará esto.';

  @override
  String get studioTranslateWarning =>
      'Traducido automáticamente. Pide a alguien con dominio del idioma que lo revise antes de enviarlo.';

  @override
  String get studioXrayAnalyzing => 'Leyendo tu CV como lo haría un ATS…';

  @override
  String get studioXrayBoxesTooltip =>
      'Ver lo que un ATS extrae de esta página';

  @override
  String studioXrayCriticalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count críticos',
      one: '1 crítico',
    );
    return '$_temp0';
  }

  @override
  String get studioXrayErrorBackToPreview => 'Volver a la vista previa';

  @override
  String get studioXrayErrorBody =>
      'El CV se generó, pero no se pudo volver a leer para revisarlo. Desactiva la radiografía para seguir trabajando: tu vista previa y tu exportación no se ven afectadas.';

  @override
  String get studioXrayErrorContext =>
      'al construir la radiografía ATS del Estudio';

  @override
  String get studioXrayErrorTitle => 'No se pudo ejecutar la revisión ATS';

  @override
  String get studioXrayFindingsTitle => 'Lo que le costaría a un ATS';

  @override
  String get studioXrayGroupLabel => 'ATS';

  @override
  String get studioXrayHide => 'Ocultar la superposición ATS';

  @override
  String studioXrayInfoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas',
      one: '1 nota',
    );
    return '$_temp0';
  }

  @override
  String get studioXrayNoIssues =>
      'Nada aquí activa un problema conocido de lectura por ATS.';

  @override
  String get studioXrayNoIssuesTitle => 'Nada que corregir aquí';

  @override
  String get studioXrayReadingOrderTooltip =>
      'Ver en qué orden lee esta página un ATS';

  @override
  String get studioXrayShow => 'Ver lo que ve un ATS';

  @override
  String studioXrayWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count advertencias',
      one: '1 advertencia',
    );
    return '$_temp0';
  }

  @override
  String get templateDescriptionClassicCentered =>
      'Encabezados centrados y un perfil justificado, con espacios en blanco en lugar de líneas divisorias.';

  @override
  String get templateDescriptionCompact =>
      'Una sola columna sencilla, con composición ajustada — el máximo contenido por página.';

  @override
  String get templateDescriptionPhotoHeader =>
      'Una banda de encabezado con color alrededor de la foto de tu Bóveda. Se espera en DACH y es común en el sur de Europa; en EE. UU. y el Reino Unido una foto provoca el descarte.';

  @override
  String get templateNameClassicCentered => 'Tradicional';

  @override
  String get templateNameCompact => 'Compacta';

  @override
  String get templateNamePhotoHeader => 'Moderna con foto';

  @override
  String get templateTagAcademic => 'Académico';

  @override
  String get templateTagAtsSafe => 'Compatible con ATS';

  @override
  String get templateTagCompact => 'Compacto';

  @override
  String get templateTagModern => 'Moderno';

  @override
  String get templateTagPhoto => 'Foto';

  @override
  String get templateTagTraditional => 'Tradicional';

  @override
  String get templateTagTwoColumn => 'Dos columnas';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeSystem => 'Según el dispositivo';

  @override
  String themeToggleTooltip(String current, String next) {
    return 'Tema: $current — cambiar a $next';
  }

  @override
  String get vaultAddBasics => 'Agrega tus datos básicos';

  @override
  String get vaultAddEducation => 'Agregar formación';

  @override
  String get vaultAddExperience => 'Agregar experiencia';

  @override
  String get vaultAddHobbies => 'Añade tus pasatiempos';

  @override
  String get vaultAddLanguages => 'Añade tus idiomas';

  @override
  String get vaultAddProject => 'Agregar proyecto';

  @override
  String get vaultAddPublication => 'Agregar publicación';

  @override
  String get vaultAddSkills => 'Añade tus habilidades';

  @override
  String get vaultBasicsDeleteLink => 'Eliminar enlace';

  @override
  String get vaultBasicsEmail => 'Correo electrónico';

  @override
  String get vaultBasicsFullName => 'Nombre completo';

  @override
  String get vaultBasicsHeadline => 'Titular';

  @override
  String get vaultBasicsHeadlineHint => 'p. ej. Ingeniera de software sénior';

  @override
  String get vaultBasicsLinkLabel => 'Etiqueta';

  @override
  String get vaultBasicsLinkLabelHint => 'p. ej. LinkedIn';

  @override
  String get vaultBasicsLinks => 'Enlaces';

  @override
  String get vaultBasicsLinkUrl => 'URL';

  @override
  String get vaultBasicsLocation => 'Ubicación';

  @override
  String get vaultBasicsPhone => 'Teléfono';

  @override
  String get vaultBasicsReferences => 'Referencias';

  @override
  String get vaultBasicsReferencesHint => 'p. ej. \"Disponibles a solicitud.\"';

  @override
  String get vaultBasicsSummary => 'Perfil profesional';

  @override
  String get vaultBasicsTitle => 'Datos básicos';

  @override
  String get vaultBasicsWorkAuthorization =>
      'Autorización de trabajo (opcional)';

  @override
  String get vaultBasicsWorkAuthorizationHint =>
      'p. ej. Con permiso de trabajo en la UE — no requiere patrocinio';

  @override
  String get vaultBulletAddSkill => 'Agregar habilidad';

  @override
  String get vaultBulletCategory => 'Categoría';

  @override
  String get vaultBulletDelete => 'Eliminar logro';

  @override
  String vaultBulletLinkedSkills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vinculado a $count habilidades',
      one: 'Vinculado a 1 habilidad',
    );
    return '$_temp0';
  }

  @override
  String get vaultBulletLinkToSkills => 'Vincular con habilidades';

  @override
  String get vaultBulletNewCategory => 'Nueva categoría…';

  @override
  String get vaultBulletNewCategoryName => 'Nombre de la nueva categoría';

  @override
  String get vaultBulletNoSkillMatches =>
      'Ninguna habilidad coincide con tu búsqueda.';

  @override
  String get vaultBulletNoSkillsYet => 'Aún no hay habilidades en tu Bóveda.';

  @override
  String get vaultBulletSearchSkills => 'Busca o agrega una habilidad…';

  @override
  String get vaultBulletsEmpty => 'Aún no hay logros.';

  @override
  String vaultBulletSkillNotInVault(String query) {
    return '\"$query\" aún no está en tu Bóveda';
  }

  @override
  String get vaultBulletsTitle => 'Logros';

  @override
  String get vaultBulletText => 'Texto';

  @override
  String get vaultConfirmDeleteFallbackTitle => '¿Eliminar esto?';

  @override
  String get vaultCropPhotoBody =>
      'Arrastra el marco para elegir qué se ve. La forma está fijada al tamaño de 35 × 45 mm que esperan los CV europeos.';

  @override
  String get vaultCropPhotoConfirm => 'Usar esta foto';

  @override
  String get vaultCropPhotoSaving => 'Guardando…';

  @override
  String get vaultCropPhotoTitle => 'Encuadra tu foto';

  @override
  String get vaultCvDefaultsChange => 'Cambiar';

  @override
  String get vaultCvDefaultsHeadline => 'Titular';

  @override
  String get vaultCvDefaultsLanguageHelp =>
      'El idioma en el que está escrito tu CV: es distinto del mercado de arriba y del idioma en el que se muestra CVForge, que se elige en Ajustes.';

  @override
  String get vaultCvDefaultsLanguageLabel => 'Idioma';

  @override
  String get vaultCvDefaultsPanelBody =>
      'Con esto empieza cada CV nuevo. Cambiarlo nunca modifica un CV que ya hayas creado: esos se cambian de uno en uno desde el Estudio.';

  @override
  String vaultCvDefaultsPanelTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'resume': 'Valores por defecto del résumé',
      'other': 'Valores por defecto del CV',
    });
    return '$_temp0';
  }

  @override
  String get vaultCvDefaultsRegionHelp =>
      'Define el tamaño de página, la extensión esperada y las recomendaciones que sigue el Asistente de IA. No el idioma: eso está en la fila de abajo.';

  @override
  String get vaultCvDefaultsRegionLabel => 'Región';

  @override
  String get vaultCvDefaultsSectionsHelp =>
      'Qué secciones incluye un CV nuevo y en qué orden se imprimen. Arrastra para reordenar.';

  @override
  String get vaultCvDefaultsSectionsLabel => 'Secciones';

  @override
  String get vaultCvDefaultsTemplateHelp =>
      'El diseño con el que empieza un CV nuevo: su composición, su tipografía y si se imprime una foto.';

  @override
  String get vaultCvDefaultsTemplateLabel => 'Plantilla';

  @override
  String get vaultDeleteCategoryBody =>
      'Esto la elimina junto con todas sus habilidades.';

  @override
  String get vaultDeleteCategoryTitle => '¿Eliminar esta categoría?';

  @override
  String get vaultDeleteExperienceTitle => '¿Eliminar esta experiencia?';

  @override
  String get vaultDeleteProjectTitle => '¿Eliminar este proyecto?';

  @override
  String get vaultDeletePublicationTitle => '¿Eliminar esta publicación?';

  @override
  String get vaultDeleteQualificationTitle => '¿Eliminar esta formación?';

  @override
  String get vaultDeleteUndoneBody => 'No se puede deshacer.';

  @override
  String get vaultDeleteWithBulletsBody =>
      'Esto la elimina junto con todos sus logros. No se puede deshacer.';

  @override
  String get vaultEducationDetails => 'Detalles (opcional)';

  @override
  String get vaultEducationGrade => 'Calificación (opcional)';

  @override
  String get vaultEducationGradeHint => 'p. ej. Grado con honores';

  @override
  String get vaultEducationInstitution => 'Institución';

  @override
  String get vaultEducationLocation => 'Ubicación (opcional)';

  @override
  String get vaultEducationNew => 'Nueva formación';

  @override
  String get vaultEducationQualification => 'Título';

  @override
  String get vaultEducationQualificationHint => 'p. ej. Ingeniería de Sistemas';

  @override
  String get vaultEducationYear => 'Año (opcional)';

  @override
  String get vaultEmptyBody =>
      'Agrega aquí tu experiencia laboral, tus habilidades y tu formación — este es tu registro maestro, independiente de cualquier CV que exportes.';

  @override
  String get vaultEmptyLoadExample => 'Cargar CV de ejemplo';

  @override
  String get vaultEmptyStartScratch => 'Empezar desde cero';

  @override
  String get vaultEmptyTitle => 'Tu Bóveda está vacía';

  @override
  String get vaultExperienceCompany => 'Empresa';

  @override
  String get vaultExperienceCurrent => 'Actualmente trabajo aquí';

  @override
  String get vaultExperienceEnd => 'Fin';

  @override
  String get vaultExperienceLocation => 'Ubicación';

  @override
  String get vaultExperienceNew => 'Nueva experiencia';

  @override
  String get vaultExperiencePromotionGroup => 'Ascenso — agrupar con';

  @override
  String get vaultExperienceRole => 'Cargo';

  @override
  String get vaultExperienceStart => 'Inicio';

  @override
  String vaultHobbiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasatiempos',
      one: '1 pasatiempo',
    );
    return '$_temp0';
  }

  @override
  String get vaultHobbiesEmptyShort => 'Aún no hay nada.';

  @override
  String get vaultHobbiesItems => 'Elementos';

  @override
  String vaultHobbiesMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasatiempos coincidentes',
      one: '1 pasatiempo coincidente',
    );
    return '$_temp0';
  }

  @override
  String get vaultHobbiesTitle => 'Intereses y pasatiempos';

  @override
  String get vaultInvalidUrlNotice =>
      'Esa página no existe — aquí está tu Bóveda.';

  @override
  String get vaultLanguageLevel => 'Nivel';

  @override
  String get vaultLanguageLevelUnset => 'Sin especificar';

  @override
  String get vaultLanguageName => 'Idioma';

  @override
  String get vaultLanguageNameHint => 'p. ej. Alemán';

  @override
  String vaultLanguagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count idiomas',
      one: '1 idioma',
    );
    return '$_temp0';
  }

  @override
  String get vaultLanguagesDeleteLanguage => 'Eliminar idioma';

  @override
  String get vaultLanguagesEmptyShort => 'Aún no hay nada.';

  @override
  String get vaultLanguagesItems => 'Elementos';

  @override
  String vaultLanguagesMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count idiomas coincidentes',
      one: '1 idioma coincidente',
    );
    return '$_temp0';
  }

  @override
  String get vaultLanguagesTitle => 'Idiomas';

  @override
  String get vaultMonthApr => 'abr';

  @override
  String get vaultMonthAug => 'ago';

  @override
  String get vaultMonthDec => 'dic';

  @override
  String get vaultMonthFeb => 'feb';

  @override
  String get vaultMonthJan => 'ene';

  @override
  String get vaultMonthJul => 'jul';

  @override
  String get vaultMonthJun => 'jun';

  @override
  String get vaultMonthMar => 'mar';

  @override
  String get vaultMonthMay => 'may';

  @override
  String get vaultMonthNov => 'nov';

  @override
  String get vaultMonthOct => 'oct';

  @override
  String get vaultMonthSep => 'sept';

  @override
  String get vaultNoEducation => 'Aún no hay formación académica.';

  @override
  String get vaultNoExperience => 'Aún no hay experiencia.';

  @override
  String get vaultNoProjects => 'Aún no hay proyectos.';

  @override
  String get vaultNoPublications => 'Aún no hay publicaciones.';

  @override
  String get vaultNoSearchMatches => 'No hay coincidencias para tu búsqueda.';

  @override
  String get vaultPersistError => 'No se pudo guardar tu último cambio.';

  @override
  String get vaultPhotoAdd => 'Agregar foto';

  @override
  String get vaultPhotoErrorPrepareFailed =>
      'No se pudo preparar esa foto. Prueba con otra imagen.';

  @override
  String get vaultPhotoErrorUnreadable =>
      'No se pudo leer ese archivo como imagen. Prueba con un JPEG o PNG.';

  @override
  String get vaultPhotoHelpInUse =>
      'La usan las plantillas que incluyen foto. Las demás la ignoran.';

  @override
  String get vaultPhotoHelpOptional =>
      'Opcional. Solo la usan las plantillas que incluyen foto — se espera en DACH, y es mejor omitirla para EE. UU. y el Reino Unido.';

  @override
  String get vaultPhotoLoading => 'Cargando…';

  @override
  String get vaultPhotoRemove => 'Quitar';

  @override
  String get vaultPhotoReplace => 'Reemplazar';

  @override
  String get vaultPhotoTitle => 'Foto';

  @override
  String get vaultProficiencyA1 => 'A1 — Principiante';

  @override
  String get vaultProficiencyA2 => 'A2 — Básico';

  @override
  String get vaultProficiencyB1 => 'B1 — Intermedio';

  @override
  String get vaultProficiencyB2 => 'B2 — Intermedio alto';

  @override
  String get vaultProficiencyC1 => 'C1 — Avanzado';

  @override
  String get vaultProficiencyC2 => 'C2 — Maestría';

  @override
  String get vaultProficiencyNative => 'Hablante nativo';

  @override
  String get vaultProjectLink => 'Enlace (opcional)';

  @override
  String get vaultProjectLinkHint => 'p. ej. github.com/tuusuario/proyecto';

  @override
  String get vaultProjectNew => 'Nuevo proyecto';

  @override
  String get vaultProjectTitle => 'Título';

  @override
  String get vaultPublicationCitation => 'Cita bibliográfica (opcional)';

  @override
  String get vaultPublicationCitationHint =>
      'p. ej. Trujillo, L. (2021). Nombre de la revista, 11(2), 194–206.';

  @override
  String get vaultPublicationLink => 'Enlace (opcional)';

  @override
  String get vaultPublicationLinkHint => 'p. ej. doi.org/10.1234/ejemplo';

  @override
  String get vaultPublicationNew => 'Nueva publicación';

  @override
  String get vaultPublicationTitle => 'Título';

  @override
  String get vaultPublicationTitleHint =>
      'p. ej. Resistencia comunitaria en Doña Juana';

  @override
  String vaultQualificationAtInstitution(
    String qualification,
    String institution,
  ) {
    return '$qualification · $institution';
  }

  @override
  String vaultRoleAtCompany(String role, String company) {
    return '$role · $company';
  }

  @override
  String get vaultSearch => 'Busca en tu Bóveda…';

  @override
  String get vaultSectionAboutYou => 'Sobre ti';

  @override
  String vaultSectionCvDefaults(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'resume': 'Valores por defecto del résumé',
      'other': 'Valores por defecto del CV',
    });
    return '$_temp0';
  }

  @override
  String get vaultSectionEducation => 'Formación académica';

  @override
  String get vaultSectionExperience => 'Experiencia laboral';

  @override
  String get vaultSectionHobbies => 'Intereses y pasatiempos';

  @override
  String get vaultSectionLanguages => 'Idiomas';

  @override
  String get vaultSectionProjects => 'Proyectos';

  @override
  String get vaultSectionPublications => 'Publicaciones';

  @override
  String get vaultSectionSkills => 'Habilidades';

  @override
  String vaultSkillLinkedBullets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vinculada a $count logros',
      one: 'Vinculada a 1 logro',
    );
    return '$_temp0';
  }

  @override
  String get vaultSkillLinkToBullets => 'Vincular con logros';

  @override
  String get vaultSkillNoBulletMatches =>
      'Ningún logro coincide con tu búsqueda.';

  @override
  String get vaultSkillsAddCategory => 'Agregar categoría';

  @override
  String get vaultSkillsAddSkill => 'Agregar habilidad';

  @override
  String get vaultSkillsCategories => 'Categorías';

  @override
  String get vaultSkillsCategoryName => 'Nombre de la categoría';

  @override
  String get vaultSkillsCategoryNameHint => 'p. ej. Lenguajes y frameworks';

  @override
  String get vaultSkillsDeleteCategory => 'Eliminar categoría';

  @override
  String get vaultSkillsDeleteSkill => 'Eliminar habilidad';

  @override
  String get vaultSkillSearchBullets => 'Buscar logros…';

  @override
  String vaultSkillsMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habilidades coincidentes',
      one: '1 habilidad coincidente',
    );
    return '$_temp0';
  }

  @override
  String get vaultSkillsNoCategories => 'Aún no hay categorías de habilidades.';

  @override
  String get vaultSkillsNoMatches =>
      'Ninguna habilidad coincide con tu búsqueda.';

  @override
  String get vaultSkillsSearch => 'Buscar habilidades…';

  @override
  String get vaultSkillsSkillLabel => 'Habilidad';

  @override
  String vaultSkillsSummary(int categories, int skills) {
    return '$categories categorías, $skills habilidades';
  }

  @override
  String get vaultSkillsTitle => 'Habilidades';

  @override
  String get vaultUntitledProject => 'Proyecto sin título';

  @override
  String get vaultUntitledPublication => 'Publicación sin título';

  @override
  String get vaultUntitledQualification => 'Formación sin título';

  @override
  String get vaultUntitledRole => 'Cargo sin título';

  @override
  String get vaultYearMonthClear => 'Borrar';

  @override
  String get vaultYearMonthEmpty => 'Elige una fecha';

  @override
  String get vaultYearMonthNextYear => 'Año siguiente';

  @override
  String get vaultYearMonthNextYears => 'Años posteriores';

  @override
  String get vaultYearMonthPickYear => 'Elegir un año';

  @override
  String get vaultYearMonthPreviousYear => 'Año anterior';

  @override
  String get vaultYearMonthPreviousYears => 'Años anteriores';
}
