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
        "en-US": "English (United States)",
        "en-GB": "English (United Kingdom)",
        "en-CA": "English (Canada)",
        "en-AU": "English (Australia)",
        "en-IN": "English (India)",
        "en-IE": "English (Ireland)",
        "en-NZ": "English (New Zealand)",
        "en-ZA": "English (South Africa)",
        "en-SA": "English (Saudi Arabia)",
        "en-AE": "English (UAE)",
        "en-SG": "English (Singapore)",
        "en-PH": "English (Philippines)",
        "en-ID": "English (Indonesia)",
        
        // Spanish variants
        "es-ES": "Spanish (Spain)",
        "es-MX": "Spanish (Mexico)",
        "es-US": "Spanish (United States)",
        "es-CO": "Spanish (Colombia)",
        "es-CL": "Spanish (Chile)",
        "es-419": "Spanish (Latin America)",
        
        // French variants
        "fr-FR": "French (France)",
        "fr-CA": "French (Canada)",
        "fr-BE": "French (Belgium)",
        "fr-CH": "French (Switzerland)",
        
        // German variants
        "de-DE": "German (Germany)",
        "de-AT": "German (Austria)",
        "de-CH": "German (Switzerland)",
        
        // Chinese variants
        "zh-CN": "Chinese Simplified (China)",
        "zh-TW": "Chinese Traditional (Taiwan)",
        "zh-HK": "Chinese Traditional (Hong Kong)",
        
        // Other Asian languages
        "ja-JP": "Japanese (Japan)",
        "ko-KR": "Korean (South Korea)",
        "yue-CN": "Cantonese (China)",
        
        // Portuguese variants
        "pt-BR": "Portuguese (Brazil)",
        "pt-PT": "Portuguese (Portugal)",
        
        // Italian variants
        "it-IT": "Italian (Italy)",
        "it-CH": "Italian (Switzerland)",
        
        // Arabic
        "ar-SA": "Arabic (Saudi Arabia)"
    ]
    
    static var models: [any TranscriptionModel] {
        return predefinedModels + CustomModelManager.shared.customModels
    }
    
    private static let predefinedModels: [any TranscriptionModel] = [
        // Native Apple Model
        NativeAppleModel(
            name: "apple-speech",
displayName: NSLocalizedString("Apple Speech", comment: "Apple Speech"),
description: NSLocalizedString("Uses the native Apple Speech framework for transcription. Requires macOS 26.", comment: "Uses the native Apple Speech framework for transcription. Requires macOS 26."),
            isMultilingualModel: true,
            supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .nativeApple)
        ),
         // Local Models
         LocalModel(
             name: "ggml-tiny",
displayName: NSLocalizedString("Tiny", comment: "Tiny"),
             size: "75 MiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Tiny model, fastest, least accurate", comment: "Tiny model, fastest, least accurate"),
             speed: 0.95,
             accuracy: 0.6,
             ramUsage: 0.3
         ),
         LocalModel(
             name: "ggml-tiny.en",
             displayName: "Tiny (English)",
             size: "75 MiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: false, provider: .local),
description: NSLocalizedString("Tiny model optimized for English, fastest, least accurate", comment: "Tiny model optimized for English, fastest, least accurate"),
             speed: 0.95,
             accuracy: 0.65,
             ramUsage: 0.3
         ),
         LocalModel(
             name: "ggml-base",
displayName: NSLocalizedString("Base", comment: "Base"),
             size: "142 MiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Base model, good balance between speed and accuracy, supports multiple languages", comment: "Base model, good balance between speed and accuracy, supports multiple languages"),
             speed: 0.85,
             accuracy: 0.72,
             ramUsage: 0.5
         ),
         LocalModel(
             name: "ggml-base.en",
             displayName: "Base (English)",
             size: "142 MiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: false, provider: .local),
description: NSLocalizedString("Base model optimized for English, good balance between speed and accuracy", comment: "Base model optimized for English, good balance between speed and accuracy"),
             speed: 0.85,
             accuracy: 0.75,
             ramUsage: 0.5
         ),
         LocalModel(
             name: "ggml-large-v2",
             displayName: "Large v2",
             size: "2.9 GiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Large model v2, slower than Medium but more accurate", comment: "Large model v2, slower than Medium but more accurate"),
             speed: 0.3,
             accuracy: 0.96,
             ramUsage: 3.8
         ),
         LocalModel(
             name: "ggml-large-v3",
             displayName: "Large v3",
             size: "2.9 GiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Large model v3, very slow but most accurate", comment: "Large model v3, very slow but most accurate"),
             speed: 0.3,
             accuracy: 0.98,
             ramUsage: 3.9
         ),
         LocalModel(
             name: "ggml-large-v3-turbo",
             displayName: "Large v3 Turbo",
             size: "1.5 GiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
             description:
NSLocalizedString("Large model v3 Turbo, faster than v3 with similar accuracy", comment: "Large model v3 Turbo, faster than v3 with similar accuracy"),
             speed: 0.75,
             accuracy: 0.97,
             ramUsage: 1.8
         ),
         LocalModel(
             name: "ggml-large-v3-turbo-q5_0",
             displayName: "Large v3 Turbo (Quantized)",
             size: "547 MiB",
             supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .local),
description: NSLocalizedString("Quantized version of Large v3 Turbo, faster with slightly lower accuracy", comment: "Quantized version of Large v3 Turbo, faster with slightly lower accuracy"),
             speed: 0.75,
             accuracy: 0.95,
             ramUsage: 1.0
         ),
         
                 // Cloud Models
        CloudModel(
            name: "whisper-large-v3-turbo",
            displayName: "Whisper Large v3 Turbo (Groq)",
description: NSLocalizedString("Whisper Large v3 Turbo model with Groq's lightning-speed inference", comment: "Whisper Large v3 Turbo model with Groq's lightning-speed inference"),
            provider: .groq,
            speed: 0.65,
            accuracy: 0.96,
            isMultilingual: true,
            supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .groq)
        ),
        CloudModel(
           name: "scribe_v1",
           displayName: "Scribe v1 (ElevenLabs)",
description: NSLocalizedString("ElevenLabs' Scribe model for fast and accurate transcription.", comment: "ElevenLabs' Scribe model for fast and accurate transcription."),
           provider: .elevenLabs,
           speed: 0.7,
           accuracy: 0.98,
           isMultilingual: true,
           supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .elevenLabs)
       ),
       CloudModel(
           name: "nova-2",
           displayName: "Nova (Deepgram)",
description: NSLocalizedString("Deepgram's Nova model for fast, accurate, and cost-effective transcription.", comment: "Deepgram's Nova model for fast, accurate, and cost-effective transcription."),
           provider: .deepgram,
           speed: 0.9,
           accuracy: 0.95,
           isMultilingual: true,
           supportedLanguages: getLanguageDictionary(isMultilingual: true, provider: .deepgram)
       ),
        CloudModel(
            name: "voxtral-mini-2507",
            displayName: "Voxtral Mini (Mistral)",
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
         "bo": "Tibetan",
         "br": "Breton",
         "bs": "Bosnian",
         "ca": "Catalan",
"cs": NSLocalizedString("Czech", comment: "Czech"),
         "cy": "Welsh",
"da": NSLocalizedString("Danish", comment: "Danish"),
"de": NSLocalizedString("German", comment: "German"),
"el": NSLocalizedString("Greek", comment: "Greek"),
"en": NSLocalizedString("English", comment: "English"),
"es": NSLocalizedString("Spanish", comment: "Spanish"),
         "et": "Estonian",
         "eu": "Basque",
         "fa": "Persian",
"fi": NSLocalizedString("Finnish", comment: "Finnish"),
         "fo": "Faroese",
"fr": NSLocalizedString("French", comment: "French"),
         "gl": "Galician",
         "gu": "Gujarati",
         "ha": "Hausa",
         "haw": "Hawaiian",
"he": NSLocalizedString("Hebrew", comment: "Hebrew"),
"hi": NSLocalizedString("Hindi", comment: "Hindi"),
"hr": NSLocalizedString("Croatian", comment: "Croatian"),
         "ht": "Haitian Creole",
"hu": NSLocalizedString("Hungarian", comment: "Hungarian"),
         "hy": "Armenian",
"id": NSLocalizedString("Indonesian", comment: "Indonesian"),
         "is": "Icelandic",
"it": NSLocalizedString("Italian", comment: "Italian"),
"ja": NSLocalizedString("Japanese", comment: "Japanese"),
         "jw": "Javanese",
         "ka": "Georgian",
         "kk": "Kazakh",
         "km": "Khmer",
         "kn": "Kannada",
"ko": NSLocalizedString("Korean", comment: "Korean"),
         "la": "Latin",
         "lb": "Luxembourgish",
         "ln": "Lingala",
         "lo": "Lao",
         "lt": "Lithuanian",
         "lv": "Latvian",
         "mg": "Malagasy",
         "mi": "Maori",
         "mk": "Macedonian",
         "ml": "Malayalam",
         "mn": "Mongolian",
         "mr": "Marathi",
"ms": NSLocalizedString("Malay", comment: "Malay"),
         "mt": "Maltese",
         "my": "Myanmar",
         "ne": "Nepali",
"nl": NSLocalizedString("Dutch", comment: "Dutch"),
         "nn": "Norwegian Nynorsk",
"no": NSLocalizedString("Norwegian", comment: "Norwegian"),
         "oc": "Occitan",
         "pa": "Punjabi",
"pl": NSLocalizedString("Polish", comment: "Polish"),
         "ps": "Pashto",
"pt": NSLocalizedString("Portuguese", comment: "Portuguese"),
"ro": NSLocalizedString("Romanian", comment: "Romanian"),
"ru": NSLocalizedString("Russian", comment: "Russian"),
         "sa": "Sanskrit",
         "sd": "Sindhi",
         "si": "Sinhala",
"sk": NSLocalizedString("Slovak", comment: "Slovak"),
         "sl": "Slovenian",
         "sn": "Shona",
         "so": "Somali",
         "sq": "Albanian",
         "sr": "Serbian",
         "su": "Sundanese",
"sv": NSLocalizedString("Swedish", comment: "Swedish"),
         "sw": "Swahili",
         "ta": "Tamil",
         "te": "Telugu",
         "tg": "Tajik",
"th": NSLocalizedString("Thai", comment: "Thai"),
         "tk": "Turkmen",
"tl": NSLocalizedString("Tagalog", comment: "Tagalog"),
"tr": NSLocalizedString("Turkish", comment: "Turkish"),
         "tt": "Tatar",
"uk": NSLocalizedString("Ukrainian", comment: "Ukrainian"),
"ur": NSLocalizedString("Urdu", comment: "Urdu"),
         "uz": "Uzbek",
"vi": NSLocalizedString("Vietnamese", comment: "Vietnamese"),
         "yi": "Yiddish",
         "yo": "Yoruba",
"yue": NSLocalizedString("Cantonese", comment: "Cantonese"),
"zh": NSLocalizedString("Chinese", comment: "Chinese"),
     ]
 }