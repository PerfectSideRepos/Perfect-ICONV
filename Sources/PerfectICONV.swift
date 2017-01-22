import iconv

/// class Iconv
public class Iconv {

  /// exceptions
  public enum Exception: Error {

    /// initialization fault
    case INVALID_ENCODING
  }//end enum

  /// iconv library handle
  internal var cd: iconv_t? = nil

  /// constructor of iconv
  /// - parameters:
  ///   - from: representable string, the original encoding
  ///   - to: representable string, the destinated encoding
  public init(from: CodePage = .GB2312, to: CodePage = .UTF_8) throws {
    cd = iconv_open(to.rawValue, from.rawValue)
    guard cd?.hashValue != -1 else {
      throw Exception.INVALID_ENCODING
    }//end guard
  }//end init

  /// destructor
  deinit {
    guard let handle = cd else {
      return
    }//end
    iconv_close(handle)
  }//end init

  /// convert a buffer to a new one, must release after calling
  /// - parameters:
  ///   - buf: input buffer
  ///   - length: input length
  /// - returns:
  ///   a tuple with output buffer pointer and size
  @discardableResult
  public func convert(buf: UnsafePointer<Int8>, length: Int) -> (UnsafeMutablePointer<Int8>?, Int) {

    // prepare larger buffers
    let cap = length * 2
    let src = UnsafeMutablePointer<Int8>.allocate(capacity: cap)
    let tag = UnsafeMutablePointer<Int8>.allocate(capacity: cap)

    // clean the buffers
    memset(src, 0, cap)
    memset(tag, 0, cap)

    // copy the buffer
    memcpy(src, buf, length)

    // *NOTE* MUST DUPLICATE POINTERS
    var pa: UnsafeMutablePointer<Int8>? = src
    var pb: UnsafeMutablePointer<Int8>? = tag

    // prepare length indicators
    var sza = length
    var szb = cap

    // perform transit
    let r = iconv(cd, &pa, &sza, &pb, &szb)

    // free the source buffer
    src.deallocate(capacity: cap)

    // deal with exceptions
    guard r != -1 else {
      tag.deinitialize()
      tag.deallocate(capacity: cap)
      return (nil, 0)
    }//end guard

    // return the output buffer and its size
    return (tag, cap - szb)
  }//end func

  /// a safer version of conversion
  /// - parameters:
  ///   - buf: input buffer
  ///  - returns:
  ///   output buffer
  @discardableResult
  public func convert (buf: [Int8]) -> [Int8] {
    var pointer: UnsafeMutablePointer<Int8>? = nil
    var sz = 0
    let _ = buf.withUnsafeBufferPointer{ (pointer, sz) = convert(buf: $0.baseAddress!, length: buf.count) }
    guard let p = pointer else {
      return []
    }//end p
    let buffer = UnsafeBufferPointer(start: p, count: sz)
    let res = Array(buffer)
    p.deallocate(capacity: buf.count * 2)
    return res
  }//end convert

  /// a safer version of conversion
  /// - parameters:
  ///   - buf: input buffer
  ///  - returns:
  ///   output buffer
  @discardableResult
  public func convert (buf: [UInt8]) -> [UInt8] {
    let cbuf:[Int8] = buf.map { Int8(bitPattern: $0) }
    var pointer: UnsafeMutablePointer<Int8>? = nil
    var sz = 0
    let _ = cbuf.withUnsafeBufferPointer{ (pointer, sz) = convert(buf: $0.baseAddress!, length: buf.count) }
    guard let p = pointer else {
      return []
    }//end p
    let buffer = UnsafeBufferPointer(start: p, count: sz)
    let res = Array(buffer)
    p.deinitialize()
    return res.map { UInt8(bitPattern: $0) }
  }//end convert

  /// an express way to convert other coding buffer to a UTF8 string
  /// - parameters:
  ///   - buf: input buffer
  /// - returns:
  ///   a utf-8 string
  @discardableResult
  public func utf8(buf: [Int8]) -> String? {
    let p = convert(buf: buf)
    if p.isEmpty {
      return nil
    }//end if
    return String(validatingUTF8: p)
  }//end utf8

  /// an express way to convert other coding buffer to a UTF8 string
  /// - parameters:
  ///   - buf: input buffer
  /// - returns:
  ///   a utf-8 string
  @discardableResult
  public func utf8(buf: [UInt8]) -> String? {
    return utf8(buf: buf.map { Int8(bitPattern: $0) })
  }//end utf8

  public enum CodePage: String {
    case ANSI_X3_4_1968 = "ANSI_X3.4-1968"
    case ANSI_X3_4_1986 = "ANSI_X3.4-1986"
    case ASCII = "ASCII"
    case CP367 = "CP367"
    case IBM367 = "IBM367"
    case ISO_IR_6 = "ISO-IR-6"
    case ISO646_US = "ISO646-US"
    case ISO_646_IRV_1991 = "ISO_646.IRV:1991"
    case US = "US"
    case US_ASCII = "US-ASCII"
    case CSASCII = "CSASCII"
    case UTF_8 = "UTF-8"
    case UTF8 = "UTF8"
    case UTF_8_MAC = "UTF-8-MAC"
    case UTF8_MAC = "UTF8-MAC"
    case ISO_10646_UCS_2 = "ISO-10646-UCS-2"
    case UCS_2 = "UCS-2"
    case CSUNICODE = "CSUNICODE"
    case UCS_2BE = "UCS-2BE"
    case UNICODE_1_1 = "UNICODE-1-1"
    case UNICODEBIG = "UNICODEBIG"
    case CSUNICODE11 = "CSUNICODE11"
    case UCS_2LE = "UCS-2LE"
    case UNICODELITTLE = "UNICODELITTLE"
    case ISO_10646_UCS_4 = "ISO-10646-UCS-4"
    case UCS_4 = "UCS-4"
    case CSUCS4 = "CSUCS4"
    case UCS_4BE = "UCS-4BE"
    case UCS_4LE = "UCS-4LE"
    case UTF_16 = "UTF-16"
    case UTF_16BE = "UTF-16BE"
    case UTF_16LE = "UTF-16LE"
    case UTF_32 = "UTF-32"
    case UTF_32BE = "UTF-32BE"
    case UTF_32LE = "UTF-32LE"
    case UNICODE_1_1_UTF_7 = "UNICODE-1-1-UTF-7"
    case UTF_7 = "UTF-7"
    case CSUNICODE11UTF7 = "CSUNICODE11UTF7"
    case UCS_2_INTERNAL = "UCS-2-INTERNAL"
    case UCS_2_SWAPPED = "UCS-2-SWAPPED"
    case UCS_4_INTERNAL = "UCS-4-INTERNAL"
    case UCS_4_SWAPPED = "UCS-4-SWAPPED"
    case C99 = "C99"
    case JAVA = "JAVA"
    case CP819 = "CP819"
    case IBM819 = "IBM819"
    case ISO_8859_1 = "ISO-8859-1"
    case ISO_IR_100 = "ISO-IR-100"
    case ISO8859_1 = "ISO8859-1"
    case ISO_8859_1_1987 = "ISO_8859-1:1987"
    case L1 = "L1"
    case LATIN1 = "LATIN1"
    case CSISOLATIN1 = "CSISOLATIN1"
    case ISO_8859_2 = "ISO-8859-2"
    case ISO_IR_101 = "ISO-IR-101"
    case ISO8859_2 = "ISO8859-2"
    case ISO_8859_2_1987 = "ISO_8859-2:1987"
    case L2 = "L2"
    case LATIN2 = "LATIN2"
    case CSISOLATIN2 = "CSISOLATIN2"
    case ISO_8859_3 = "ISO-8859-3"
    case ISO_IR_109 = "ISO-IR-109"
    case ISO8859_3 = "ISO8859-3"
    case ISO_8859_3_1988 = "ISO_8859-3:1988"
    case L3 = "L3"
    case LATIN3 = "LATIN3"
    case CSISOLATIN3 = "CSISOLATIN3"
    case ISO_8859_4 = "ISO-8859-4"
    case ISO_IR_110 = "ISO-IR-110"
    case ISO8859_4 = "ISO8859-4"
    case ISO_8859_4_1988 = "ISO_8859-4:1988"
    case L4 = "L4"
    case LATIN4 = "LATIN4"
    case CSISOLATIN4 = "CSISOLATIN4"
    case CYRILLIC = "CYRILLIC"
    case ISO_8859_5 = "ISO-8859-5"
    case ISO_IR_144 = "ISO-IR-144"
    case ISO8859_5 = "ISO8859-5"
    case ISO_8859_5_1988 = "ISO_8859-5:1988"
    case CSISOLATINCYRILLIC = "CSISOLATINCYRILLIC"
    case ARABIC = "ARABIC"
    case ASMO_708 = "ASMO-708"
    case ECMA_114 = "ECMA-114"
    case ISO_8859_6 = "ISO-8859-6"
    case ISO_IR_127 = "ISO-IR-127"
    case ISO8859_6 = "ISO8859-6"
    case ISO_8859_6_1987 = "ISO_8859-6:1987"
    case CSISOLATINARABIC = "CSISOLATINARABIC"
    case ECMA_118 = "ECMA-118"
    case ELOT_928 = "ELOT_928"
    case GREEK = "GREEK"
    case GREEK8 = "GREEK8"
    case ISO_8859_7 = "ISO-8859-7"
    case ISO_IR_126 = "ISO-IR-126"
    case ISO8859_7 = "ISO8859-7"
    case ISO_8859_7_1987 = "ISO_8859-7:1987"
    case ISO_8859_7_2003 = "ISO_8859-7:2003"
    case CSISOLATINGREEK = "CSISOLATINGREEK"
    case HEBREW = "HEBREW"
    case ISO_8859_8 = "ISO-8859-8"
    case ISO_IR_138 = "ISO-IR-138"
    case ISO8859_8 = "ISO8859-8"
    case ISO_8859_8_1988 = "ISO_8859-8:1988"
    case CSISOLATINHEBREW = "CSISOLATINHEBREW"
    case ISO_8859_9 = "ISO-8859-9"
    case ISO_IR_148 = "ISO-IR-148"
    case ISO8859_9 = "ISO8859-9"
    case ISO_8859_9_1989 = "ISO_8859-9:1989"
    case L5 = "L5"
    case LATIN5 = "LATIN5"
    case CSISOLATIN5 = "CSISOLATIN5"
    case ISO_8859_10 = "ISO-8859-10"
    case ISO_IR_157 = "ISO-IR-157"
    case ISO8859_10 = "ISO8859-10"
    case ISO_8859_10_1992 = "ISO_8859-10:1992"
    case L6 = "L6"
    case LATIN6 = "LATIN6"
    case CSISOLATIN6 = "CSISOLATIN6"
    case ISO_8859_11 = "ISO-8859-11"
    case ISO8859_11 = "ISO8859-11"
    case ISO_8859_13 = "ISO-8859-13"
    case ISO_IR_179 = "ISO-IR-179"
    case ISO8859_13 = "ISO8859-13"
    case L7 = "L7"
    case LATIN7 = "LATIN7"
    case ISO_8859_14 = "ISO-8859-14"
    case ISO_CELTIC = "ISO-CELTIC"
    case ISO_IR_199 = "ISO-IR-199"
    case ISO8859_14 = "ISO8859-14"
    case ISO_8859_14_1998 = "ISO_8859-14:1998"
    case L8 = "L8"
    case LATIN8 = "LATIN8"
    case ISO_8859_15 = "ISO-8859-15"
    case ISO_IR_203 = "ISO-IR-203"
    case ISO8859_15 = "ISO8859-15"
    case ISO_8859_15_1998 = "ISO_8859-15:1998"
    case LATIN_9 = "LATIN-9"
    case ISO_8859_16 = "ISO-8859-16"
    case ISO_IR_226 = "ISO-IR-226"
    case ISO8859_16 = "ISO8859-16"
    case ISO_8859_16_2001 = "ISO_8859-16:2001"
    case L10 = "L10"
    case LATIN10 = "LATIN10"
    case KOI8_R = "KOI8-R"
    case CSKOI8R = "CSKOI8R"
    case KOI8_U = "KOI8-U"
    case KOI8_RU = "KOI8-RU"
    case CP1250 = "CP1250"
    case MS_EE = "MS-EE"
    case WINDOWS_1250 = "WINDOWS-1250"
    case CP1251 = "CP1251"
    case MS_CYRL = "MS-CYRL"
    case WINDOWS_1251 = "WINDOWS-1251"
    case CP1252 = "CP1252"
    case MS_ANSI = "MS-ANSI"
    case WINDOWS_1252 = "WINDOWS-1252"
    case CP1253 = "CP1253"
    case MS_GREEK = "MS-GREEK"
    case WINDOWS_1253 = "WINDOWS-1253"
    case CP1254 = "CP1254"
    case MS_TURK = "MS-TURK"
    case WINDOWS_1254 = "WINDOWS-1254"
    case CP1255 = "CP1255"
    case MS_HEBR = "MS-HEBR"
    case WINDOWS_1255 = "WINDOWS-1255"
    case CP1256 = "CP1256"
    case MS_ARAB = "MS-ARAB"
    case WINDOWS_1256 = "WINDOWS-1256"
    case CP1257 = "CP1257"
    case WINBALTRIM = "WINBALTRIM"
    case WINDOWS_1257 = "WINDOWS-1257"
    case CP1258 = "CP1258"
    case WINDOWS_1258 = "WINDOWS-1258"
    case _850 = "850"
    case CP850 = "CP850"
    case IBM850 = "IBM850"
    case CSPC850MULTILINGUAL = "CSPC850MULTILINGUAL"
    case _862 = "862"
    case CP862 = "CP862"
    case IBM862 = "IBM862"
    case CSPC862LATINHEBREW = "CSPC862LATINHEBREW"
    case _866 = "866"
    case CP866 = "CP866"
    case IBM866 = "IBM866"
    case CSIBM866 = "CSIBM866"
    case MAC = "MAC"
    case MACINTOSH = "MACINTOSH"
    case MACROMAN = "MACROMAN"
    case CSMACINTOSH = "CSMACINTOSH"
    case MACCENTRALEUROPE = "MACCENTRALEUROPE"
    case MACICELAND = "MACICELAND"
    case MACCROATIAN = "MACCROATIAN"
    case MACROMANIA = "MACROMANIA"
    case MACCYRILLIC = "MACCYRILLIC"
    case MACUKRAINE = "MACUKRAINE"
    case MACGREEK = "MACGREEK"
    case MACTURKISH = "MACTURKISH"
    case MACHEBREW = "MACHEBREW"
    case MACARABIC = "MACARABIC"
    case MACTHAI = "MACTHAI"
    case HP_ROMAN8 = "HP-ROMAN8"
    case R8 = "R8"
    case ROMAN8 = "ROMAN8"
    case CSHPROMAN8 = "CSHPROMAN8"
    case NEXTSTEP = "NEXTSTEP"
    case ARMSCII_8 = "ARMSCII-8"
    case GEORGIAN_ACADEMY = "GEORGIAN-ACADEMY"
    case GEORGIAN_PS = "GEORGIAN-PS"
    case KOI8_T = "KOI8-T"
    case CP154 = "CP154"
    case CYRILLIC_ASIAN = "CYRILLIC-ASIAN"
    case PT154 = "PT154"
    case PTCP154 = "PTCP154"
    case CSPTCP154 = "CSPTCP154"
    case MULELAO_1 = "MULELAO-1"
    case CP1133 = "CP1133"
    case IBM_CP1133 = "IBM-CP1133"
    case ISO_IR_166 = "ISO-IR-166"
    case TIS_620 = "TIS-620"
    case TIS620 = "TIS620"
    case TIS620_0 = "TIS620-0"
    case TIS620_2529_1 = "TIS620.2529-1"
    case TIS620_2533_0 = "TIS620.2533-0"
    case TIS620_2533_1 = "TIS620.2533-1"
    case CP874 = "CP874"
    case WINDOWS_874 = "WINDOWS-874"
    case VISCII = "VISCII"
    case VISCII1_1_1 = "VISCII1.1-1"
    case CSVISCII = "CSVISCII"
    case TCVN = "TCVN"
    case TCVN_5712 = "TCVN-5712"
    case TCVN5712_1 = "TCVN5712-1"
    case TCVN5712_1_1993 = "TCVN5712-1:1993"
    case ISO_IR_14 = "ISO-IR-14"
    case ISO646_JP = "ISO646-JP"
    case JIS_C6220_1969_RO = "JIS_C6220-1969-RO"
    case JP = "JP"
    case CSISO14JISC6220RO = "CSISO14JISC6220RO"
    case JISX0201_1976 = "JISX0201-1976"
    case JIS_X0201 = "JIS_X0201"
    case X0201 = "X0201"
    case CSHALFWIDTHKATAKANA = "CSHALFWIDTHKATAKANA"
    case ISO_IR_87 = "ISO-IR-87"
    case JIS0208 = "JIS0208"
    case JIS_C6226_1983 = "JIS_C6226-1983"
    case JIS_X0208 = "JIS_X0208"
    case JIS_X0208_1983 = "JIS_X0208-1983"
    case JIS_X0208_1990 = "JIS_X0208-1990"
    case X0208 = "X0208"
    case CSISO87JISX0208 = "CSISO87JISX0208"
    case ISO_IR_159 = "ISO-IR-159"
    case JIS_X0212 = "JIS_X0212"
    case JIS_X0212_1990 = "JIS_X0212-1990"
    case JIS_X0212_1990_0 = "JIS_X0212.1990-0"
    case X0212 = "X0212"
    case CSISO159JISX02121990 = "CSISO159JISX02121990"
    case CN = "CN"
    case GB_1988_80 = "GB_1988-80"
    case ISO_IR_57 = "ISO-IR-57"
    case ISO646_CN = "ISO646-CN"
    case CSISO57GB1988 = "CSISO57GB1988"
    case CHINESE = "CHINESE"
    case GB_2312_80 = "GB_2312-80"
    case ISO_IR_58 = "ISO-IR-58"
    case CSISO58GB231280 = "CSISO58GB231280"
    case CN_GB_ISOIR165 = "CN-GB-ISOIR165"
    case ISO_IR_165 = "ISO-IR-165"
    case ISO_IR_149 = "ISO-IR-149"
    case KOREAN = "KOREAN"
    case KSC_5601 = "KSC_5601"
    case KS_C_5601_1987 = "KS_C_5601-1987"
    case KS_C_5601_1989 = "KS_C_5601-1989"
    case CSKSC56011987 = "CSKSC56011987"
    case EUC_JP = "EUC-JP"
    case EUCJP = "EUCJP"
    case EXTENDED_UNIX_CODE_PACKED_FORMAT_FOR_JAPANESE = "EXTENDED_UNIX_CODE_PACKED_FORMAT_FOR_JAPANESE"
    case CSEUCPKDFMTJAPANESE = "CSEUCPKDFMTJAPANESE"
    case MS_KANJI = "MS_KANJI"
    case SHIFT_JIS = "SHIFT-JIS"
    case SJIS = "SJIS"
    case CSSHIFTJIS = "CSSHIFTJIS"
    case CP932 = "CP932"
    case ISO_2022_JP = "ISO-2022-JP"
    case CSISO2022JP = "CSISO2022JP"
    case ISO_2022_JP_1 = "ISO-2022-JP-1"
    case ISO_2022_JP_2 = "ISO-2022-JP-2"
    case CSISO2022JP2 = "CSISO2022JP2"
    case CN_GB = "CN-GB"
    case EUC_CN = "EUC-CN"
    case EUCCN = "EUCCN"
    case GB2312 = "GB2312"
    case CSGB2312 = "CSGB2312"
    case GBK = "GBK"
    case CP936 = "CP936"
    case MS936 = "MS936"
    case WINDOWS_936 = "WINDOWS-936"
    case GB18030 = "GB18030"
    case ISO_2022_CN = "ISO-2022-CN"
    case CSISO2022CN = "CSISO2022CN"
    case ISO_2022_CN_EXT = "ISO-2022-CN-EXT"
    case HZ = "HZ"
    case HZ_GB_2312 = "HZ-GB-2312"
    case EUC_TW = "EUC-TW"
    case EUCTW = "EUCTW"
    case CSEUCTW = "CSEUCTW"
    case BIG_5 = "BIG-5"
    case BIG_FIVE = "BIG-FIVE"
    case BIG5 = "BIG5"
    case BIGFIVE = "BIGFIVE"
    case CN_BIG5 = "CN-BIG5"
    case CSBIG5 = "CSBIG5"
    case CP950 = "CP950"
    case BIG5_HKSCS_1999 = "BIG5-HKSCS:1999"
    case BIG5_HKSCS_2001 = "BIG5-HKSCS:2001"
    case BIG5_HKSCS = "BIG5-HKSCS"
    case BIG5_HKSCS_2004 = "BIG5-HKSCS:2004"
    case BIG5HKSCS = "BIG5HKSCS"
    case EUC_KR = "EUC-KR"
    case EUCKR = "EUCKR"
    case CSEUCKR = "CSEUCKR"
    case CP949 = "CP949"
    case UHC = "UHC"
    case CP1361 = "CP1361"
    case JOHAB = "JOHAB"
    case ISO_2022_KR = "ISO-2022-KR"
    case CSISO2022KR = "CSISO2022KR"
    case CP856 = "CP856"
    case CP922 = "CP922"
    case CP943 = "CP943"
    case CP1046 = "CP1046"
    case CP1124 = "CP1124"
    case CP1129 = "CP1129"
    case CP1161 = "CP1161"
    case IBM_1161 = "IBM-1161"
    case IBM1161 = "IBM1161"
    case CSIBM1161 = "CSIBM1161"
    case CP1162 = "CP1162"
    case IBM_1162 = "IBM-1162"
    case IBM1162 = "IBM1162"
    case CSIBM1162 = "CSIBM1162"
    case CP1163 = "CP1163"
    case IBM_1163 = "IBM-1163"
    case IBM1163 = "IBM1163"
    case CSIBM1163 = "CSIBM1163"
    case DEC_KANJI = "DEC-KANJI"
    case DEC_HANYU = "DEC-HANYU"
    case _437 = "437"
    case CP437 = "CP437"
    case IBM437 = "IBM437"
    case CSPC8CODEPAGE437 = "CSPC8CODEPAGE437"
    case CP737 = "CP737"
    case CP775 = "CP775"
    case IBM775 = "IBM775"
    case CSPC775BALTIC = "CSPC775BALTIC"
    case _852 = "852"
    case CP852 = "CP852"
    case IBM852 = "IBM852"
    case CSPCP852 = "CSPCP852"
    case CP853 = "CP853"
    case _855 = "855"
    case CP855 = "CP855"
    case IBM855 = "IBM855"
    case CSIBM855 = "CSIBM855"
    case _857 = "857"
    case CP857 = "CP857"
    case IBM857 = "IBM857"
    case CSIBM857 = "CSIBM857"
    case CP858 = "CP858"
    case _860 = "860"
    case CP860 = "CP860"
    case IBM860 = "IBM860"
    case CSIBM860 = "CSIBM860"
    case _861 = "861"
    case CP_IS = "CP-IS"
    case CP861 = "CP861"
    case IBM861 = "IBM861"
    case CSIBM861 = "CSIBM861"
    case _863 = "863"
    case CP863 = "CP863"
    case IBM863 = "IBM863"
    case CSIBM863 = "CSIBM863"
    case CP864 = "CP864"
    case IBM864 = "IBM864"
    case CSIBM864 = "CSIBM864"
    case _865 = "865"
    case CP865 = "CP865"
    case IBM865 = "IBM865"
    case CSIBM865 = "CSIBM865"
    case _869 = "869"
    case CP_GR = "CP-GR"
    case CP869 = "CP869"
    case IBM869 = "IBM869"
    case CSIBM869 = "CSIBM869"
    case CP1125 = "CP1125"
    case EUC_JISX0213 = "EUC-JISX0213"
    case SHIFT_JISX0213 = "SHIFT_JISX0213"
    case ISO_2022_JP_3 = "ISO-2022-JP-3"
    case BIG5_2003 = "BIG5-2003"
    case ISO_IR_230 = "ISO-IR-230"
    case TDS565 = "TDS565"
    case ATARI = "ATARI"
    case ATARIST = "ATARIST"
    case RISCOS_LATIN1 = "RISCOS-LATIN1"
  }//end enum
}//end class
