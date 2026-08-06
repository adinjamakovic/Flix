import 'package:flix_desktop/models/language.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class LanguageProvider extends BaseProvider<Language> {
  LanguageProvider() : super("Language");

  @override
  Language fromJson(data) {
    return Language.fromJson(data);
  }
}
