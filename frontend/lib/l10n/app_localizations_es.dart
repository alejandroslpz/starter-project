// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App de Noticias';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get homeTitle => 'Noticias del día';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterFitnessNews => 'Noticias fitness';

  @override
  String get filterNews => 'Noticias';

  @override
  String get filterCommunity => 'Comunidad';

  @override
  String get searchHint => 'Buscar artículos…';

  @override
  String get feedEmpty => 'No se encontraron artículos.';

  @override
  String get semanticSearchUnavailable =>
      'Búsqueda semántica no disponible — mostrando coincidencias por palabra clave.';

  @override
  String get myArticlesTitle => 'Mis artículos';

  @override
  String get savedArticlesTitle => 'Artículos guardados';

  @override
  String get articleDetailNotFound => 'Artículo no encontrado.';

  @override
  String get articleDetailLoadError =>
      'No se pudo cargar el artículo. Regresa e inténtalo de nuevo.';

  @override
  String get articleSavedSuccess => 'Artículo guardado correctamente.';

  @override
  String get newArticleTitle => 'Nuevo artículo';

  @override
  String get editArticleTitle => 'Editar artículo';

  @override
  String get saveDraftAction => 'Guardar borrador';

  @override
  String get publishedSnack => 'Publicado';

  @override
  String get savedSnack => 'Guardado';

  @override
  String get publishingOverlay => 'Publicando tu artículo…';

  @override
  String get deleteArticleTitle => '¿Eliminar artículo?';

  @override
  String deleteArticleConfirm(String title) {
    return '¿Seguro que quieres eliminar \"$title\"?';
  }

  @override
  String get deleteDraftTitle => '¿Eliminar borrador?';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get draftBadge => 'Borrador';

  @override
  String get thumbnailPickerTitle => 'Elige una miniatura';

  @override
  String get thumbnailFromGallery => 'Desde galería';

  @override
  String get thumbnailFromCamera => 'Desde cámara';

  @override
  String get fieldCategory => 'Categoría';

  @override
  String get fieldTags => 'Etiquetas';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get menuMyArticles => 'Mis artículos';

  @override
  String get menuSignOut => 'Cerrar sesión';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsLanguageSystemSubtitle =>
      'Seguir el idioma del dispositivo';

  @override
  String get settingsPermissionsSection => 'Permisos que usa la app';

  @override
  String get settingsPermissionsHelp =>
      'Estos permisos se solicitan solo cuando una función específica los necesita.';

  @override
  String get permissionCameraTitle => 'Cámara';

  @override
  String get permissionCameraReason =>
      'Tomar una foto para usarla como miniatura de tu artículo.';

  @override
  String get permissionPhotosTitle => 'Galería';

  @override
  String get permissionPhotosReason =>
      'Elegir una foto existente como miniatura de tu artículo.';

  @override
  String get permissionInternetTitle => 'Internet';

  @override
  String get permissionInternetReason =>
      'Obtener noticias, sincronizar tus artículos y realizar búsqueda semántica.';
}
