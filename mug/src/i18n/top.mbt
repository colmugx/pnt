///|
type Reader[Env, X] = @reader.Reader[Env, X]

///|
using @reader {asks}

///|
suberror I18NError {
  I18NError(String)
}

///|
priv struct I18nConfig {
  current_locale : Locale
  all_translations : Map[Locale, Translations]
}

///|
pub fn load_catalog() -> Map[Locale, Translations] raise I18NError {
  try {
    let zh_cn_json = @json.parse(zh_cn_text)
    let zh_cn_data : Translations = @json.from_json(zh_cn_json)
    let en_json = @json.parse(en_text)
    let en_data : Translations = @json.from_json(en_json)
    { "zh-CN": zh_cn_data, "en-US": en_data }
  } catch {
    _ => raise I18NError("Failed to load catalog")
  }
}

///|
fn get_locale() -> Reader[I18nConfig, Locale] {
  asks(fn(cfg) { cfg.current_locale })
}

///|
fn translate(key : TranslationKey) -> Reader[I18nConfig, TranslationValue?] {
  asks(fn(cfg) {
    let current_translations_option = cfg.all_translations.get(
      cfg.current_locale,
    )
    guard current_translations_option is Some(current_translations) else {
      None
    }
    current_translations.get(key)
  })
}

///|
fn translate_or_key(
  key : TranslationKey,
) -> Reader[I18nConfig, TranslationValue] {
  translate(key).map(fn(value) { value.unwrap_or(key) })
}

///|
test "translate_or_key/empty_key" {
  let config : I18nConfig = {
    current_locale: "en-US",
    all_translations: { "en-US": {}, "zh-CN": {} },
  }
  let reader = translate_or_key("")
  inspect(reader.run(config), content="")
}

///|
test "translate_or_key/special_characters_key" {
  let config : I18nConfig = {
    current_locale: "en-US",
    all_translations: {
      "en-US": { "special.characters!@#$%": "Special Translation" },
      "zh-CN": {},
    },
  }
  let reader = translate_or_key("special.characters!@#$%")
  inspect(reader.run(config), content="Special Translation")
}

///|
test "i18n functionality using Reader Monad" {
  let all_translations = load_catalog()
  let config_en : I18nConfig = { current_locale: "en-US", all_translations }
  let config_zh : I18nConfig = { current_locale: "zh-CN", all_translations }

  // test get_locale
  let locale_reader = get_locale()
  assert_eq(locale_reader.run(config_en), "en-US")
  assert_eq(locale_reader.run(config_zh), "zh-CN")

  // test translate
  let version_opt_reader = translate("version")
  let missing_opt_reader = translate("nonexistent.key")
  assert_eq(version_opt_reader.run(config_en), Some("Show version"))
  assert_eq(version_opt_reader.run(config_zh), Some("显示版本信息"))
  assert_eq(missing_opt_reader.run(config_en), None)
  assert_eq(missing_opt_reader.run(config_zh), None)

  // test translate_or_key
  let help_reader = translate_or_key("help")
  let help_en = help_reader.run(config_en)
  let help_zh = help_reader.run(config_zh)
  assert_eq(help_en, "Show help information")
  assert_eq(help_zh, "显示帮助信息")
  let missing_key_reader = translate_or_key("nonexistent.key")
  let missing_en = missing_key_reader.run(config_en)
  let missing_zh = missing_key_reader.run(config_zh)
  assert_eq(missing_en, "nonexistent.key")
  assert_eq(missing_zh, "nonexistent.key")
}
