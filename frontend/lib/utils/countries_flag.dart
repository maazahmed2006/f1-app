class Flags{
  static const Map<String, String> f1CountryFlags = {
    'Australia':   'https://www.worldometers.info/img/flags/as-flag.gif',
    'China':       'https://www.worldometers.info/img/flags/ch-flag.gif',
    'Japan':       'https://www.worldometers.info/img/flags/ja-flag.gif',
    'USA':         'https://www.worldometers.info/img/flags/us-flag.gif',
    'Canada':      'https://www.worldometers.info/img/flags/ca-flag.gif',
    'Monaco':      'https://www.worldometers.info/img/flags/mn-flag.gif',
    'Spain':       'https://www.worldometers.info/img/flags/sp-flag.gif',
    'Austria':     'https://www.worldometers.info/img/flags/au-flag.gif',
    'UK':          'https://www.worldometers.info/img/flags/uk-flag.gif',
    'Belgium':     'https://www.worldometers.info/img/flags/be-flag.gif',
    'Hungary':     'https://www.worldometers.info/img/flags/hu-flag.gif',
    'Netherlands': 'https://www.worldometers.info/img/flags/nl-flag.gif',
    'Italy':       'https://www.worldometers.info/img/flags/it-flag.gif',
    'Azerbaijan':  'https://www.worldometers.info/img/flags/aj-flag.gif',
    'Singapore':   'https://www.worldometers.info/img/flags/sn-flag.gif',
    'Mexico':      'https://www.worldometers.info/img/flags/mx-flag.gif',
    'Brazil':      'https://www.worldometers.info/img/flags/br-flag.gif',
    'Qatar':       'https://www.worldometers.info/img/flags/qa-flag.gif',
    'UAE':         'https://www.worldometers.info/img/flags/ae-flag.gif',
  };

  String? getFlag (String countryName){
    return f1CountryFlags[countryName];
  }
}
