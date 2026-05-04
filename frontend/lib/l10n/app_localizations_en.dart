// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'News App';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'Daily News';

  @override
  String get filterAll => 'All';

  @override
  String get filterFitnessNews => 'Fitness News';

  @override
  String get filterNews => 'News';

  @override
  String get filterCommunity => 'Community';

  @override
  String get searchHint => 'Search articles…';

  @override
  String get feedEmpty => 'No articles found.';

  @override
  String get semanticSearchUnavailable =>
      'Semantic search unavailable — showing keyword matches.';

  @override
  String get myArticlesTitle => 'My Articles';

  @override
  String get savedArticlesTitle => 'Saved Articles';

  @override
  String get articleDetailNotFound => 'Article not found.';

  @override
  String get articleDetailLoadError =>
      'Couldn\'t load article. Pull back and retry.';

  @override
  String get articleSavedSuccess => 'Article saved successfully.';

  @override
  String get newArticleTitle => 'New Article';

  @override
  String get editArticleTitle => 'Edit Article';

  @override
  String get saveDraftAction => 'Save Draft';

  @override
  String get publishedSnack => 'Published';

  @override
  String get savedSnack => 'Saved';

  @override
  String get publishingOverlay => 'Publishing your article…';

  @override
  String get deleteArticleTitle => 'Delete article?';

  @override
  String deleteArticleConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get deleteDraftTitle => 'Delete draft?';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get draftBadge => 'Draft';

  @override
  String get thumbnailPickerTitle => 'Pick a thumbnail';

  @override
  String get thumbnailFromGallery => 'From Gallery';

  @override
  String get thumbnailFromCamera => 'From Camera';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldTags => 'Tags';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get menuMyArticles => 'My Articles';

  @override
  String get menuSignOut => 'Sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageSystemSubtitle => 'Follow the device language';

  @override
  String get settingsPermissionsSection => 'Permissions used by this app';

  @override
  String get settingsPermissionsHelp =>
      'These permissions are requested only when needed for a specific feature.';

  @override
  String get permissionCameraTitle => 'Camera';

  @override
  String get permissionCameraReason =>
      'Take a photo to use as your article thumbnail.';

  @override
  String get permissionPhotosTitle => 'Photo Library';

  @override
  String get permissionPhotosReason =>
      'Choose an existing photo as your article thumbnail.';

  @override
  String get permissionInternetTitle => 'Internet';

  @override
  String get permissionInternetReason =>
      'Fetch news, sync your articles and run semantic search.';
}
