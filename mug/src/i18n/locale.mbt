///|
/// Locale detection utilities
/// Detects system locale from environment variables

///|
/// Detect system locale from environment
/// Priority: LC_ALL > LANG > LC_MESSAGES
/// Returns locale in format like "zh-CN", "en-US"
pub fn detect_locale() -> String {
  // Try LC_ALL first (highest priority)
  let lc_all = get_env("LC_ALL")
  match lc_all {
    Some(val) => {
      let parsed = parse_locale_string(val)
      if parsed != "" {
        return parsed
      }
    }
    None => ()
  }

  // Try LANG
  let lang = get_env("LANG")
  match lang {
    Some(val) => {
      let parsed = parse_locale_string(val)
      if parsed != "" {
        return parsed
      }
    }
    None => ()
  }

  // Try LC_MESSAGES
  let lc_messages = get_env("LC_MESSAGES")
  match lc_messages {
    Some(val) => {
      let parsed = parse_locale_string(val)
      if parsed != "" {
        return parsed
      }
    }
    None => ()
  }

  // Default to English
  "en-US"
}

///|
/// Parse locale string from environment variable
/// Examples:
///   "zh_CN.UTF-8" -> "zh-CN"
///   "en_US.UTF-8" -> "en-US"
///   "en" -> "en-US"
fn parse_locale_string(env_val : String) -> String {
  // Remove encoding (e.g., .UTF-8)
  let without_encoding = split_char(env_val, '.')
  let locale_part = if without_encoding.length() > 0 {
    without_encoding[0]
  } else {
    env_val
  }

  // Parse locale (e.g., zh_CN -> zh-CN)
  let parts = split_char(locale_part, '_')
  if parts.length() == 2 {
    let lang = parts[0]
    let country = parts[1]
    "\{lang}-\{country}"
  } else if parts.length() == 1 && parts[0].length() > 0 {
    // Only language code, add default country
    let lang = parts[0]
    map_to_full_locale(lang)
  } else {
    ""
  }
}

///|
/// Map short locale codes to full locales
fn map_to_full_locale(lang : String) -> String {
  match lang {
    "zh" => "zh-CN"
    "en" => "en-US"
    "ja" => "ja-JP"
    "ko" => "ko-KR"
    "fr" => "fr-FR"
    "de" => "de-DE"
    "es" => "es-ES"
    _ => "\{lang}-\{lang}"  // Fallback: en -> en-en
  }
}

///|
/// Split string by character (simple implementation)
fn split_char(s : String, c : Char) -> Array[String] {
  let result : Array[String] = []
  let mut current = ""
  let mut i = 0

  while i < s.length() {
    let char_code = s[i]
    if char_code.to_int() == c.to_int() {
      if current != "" {
        result.push(current)
      }
      current = ""
    } else {
      current = current + char_code.to_string()
    }
    i = i + 1
  }

  if current != "" {
    result.push(current)
  }

  result
}

///|
/// Get environment variable (placeholder for now)
/// TODO: Implement actual environment variable access via FFI
fn get_env(name : String) -> String? {
  // For now, return None
  // In the future, this should use FFI to read environment variables
  // TODO: Add FFI binding to getenv()
  None
}
