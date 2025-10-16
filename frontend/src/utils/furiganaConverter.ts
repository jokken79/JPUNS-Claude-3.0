// Utilidad para convertir nombres en romaji a furigana (katakana)
export const convertRomajiToFurigana = (romajiText: string): string => {
  if (!romajiText || !romajiText.trim()) {
    return '';
  }

  const normalizedInput = romajiText
    .normalize('NFKC')
    .replace(/[^A-Za-z\s\-']+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  if (!normalizedInput) {
    return '';
  }

  const manualWordMap: { [key: string]: string } = {
    'tu': 'トゥ', 'di': 'ディ', 'du': 'ドゥ', 'fa': 'ファ', 'fi': 'フィ',
    'fe': 'フェ', 'fo': 'フォ', 'je': 'ジェ', 'we': 'ウェ', 'wi': 'ウィ', 'anh': 'アン'
  };

  const basicRomajiToKatakana = (word: string): string => {
    const lowerWord = word.toLowerCase();
    
    if (manualWordMap[lowerWord]) {
      return manualWordMap[lowerWord];
    }

    let processed = lowerWord
      .replace(/nh$/g, 'n')
      .replace(/shi/g, 'シ').replace(/chi/g, 'チ').replace(/tsu/g, 'ツ')
      .replace(/fu/g, 'フ').replace(/ji/g, 'ジ').replace(/zu/g, 'ズ')
      .replace(/su/g, 'ス').replace(/ku/g, 'ク').replace(/tu/g, 'トゥ')
      .replace(/di/g, 'ディ').replace(/du/g, 'ドゥ');

    const syllableMap: { [key: string]: string } = {
      'a': 'ア', 'i': 'イ', 'u': 'ウ', 'e': 'エ', 'o': 'オ',
      'ka': 'カ', 'ki': 'キ', 'ku': 'ク', 'ke': 'ケ', 'ko': 'コ',
      'sa': 'サ', 'shi': 'シ', 'su': 'ス', 'se': 'セ', 'so': 'ソ',
      'ta': 'タ', 'chi': 'チ', 'tsu': 'ツ', 'te': 'テ', 'to': 'ト',
      'na': 'ナ', 'ni': 'ニ', 'nu': 'ヌ', 'ne': 'ネ', 'no': 'ノ',
      'ha': 'ハ', 'hi': 'ヒ', 'fu': 'フ', 'he': 'ヘ', 'ho': 'ホ',
      'ma': 'マ', 'mi': 'ミ', 'mu': 'ム', 'me': 'メ', 'mo': 'モ',
      'ya': 'ヤ', 'yu': 'ユ', 'yo': 'ヨ',
      'ra': 'ラ', 'ri': 'リ', 'ru': 'ル', 're': 'レ', 'ro': 'ロ',
      'wa': 'ワ', 'wo': 'ヲ', 'n': 'ン',
      'ga': 'ガ', 'gi': 'ギ', 'gu': 'グ', 'ge': 'ゲ', 'go': 'ゴ',
      'za': 'ザ', 'ji': 'ジ', 'zu': 'ズ', 'ze': 'ゼ', 'zo': 'ゾ',
      'da': 'ダ', 'di': 'ヂ', 'du': 'ヅ', 'de': 'デ', 'do': 'ド',
      'ba': 'バ', 'bi': 'ビ', 'bu': 'ブ', 'be': 'ベ', 'bo': 'ボ',
      'pa': 'パ', 'pi': 'ピ', 'pu': 'プ', 'pe': 'ペ', 'po': 'ポ',
      'kya': 'キャ', 'kyu': 'キュ', 'kyo': 'キョ',
      'sha': 'シャ', 'shu': 'シュ', 'sho': 'ショ',
      'cha': 'チャ', 'chu': 'チュ', 'cho': 'チョ',
      'nya': 'ニャ', 'nyu': 'ニュ', 'nyo': 'ニョ',
      'hya': 'ヒャ', 'hyu': 'ヒュ', 'hyo': 'ヒョ',
      'mya': 'ミャ', 'myu': 'ミュ', 'myo': 'ミョ',
      'rya': 'リャ', 'ryu': 'リュ', 'ryo': 'リョ',
      'gya': 'ギャ', 'gyu': 'ギュ', 'gyo': 'ギョ',
      'ja': 'ジャ', 'ju': 'ジュ', 'jo': 'ジョ',
      'bya': 'ビャ', 'byu': 'ビュ', 'byo': 'ビョ',
      'pya': 'ピャ', 'pyu': 'ピュ', 'pyo': 'ピョ'
    };

    for (const [romaji, katakana] of Object.entries(syllableMap)) {
      if (processed.includes(romaji)) {
        processed = processed.replace(new RegExp(romaji, 'g'), katakana);
      }
    }

    let result = '';
    for (let i = 0; i < processed.length; i++) {
      const char = processed[i];
      if (syllableMap[char]) {
        result += syllableMap[char];
      } else if (/[a-z]/.test(char)) {
        result += char;
      } else {
        result += char;
      }
    }

    return result;
  };

  const katakanaWords = normalizedInput.split(' ').map((word) => {
    if (!word) return '';
    
    const lowerWord = word.toLowerCase();
    if (manualWordMap[lowerWord]) {
      return manualWordMap[lowerWord];
    }

    let katakanaWord = basicRomajiToKatakana(word);

    if (word.includes('-')) {
      katakanaWord = katakanaWord.replace(/-/g, '・');
    }

    return katakanaWord;
  }).filter(Boolean);

  return katakanaWords.join('　');
};

// Función mejorada para detectar y convertir automáticamente nombres extranjeros en romaji
export const smartAutoUpdateFurigana = (nameValue: string): { furiganaValue: string; convertMessage: string } => {
  const value = (nameValue || '').trim();
  let convertMessage = '';
  let furiganaValue = '';

  if (!value) {
    return { furiganaValue: '', convertMessage: '' };
  }

  // Detectar si es principalmente romaji (más del 70% letras latinas)
  const latinCharCount = (value.match(/[A-Za-z]/g) || []).length;
  const totalChars = value.replace(/\s/g, '').length;
  const latinRatio = totalChars > 0 ? latinCharCount / totalChars : 0;

  // Si es principalmente romaji o completamente romaji, convertir a katakana
  if (latinRatio >= 0.7 || /^[A-Za-z\s'-]+$/.test(value)) {
    furiganaValue = convertRomajiToFurigana(value);
    convertMessage = 'ローマ字からフリガナに自動変換しました';
    
    console.log(`Conversión inteligente: "${value}" -> "${furiganaValue}" (ratio: ${latinRatio})`);
  }
  // Si el nombre contiene Kana, copiar directamente
  else if (/[\u3040-\u309F\u30A0-\u30FF]/.test(value)) {
    furiganaValue = value;
    convertMessage = 'カナをフリガナに設定しました';
  }
  // Si el nombre contiene Kanji, mantener como está
  else if (/[\u4E00-\u9FAF]/.test(value)) {
    furiganaValue = value;
    convertMessage = '漢字のフリガナを手動で確認してください';
  }
  else {
    furiganaValue = '';
    convertMessage = '';
  }

  return { furiganaValue, convertMessage };
};
