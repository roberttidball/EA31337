#ifndef FXMACRODATA_MQH
#define FXMACRODATA_MQH

class FXMacroData {
 private:
  string api_key;
  string base_url;
  bool key_in_url;

  string Lower(string value) {
    StringToLower(value);
    return value;
  }

  // Percent-encodes a single URL component (RFC 3986).
  // Unreserved characters (A-Z a-z 0-9 - _ . ~) are kept; every other byte of
  // the UTF-8 representation is encoded as %XX.
  string Encode(string value) {
    string hex = "0123456789ABCDEF";
    string encoded = "";
    uchar bytes[];
    int count = StringToCharArray(value, bytes, 0, -1, CP_UTF8);
    for (int i = 0; i < count; i++) {
      uchar c = bytes[i];
      if (c == 0) {
        break;  // Terminating zero copied by StringToCharArray().
      }
      if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-' || c == '_' ||
          c == '.' || c == '~') {
        encoded += CharToString(c);
      } else {
        encoded += "%" + StringSubstr(hex, (int)(c >> 4), 1) + StringSubstr(hex, (int)(c & 0x0F), 1);
      }
    }
    return encoded;
  }

  string BuildUrl(string path) {
    string request_url = base_url + path;
    if (key_in_url && api_key != "") {
      request_url += "?api_key=" + Encode(api_key);
    }
    return request_url;
  }

 public:
  // key_in_query controls whether the API key is appended as ?api_key= to every
  // URL. Prefer key_in_query=false and pass Headers() to WebRequest() so the key
  // does not appear in URLs, logs or proxies.
  FXMacroData(string key = "", string url = "https://api.fxmacrodata.com/v1", bool key_in_query = true) {
    api_key = key;
    base_url = url;
    key_in_url = key_in_query;
    // Trim trailing separators so joining with a path yields exactly one "/".
    while (StringLen(base_url) > 0 && StringSubstr(base_url, StringLen(base_url) - 1, 1) == "/") {
      base_url = StringSubstr(base_url, 0, StringLen(base_url) - 1);
    }
  }

  // Request headers for WebRequest(), carrying the API key as X-API-Key.
  string Headers() { return api_key != "" ? "X-API-Key: " + api_key + "\r\n" : ""; }

  string DataCatalogue(string currency) { return BuildUrl("/data_catalogue/" + Encode(Lower(currency))); }
  string Announcements(string currency, string indicator) {
    return BuildUrl("/announcements/" + Encode(Lower(currency)) + "/" + Encode(indicator));
  }
  string Calendar(string currency) { return BuildUrl("/calendar/" + Encode(Lower(currency))); }
  string Predictions(string currency, string indicator) {
    return BuildUrl("/predictions/" + Encode(Lower(currency)) + "/" + Encode(indicator));
  }
  string Forex(string base, string quote) {
    return BuildUrl("/forex/" + Encode(Lower(base)) + "/" + Encode(Lower(quote)));
  }
  string Cot(string currency) { return BuildUrl("/cot/" + Encode(Lower(currency))); }
  string CommoditiesLatest() { return BuildUrl("/commodities/latest"); }
  string Commodity(string indicator) { return BuildUrl("/commodities/" + Encode(indicator)); }
  string Curves(string currency) { return BuildUrl("/curves/" + Encode(Lower(currency))); }
  string CurveProxies(string currency) { return BuildUrl("/curve_proxies/" + Encode(Lower(currency))); }
  string ForwardCurves(string currency) { return BuildUrl("/forward_curves/" + Encode(Lower(currency))); }
  string MarketSessions() { return BuildUrl("/market_sessions"); }
  string RiskSentiment() { return BuildUrl("/risk_sentiment"); }
  string News(string currency) { return BuildUrl("/news/" + Encode(Lower(currency))); }
  string PressReleases(string currency) { return BuildUrl("/press-releases/" + Encode(Lower(currency))); }
  string CentralBankers(string currency) { return BuildUrl("/central_bankers/" + Encode(Lower(currency))); }
};

#endif
