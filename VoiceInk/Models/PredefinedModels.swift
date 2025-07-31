import Foundation
 
 enum PredefinedModels {
    static func getLanguageDictionary(isMultilingual: Bool, provider: ModelProvider = .local) -> [String: String] {
        if !isMultilingual {
return ["en": NSLocalizedString("English", comment: "English")]
        } else {
            // For Apple Native models, return only supported languages in simple format
            if provider == .nativeApple {
                let appleSupportedCodes = ["ar", "de", "en", "es", "fr", "it", "ja", "ko", "pt", "yue", "zh"]
                return allLanguages.filter { appleSupportedCodes.contains($0.key) }
            }
            return allLanguages
        }
    }
    
    // Apple Native Speech specific languages with proper BCP-47 format
    // Based on actual supported locales from SpeechTranscriber.supportedLocales
    static let appleNativeLanguages = [
        // English variants
        "en-US": NSLocalizedString("English (United States)", comment: "English (United States)"),
        "en-GB": NSLocalizedString("English (United Kingdom)", comment: "English (United Kingdom)"),
        "en-CA": NSLocalizedString("English (Canada)", comment: "English (Canada)"),
        "en-AU": NSLocalizedString("English (Australia)", comment: "English (Australia)"),
        "en-IN": NSLocalizedString("English (India)", comment: "English (India)"),
        "en-IE": NSLocalizedString("English (Ireland)", comment: "English (Ireland)"),
        "en-NZ": NSLocalizedString("English (New Zealand)", comment: "English (New Zealand)"),
        "en-ZA": NSLocalizedString("English (South Africa)", comment: "English (South Africa)"),
        "en-SA": NSLocalizedString("English (Saudi Arabia)", comment: "English (Saudi Arabia)"),
        "en-AE": NSLocalizedString("English (UAE)", comment: "English (UAE)"),
        "en-SG": NSLocalizedString("English (Singapore)", comment: "English (Singapore)"),
        "en-PH": NSLocalizedString("English (Philippines)", comment: "English (Philippines)"),
        "en-ID": NSLocalizedString("English (Indonesia)", comment: "English (Indonesia)"),
        
        // Spanish variants
        "es-ES": NSLocalizedString("Spanish (Spain)", comment: "Spanish (Spain)"),
        "es-MX": NSLocalizedString("Spanish (Mexico)", comment: "Spanish (Mexico)"),
        "es-US": NSLocalizedString("Spanish (United States)", comment: "Spanish (United States)"),
        "es-CO": NSLocalizedString("Spanish (Colombia)", comment: "Spanish (Colombia)"),
        "es-CL": NSLocalizedString("Spanish (Chile)", comment: "Spanish (Chile)"),
        "es-419": NSLocalizedString("Spanish (Latin America)", comment: "Spanish (Latin America)"),
        
        // French variants
        "fr-FR": NSLocalizedString("French (France)", comment: "French (France)"),
        "fr-CA": NSLocalizedString("French (Canada)", comment: "French (Canada)"),
        "fr-BE": NSLocalizedString("French (Belgium)", comment: "French (Belgium)"),
        "fr-CH": NSLocalizedString("French (Switzerland)", comment: "French (Switzerland)"),
        
        // German variants
        "de-DE": NSLocalizedString("German (Germany)", comment: "German (Germany)"),
        "de-AT": NSLocalizedString("German (Austria)", comment: "German (Austria)"),
        "de-CH": NSLocalizedString("German (Switzerland)", comment: "German (Switzerland)"),
        
        // Chinese variants
        "zh-CN": NSLocalizedString("Chinese Simplified (China)", comment: "Chinese Simplified (China)"),
        "zh-TW": NSLocalizedString("Chinese Traditional (Taiwan)", comment: "Chinese Traditional (Taiwan)"),
        "zh-HK": NSLocalizedString("Chinese Traditional (Hong Kong)", comment: "Chinese Traditional (Hong Kong)"),
        
        // Other Asian languages
        "ja-JP": NSLocalizedString("Japanese (Japan)", comment: "Japanese (Japan)"),
        "ko-KR": NSLocalizedString("Korean (South Korea)", comment: "Korean (South Korea)"),
        "yue-CN": NSLocalizedString("Cantonese (China)", comment: "Cantonese (China)"),
        
        // Portuguese variants
        "pt-BR": NSLocalizedString("Portuguese (Brazil)", comment: "Portuguese (Brazil)"),
        "pt-PT": NSLocalizedString("Portuguese (Portugal)", comment: "Portuguese (Portugal)"),
        
        // Italian variants
        "it-IT": NSLocalizedString("Italian (Italy)", comment: "Italian (Italy)"),
        "it-CH": NSLocalizedString("Italian (Switzerland)", comment: "Italian (Switzerland)"),
        
        // Arabic
        "ar-SA": "Arabic (Saudi Arabia)"
    ]
    
    static var models: [any TranscriptionModel] {
        return predefinedModels + CustomModelManager.shared.customModels
    }
    
    private static let predefinedModels: [any TranscriptionModel] = [
        // Native Apple Model
        NativeAppleModel(
            name: NSLocalizedString("apple-speech", comment: "apple-speech"),
displayName: NSLocalizedString("Apple Speech", comment: "Apple Speech"),
description: NSLocalizedString("Uses the native Apple Speech framework for transcription. Requires macOS 26.", comment: "Uses the native Apple Speech framework for transcription. Requires macOS 26."),
            isMultilingualModel: true,
            supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .nativeApple)
        ),
         // Local Models
         LocalModel(
             name: NSLocalizedString("ggml-tiny", comment: "ggml-tiny"),
displayName: NSLocalizedString("Tiny", comment: "Tiny"),
             size: NSLocalizedString(NSLocalizedString("75 MiB", comment: "75 MiB"), comment: "75 MiB"),
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Tiny model, fastest, least accurate", comment: "Tiny model, fastest, least accurate"),
             speed: 0.95,
             accuracy: 0.6,
             ramUsage: 0.3
         ),
         LocalModel(
             name: "ggml-tiny.en",
             displayName: NSLocalizedString("Tiny (English)", comment: "Tiny (English)"),
             size: "75 MiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: false, provider: .local),
description: NSLocalizedString("Tiny model optimized for English, fastest, least accurate", comment: "Tiny model optimized for English, fastest, least accurate"),
             speed: 0.95,
             accuracy: 0.65,
             ramUsage: 0.3
         ),
         LocalModel(
             name: NSLocalizedString("ggml-base", comment: "ggml-base"),
displayName: NSLocalizedString("Base", comment: "Base"),
             size: NSLocalizedString(NSLocalizedString("142 MiB", comment: "142 MiB"), comment: "142 MiB"),
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Base model, good balance between speed and accuracy, supports multiple languages", comment: "Base model, good balance between speed and accuracy, supports multiple languages"),
             speed: 0.85,
             accuracy: 0.72,
             ramUsage: 0.5
         ),
         LocalModel(
             name: "ggml-base.en",
             displayName: NSLocalizedString("Base (English)", comment: "Base (English)"),
             size: "142 MiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: false, provider: .local),
description: NSLocalizedString("Base model optimized for English, good balance between speed and accuracy", comment: "Base model optimized for English, good balance between speed and accuracy"),
             speed: 0.85,
             accuracy: 0.75,
             ramUsage: 0.5
         ),
         LocalModel(
             name: NSLocalizedString("ggml-large-v2", comment: "ggml-large-v2"),
             displayName: NSLocalizedString("Large v2", comment: "Large v2"),
             size: NSLocalizedString(NSLocalizedString("2.9 GiB", comment: "2.9 GiB"), comment: "2.9 GiB"),
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Large model v2, slower than Medium but more accurate", comment: "Large model v2, slower than Medium but more accurate"),
             speed: 0.3,
             accuracy: 0.96,
             ramUsage: 3.8
         ),
         LocalModel(
             name: NSLocalizedString("ggml-large-v3", comment: "ggml-large-v3"),
             displayName: NSLocalizedString("Large v3", comment: "Large v3"),
             size: "2.9 GiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Large model v3, very slow but most accurate", comment: "Large model v3, very slow but most accurate"),
             speed: 0.3,
             accuracy: 0.98,
             ramUsage: 3.9
         ),
         LocalModel(
             name: NSLocalizedString("ggml-large-v3-turbo", comment: "ggml-large-v3-turbo"),
             displayName: NSLocalizedString("Large v3 Turbo", comment: "Large v3 Turbo"),
             size: NSLocalizedString("1.5 GiB", comment: "1.5 GiB"),
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
             description:
NSLocalizedString("Large model v3 Turbo, faster than v3 with similar accuracy", comment: "Large model v3 Turbo, faster than v3 with similar accuracy"),
             speed: 0.75,
             accuracy: 0.97,
             ramUsage: 1.8
         ),
         LocalModel(
             name: NSLocalizedString("ggml-large-v3-turbo-q5_0", comment: "ggml-large-v3-turbo-q5_0"),
             displayName: NSLocalizedString("Large v3 Turbo (Quantized)", comment: "Large v3 Turbo (Quantized)"),
             size: NSLocalizedString("547 MiB", comment: "547 MiB"),
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Quantized version of Large v3 Turbo, faster with slightly lower accuracy", comment: "Quantized version of Large v3 Turbo, faster with slightly lower accuracy"),
             speed: 0.75,
             accuracy: 0.95,
             ramUsage: 1.0
         ),
         
                 // Cloud Models
        CloudModel(
            name: NSLocalizedString("whisper-large-v3-turbo", comment: "whisper-large-v3-turbo"),
            displayName: NSLocalizedString("Whisper Large v3 Turbo (Groq)", comment: "Whisper Large v3 Turbo (Groq)"),
description: NSLocalizedString("Whisper Large v3 Turbo model with Groq's lightning-speed inference", comment: "Whisper Large v3 Turbo model with Groq's lightning-speed inference"),
            provider: .groq,
            speed: 0.65,
            accuracy: 0.96,
            isMultilingual: true,
            supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .groq)
        ),
        CloudModel(
           name: "scribe_v1",
           displayName: NSLocalizedString("Scribe v1 (ElevenLabs)", comment: "Scribe v1 (ElevenLabs)"),
description: NSLocalizedString("ElevenLabs' Scribe model for fast and accurate transcription.", comment: "ElevenLabs' Scribe model for fast and accurate transcription."),
           provider: .elevenLabs,
           speed: 0.7,
           accuracy: 0.98,
           isMultilingual: true,
           supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .elevenLabs)
       ),
       CloudModel(
           name: NSLocalizedString("nova-2", comment: "nova-2"),
           displayName: NSLocalizedString("Nova (Deepgram)", comment: "Nova (Deepgram)"),
description: NSLocalizedString("Deepgram's Nova model for fast, accurate, and cost-effective transcription.", comment: "Deepgram's Nova model for fast, accurate, and cost-effective transcription."),
           provider: .deepgram,
           speed: 0.9,
           accuracy: 0.95,
           isMultilingual: true,
           supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .deepgram)
       ),
        CloudModel(
            name: NSLocalizedString("voxtral-mini-2507", comment: "voxtral-mini-2507"),
            displayName: NSLocalizedString("Voxtral Mini (Mistral)", comment: "Voxtral Mini (Mistral)"),
description: NSLocalizedString("Mistral's latest SOTA transcription model.", comment: "Mistral's latest SOTA transcription model."),
            provider: .mistral,
            speed: 0.8,
            accuracy: 0.97,
            isMultilingual: true,
            supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .mistral)
        )
     ]
 
     static let allLanguages = [
"auto": NSLocalizedString("Auto-detect", comment: "Auto-detect"),
"af": NSLocalizedString("Afrikaans", comment: "Afrikaans"),
"am": NSLocalizedString("Amharic", comment: "Amharic"),
"ar": NSLocalizedString("Arabic", comment: "Arabic"),
"as": NSLocalizedString("Assamese", comment: "Assamese"),
"az": NSLocalizedString("Azerbaijani", comment: "Azerbaijani"),
"ba": NSLocalizedString("Bashkir", comment: "Bashkir"),
"be": NSLocalizedString("Belarusian", comment: "Belarusian"),
"bg": NSLocalizedString("Bulgarian", comment: "Bulgarian"),
"bn": NSLocalizedString("Bengali", comment: "Bengali"),
         "bo": NSLocalizedString("Tibetan", comment: "Tibetan"),
         "br": NSLocalizedString("Breton", comment: "Breton"),
         "bs": NSLocalizedString("Bosnian", comment: "Bosnian"),
         "ca": NSLocalizedString("Catalan", comment: "Catalan"),
"cs": NSLocalizedString("Czech", comment: "Czech"),
         "cy": NSLocalizedString("Welsh", comment: "Welsh"),
"da": NSLocalizedString("Danish", comment: "Danish"),
"de": NSLocalizedString("German", comment: "German"),
"el": NSLocalizedString("Greek", comment: "Greek"),
"en": NSLocalizedString("English", comment: "English"),
"es": NSLocalizedString("Spanish", comment: "Spanish"),
         "et": NSLocalizedString("Estonian", comment: "Estonian"),
         "eu": NSLocalizedString("Basque", comment: "Basque"),
         "fa": NSLocalizedString("Persian", comment: "Persian"),
"fi": NSLocalizedString("Finnish", comment: "Finnish"),
         "fo": NSLocalizedString("Faroese", comment: "Faroese"),
"fr": NSLocalizedString("French", comment: "French"),
         "gl": NSLocalizedString("Galician", comment: "Galician"),
         "gu": NSLocalizedString("Gujarati", comment: "Gujarati"),
         "ha": NSLocalizedString("Hausa", comment: "Hausa"),
         "haw": NSLocalizedString("Hawaiian", comment: "Hawaiian"),
"he": NSLocalizedString("Hebrew", comment: "Hebrew"),
"hi": NSLocalizedString("Hindi", comment: "Hindi"),
"hr": NSLocalizedString("Croatian", comment: "Croatian"),
         "ht": NSLocalizedString("Haitian Creole", comment: "Haitian Creole"),
"hu": NSLocalizedString("Hungarian", comment: "Hungarian"),
         "hy": NSLocalizedString("Armenian", comment: "Armenian"),
"id": NSLocalizedString("Indonesian", comment: "Indonesian"),
         "is": NSLocalizedString("Icelandic", comment: "Icelandic"),
"it": NSLocalizedString("Italian", comment: "Italian"),
"ja": NSLocalizedString("Japanese", comment: "Japanese"),
         "jw": NSLocalizedString("Javanese", comment: "Javanese"),
         "ka": NSLocalizedString("Georgian", comment: "Georgian"),
         "kk": NSLocalizedString("Kazakh", comment: "Kazakh"),
         "km": NSLocalizedString("Khmer", comment: "Khmer"),
         "kn": NSLocalizedString("Kannada", comment: "Kannada"),
"ko": NSLocalizedString("Korean", comment: "Korean"),
         "la": NSLocalizedString("Latin", comment: "Latin"),
         "lb": NSLocalizedString("Luxembourgish", comment: "Luxembourgish"),
         "ln": NSLocalizedString("Lingala", comment: "Lingala"),
         "lo": NSLocalizedString("Lao", comment: "Lao"),
         "lt": NSLocalizedString("Lithuanian", comment: "Lithuanian"),
         "lv": NSLocalizedString("Latvian", comment: "Latvian"),
         "mg": NSLocalizedString("Malagasy", comment: "Malagasy"),
         "mi": NSLocalizedString("Maori", comment: "Maori"),
         "mk": NSLocalizedString("Macedonian", comment: "Macedonian"),
         "ml": NSLocalizedString("Malayalam", comment: "Malayalam"),
         "mn": NSLocalizedString("Mongolian", comment: "Mongolian"),
         "mr": NSLocalizedString("Marathi", comment: "Marathi"),
"ms": NSLocalizedString("Malay", comment: "Malay"),
         "mt": NSLocalizedString("Maltese", comment: "Maltese"),
         "my": NSLocalizedString("Myanmar", comment: "Myanmar"),
         "ne": NSLocalizedString("Nepali", comment: "Nepali"),
"nl": NSLocalizedString("Dutch", comment: "Dutch"),
         "nn": NSLocalizedString("Norwegian Nynorsk", comment: "Norwegian Nynorsk"),
"no": NSLocalizedString("Norwegian", comment: "Norwegian"),
         "oc": NSLocalizedString("Occitan", comment: "Occitan"),
         "pa": NSLocalizedString("Punjabi", comment: "Punjabi"),
"pl": NSLocalizedString("Polish", comment: "Polish"),
         "ps": NSLocalizedString("Pashto", comment: "Pashto"),
"pt": NSLocalizedString("Portuguese", comment: "Portuguese"),
"ro": NSLocalizedString("Romanian", comment: "Romanian"),
"ru": NSLocalizedString("Russian", comment: "Russian"),
         "sa": NSLocalizedString("Sanskrit", comment: "Sanskrit"),
         "sd": NSLocalizedString("Sindhi", comment: "Sindhi"),
         "si": NSLocalizedString("Sinhala", comment: "Sinhala"),
"sk": NSLocalizedString("Slovak", comment: "Slovak"),
         "sl": NSLocalizedString("Slovenian", comment: "Slovenian"),
         "sn": NSLocalizedString("Shona", comment: "Shona"),
         "so": NSLocalizedString("Somali", comment: "Somali"),
         "sq": NSLocalizedString("Albanian", comment: "Albanian"),
         "sr": NSLocalizedString("Serbian", comment: "Serbian"),
         "su": NSLocalizedString("Sundanese", comment: "Sundanese"),
"sv": NSLocalizedString("Swedish", comment: "Swedish"),
         "sw": NSLocalizedString("Swahili", comment: "Swahili"),
         "ta": NSLocalizedString("Tamil", comment: "Tamil"),
         "te": NSLocalizedString("Telugu", comment: "Telugu"),
         "tg": NSLocalizedString("Tajik", comment: "Tajik"),
"th": NSLocalizedString("Thai", comment: "Thai"),
         "tk": NSLocalizedString("Turkmen", comment: "Turkmen"),
"tl": NSLocalizedString("Tagalog", comment: "Tagalog"),
"tr": NSLocalizedString("Turkish", comment: "Turkish"),
         "tt": NSLocalizedString("Tatar", comment: "Tatar"),
"uk": NSLocalizedString("Ukrainian", comment: "Ukrainian"),
"ur": NSLocalizedString("Urdu", comment: "Urdu"),
         "uz": NSLocalizedString("Uzbek", comment: "Uzbek"),
"vi": NSLocalizedString("Vietnamese", comment: "Vietnamese"),
         "yi": NSLocalizedString("Yiddish", comment: "Yiddish"),
         "yo": NSLocalizedString("Yoruba", comment: "Yoruba"),
"yue": NSLocalizedString("Cantonese", comment: "Cantonese"),
"zh": NSLocalizedString("Chinese", comment: "Chinese"),
     ]
 }
