// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get languageName => 'Suomi';

  @override
  String get languageFlag => '🇫🇮';

  @override
  String get appTitle => 'BiteScale';

  @override
  String get language => 'Kieli';

  @override
  String get systemDefault => 'Järjestelmän oletus';

  @override
  String get cancel => 'Peruuta';

  @override
  String get save => 'Tallenna';

  @override
  String get add => 'Lisää';

  @override
  String get delete => 'Poista';

  @override
  String get yes => 'Kyllä';

  @override
  String get no => 'Ei';

  @override
  String get edit => 'Muokkaa';

  @override
  String get male => 'Mies';

  @override
  String get female => 'Nainen';

  @override
  String get weight => 'Paino';

  @override
  String get food => 'Ruoka';

  @override
  String valueBetween(String min, String max) {
    return 'Anna arvo väliltä $min–$max';
  }

  @override
  String get welcome => 'Tervetuloa!';

  @override
  String get heightQuestion =>
      'Kuinka pitkä olet? Pituuttasi käytetään painoindeksin laskemiseen.';

  @override
  String get height => 'Pituus';

  @override
  String get heightError => 'Anna pituutesi senttimetreinä';

  @override
  String get continueButton => 'Jatka';

  @override
  String get editHeight => 'Muokkaa pituutta';

  @override
  String get yourHeight => 'Pituutesi';

  @override
  String get addWeight => 'Lisää paino';

  @override
  String get noWeightEntries =>
      'Ei merkintöjä vielä.\nAloita napauttamalla \"Lisää paino\".';

  @override
  String get history => 'Historia';

  @override
  String get noWeightsInRange =>
      'Tältä ajalta ei ole painomerkintöjä.\nVedä liukusäädintä vasemmalle nähdäksesi kauemmas.';

  @override
  String showingLastDays(int days) {
    return 'Viimeiset $days päivää';
  }

  @override
  String rangeDays(int days) {
    return '$days pv';
  }

  @override
  String rangeMonths(int months) {
    return '$months kk';
  }

  @override
  String rangeYears(String years) {
    return '$years v';
  }

  @override
  String get oneDayLess => 'Päivä vähemmän';

  @override
  String get oneDayMore => 'Päivä enemmän';

  @override
  String get weightSummaryEmpty =>
      'Kirjaa painosi säännöllisesti, niin näet trendin ja painoindeksin.';

  @override
  String get current => 'Nyt';

  @override
  String totalChange(String change) {
    return 'Muutos yhteensä: $change kg';
  }

  @override
  String get trendNeedsTwo =>
      'Lisää vähintään kaksi merkintää eri päiville, niin trendiviiva voidaan laskea.';

  @override
  String trendPerWeek(String change) {
    return 'Trendi: $change kg / viikko';
  }

  @override
  String estimatedDeficit(int kcal) {
    return 'Arvioitu kalorivaje: $kcal kcal / päivä';
  }

  @override
  String estimatedSurplus(int kcal) {
    return 'Arvioitu kaloriylijäämä: $kcal kcal / päivä';
  }

  @override
  String get enterValidWeight => 'Anna kelvollinen paino';

  @override
  String get bmi => 'BMI';

  @override
  String get bmiUnderweight => 'Alipaino';

  @override
  String get bmiNormal => 'Normaali paino';

  @override
  String get bmiOverweight => 'Ylipaino';

  @override
  String get bmiObese => 'Lihavuus';

  @override
  String get bodyFat => 'Rasvaprosentti';

  @override
  String get bodyFatEssential => 'Välttämätön rasva';

  @override
  String get bodyFatAthletic => 'Urheilullinen';

  @override
  String get bodyFatFit => 'Hyvä kunto';

  @override
  String get bodyFatAverage => 'Keskimääräinen';

  @override
  String get bodyFatObese => 'Lihavuus';

  @override
  String get tapToAddMeasurements => 'Lisää mitat napauttamalla';

  @override
  String fatAndLean(String fat, String lean) {
    return '$fat kg rasvaa · $lean kg rasvatonta';
  }

  @override
  String measuredOn(String date) {
    return 'Mitattu $date';
  }

  @override
  String get setGoal => 'Aseta painotavoite';

  @override
  String get setGoalSubtitle =>
      'Näet, kuinka suuri päivittäinen kalorivaje tarvitaan';

  @override
  String get goalNeedsWeight =>
      'Lisää painosi, niin näet mitä tavoitteeseen pääseminen vaatii.';

  @override
  String get goalReached => 'Tavoite saavutettu! 🎉';

  @override
  String goalOverdue(String kg) {
    return 'Tavoitteeseen on $kg kg, mutta tavoitepäivä on mennyt. Aseta uusi päivä.';
  }

  @override
  String kgToLose(String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$kg kg pudotettavaa $days päivässä',
      one: '$kg kg pudotettavaa 1 päivässä',
    );
    return '$_temp0';
  }

  @override
  String kgToGain(String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$kg kg lisättävää $days päivässä',
      one: '$kg kg lisättävää 1 päivässä',
    );
    return '$_temp0';
  }

  @override
  String neededDeficit(int kcal) {
    return 'Tarvittava kalorivaje: $kcal kcal / päivä';
  }

  @override
  String neededSurplus(int kcal) {
    return 'Tarvittava kaloriylijäämä: $kcal kcal / päivä';
  }

  @override
  String get tooFastPace =>
      'Tahti on hyvin nopea. Harkitse myöhäisempää tavoitepäivää.';

  @override
  String currentTrendDeficit(int kcal) {
    return 'Nykyinen trendisi: $kcal kcal vajetta / päivä';
  }

  @override
  String currentTrendSurplus(int kcal) {
    return 'Nykyinen trendisi: $kcal kcal ylijäämää / päivä';
  }

  @override
  String goalTitle(String kg, String date) {
    return 'Tavoite: $kg kg $date mennessä';
  }

  @override
  String get editGoal => 'Muokkaa tavoitetta';

  @override
  String get removeGoal => 'Poista tavoite';

  @override
  String get weightGoal => 'Painotavoite';

  @override
  String get goalWeight => 'Tavoitepaino';

  @override
  String get goalDate => 'Tavoitepäivä';

  @override
  String get chartGoal => 'Tavoite';

  @override
  String get bodyComposition => 'Kehon koostumus';

  @override
  String get tapeMeasure => 'Mittanauha';

  @override
  String get bmiExplanation =>
      'Painoindeksi (BMI) lasketaan pituudestasi ja viimeisimmästä painostasi. Se ei erota rasvaa ja lihasta.';

  @override
  String get navyExplanation =>
      'U.S. Navy -menetelmä: arvioi rasvaprosentin ympärysmitoista ja pituudestasi.';

  @override
  String get neck => 'Kaula';

  @override
  String get waist => 'Vyötärö';

  @override
  String get hips => 'Lantio';

  @override
  String get neckHelp =>
      'Heti kurkunpään (aataminomenan) alapuolelta, nauha hieman eteenpäin alaspäin viettäen';

  @override
  String get waistHelpMale => 'Vaakasuoraan navan korkeudelta';

  @override
  String get waistHelpFemale => 'Vyötärön kapeimmasta kohdasta';

  @override
  String get hipsHelp => 'Pakaroiden leveimmästä kohdasta';

  @override
  String bodyFatPreview(String value) {
    return 'Rasvaprosentti: $value';
  }

  @override
  String heightUsed(String cm) {
    return 'Käytetty pituus: $cm cm';
  }

  @override
  String get chooseSex => 'Valitse mies tai nainen';

  @override
  String get enterAllMeasurements => 'Anna kaikki mitat senttimetreinä';

  @override
  String get invalidMeasurements =>
      'Näillä mitoilla ei saada kelvollista tulosta. Tarkista mitat.';

  @override
  String get dailyCalorieNeeds => 'Päivittäinen energiantarve';

  @override
  String get calorieProfileIntro =>
      'Näiden, pituutesi ja viimeisimmän painosi avulla arvioidaan, kuinka monta kaloria kulutat päivässä.';

  @override
  String get birthYear => 'Syntymävuosi';

  @override
  String get invalidBirthYear => 'Anna kelvollinen syntymävuosi';

  @override
  String get activityLevel => 'Aktiivisuustaso';

  @override
  String get chooseActivity => 'Valitse aktiivisuustasosi';

  @override
  String get activitySedentary => 'Vähän liikkuva';

  @override
  String get activitySedentaryDesc =>
      'Vähän tai ei lainkaan liikuntaa, istumatyö';

  @override
  String get activityLight => 'Kevyesti aktiivinen';

  @override
  String get activityLightDesc => 'Kevyttä liikuntaa 1–3 päivänä viikossa';

  @override
  String get activityModerate => 'Kohtalaisen aktiivinen';

  @override
  String get activityModerateDesc => 'Liikuntaa 3–5 päivänä viikossa';

  @override
  String get activityActive => 'Erittäin aktiivinen';

  @override
  String get activityActiveDesc => 'Rasittavaa liikuntaa 6–7 päivänä viikossa';

  @override
  String get activityExtreme => 'Äärimmäisen aktiivinen';

  @override
  String get activityExtremeDesc => 'Fyysinen työ ja kova harjoittelu';

  @override
  String get myFoods => 'Omat ruoat';

  @override
  String get addFood => 'Lisää ruoka';

  @override
  String get today => 'Tänään';

  @override
  String get favourites => 'Suosikit';

  @override
  String get addToFavourites => 'Lisää suosikkeihin';

  @override
  String get removeFromFavourites => 'Poista suosikeista';

  @override
  String get eaten => 'Syöty';

  @override
  String get nothingLogged => 'Tälle päivälle ei ole kirjauksia.';

  @override
  String kcalEaten(int kcal) {
    return '$kcal kcal syöty';
  }

  @override
  String get needWeightForTarget =>
      'Lisää painosi, niin näet kuinka paljon sinun kannattaa syödä päivässä.';

  @override
  String get needInfoForTarget =>
      'Kerro itsestäsi hieman lisää, niin näet kuinka paljon sinun kannattaa syödä päivässä.';

  @override
  String get goToWeightPage => 'Siirry painosivulle';

  @override
  String get setUpCalorieTarget => 'Määritä päivän kaloritavoite';

  @override
  String get targetGoalDone =>
      'Tavoitteesi on saavutettu tai sen päivä on mennyt, joten tavoite pitää nykyisen painosi.';

  @override
  String get targetNoGoal =>
      'Painotavoitetta ei ole asetettu, joten tavoite pitää nykyisen painosi.';

  @override
  String targetDeficitToGoal(int kcal, String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          '$kcal kcal vajetta / päivä, jotta $kg kg saavutetaan $days päivässä',
      one: '$kcal kcal vajetta / päivä, jotta $kg kg saavutetaan 1 päivässä',
    );
    return '$_temp0';
  }

  @override
  String targetSurplusToGoal(int kcal, String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          '$kcal kcal ylijäämää / päivä, jotta $kg kg saavutetaan $days päivässä',
      one: '$kcal kcal ylijäämää / päivä, jotta $kg kg saavutetaan 1 päivässä',
    );
    return '$_temp0';
  }

  @override
  String dailyTarget(int kcal) {
    return 'Päivän tavoite: $kcal kcal';
  }

  @override
  String get calorieProfileTooltip => 'Ikä, sukupuoli ja aktiivisuus';

  @override
  String get overTarget => 'Yli tavoitteen';

  @override
  String get leftToEat => 'Jäljellä';

  @override
  String get deficitLeft => 'Vajetta jäljellä';

  @override
  String get overMaintenance => 'Yli ylläpidon';

  @override
  String get barGoal => 'Tavoite';

  @override
  String get barDeficitEnds => 'Vaje loppuu';

  @override
  String get statusWithinGoalDeficit => 'Tavoitteen sisällä ja kalorivajeessa.';

  @override
  String get statusWithinGoal => 'Tavoitteen sisällä.';

  @override
  String get statusOverGoalDeficit =>
      'Yli tavoitteen, mutta yhä kalorivajeessa.';

  @override
  String get statusOverGoal => 'Yli tavoitteen.';

  @override
  String get statusNoDeficit =>
      'Kalorivajetta ei ole enää: olet syönyt yhtä paljon kuin kulutat.';

  @override
  String maintenanceLine(int kcal) {
    return 'Nykyisen painon ylläpito: $kcal kcal / päivä';
  }

  @override
  String minimumWarning(int kcal) {
    return 'Tavoitteen saavuttaminen ajallaan vaatisi syömään alle $kcal kcal päivässä, mitä ei suositella. Tavoite on rajattu tähän, joten harkitse myöhäisempää tavoitepäivää.';
  }

  @override
  String get estimateBodyFat =>
      'Arvio perustuu rasvaprosenttiisi (Katch-McArdle) ja aktiivisuustasoosi.';

  @override
  String get estimateMifflin =>
      'Arvio perustuu ikääsi, sukupuoleesi, pituuteesi, painoosi (Mifflin-St Jeor) ja aktiivisuustasoosi.';

  @override
  String get nutrientProtein => 'Proteiini';

  @override
  String get nutrientCarbs => 'Hiilihydraatit';

  @override
  String get nutrientSugar => 'josta sokereita';

  @override
  String get nutrientFat => 'Rasva';

  @override
  String get nutrientFiber => 'Kuitu';

  @override
  String get nutrientSalt => 'Suola';

  @override
  String get enterValidAmount => 'Anna kelvollinen määrä';

  @override
  String get volume => 'Tilavuus';

  @override
  String get portionDefault => 'annos';

  @override
  String get portionCount => 'Annosten määrä';

  @override
  String kcalPer100(String kcal, String unit) {
    return '$kcal kcal / 100 $unit';
  }

  @override
  String get newFood => 'Uusi ruoka';

  @override
  String get searchFoods => 'Hae ruokia';

  @override
  String get all => 'Kaikki';

  @override
  String get noSavedFoods =>
      'Ei tallennettuja ruokia.\nLisää ruoka napauttamalla \"Uusi ruoka\".';

  @override
  String get noFoodsMatch => 'Hakua vastaavia ruokia ei löytynyt.';

  @override
  String deleteFoodTitle(String name) {
    return 'Poistetaanko ruokapohja \"$name\"?';
  }

  @override
  String get deleteFoodBody =>
      'Ruoka poistetaan tallennetuista ruoista. Päiviin, joille se on jo kirjattu, ei tehdä muutoksia.';

  @override
  String get deleteFoodTemplate => 'Poista ruokapohja';

  @override
  String get removeFromEaten => 'Poista syödyistä';

  @override
  String removeFromEatenTitle(String name) {
    return 'Poistetaanko \"$name\" syödyistä?';
  }

  @override
  String get editFood => 'Muokkaa ruokaa';

  @override
  String get takePhoto => 'Ota kuva';

  @override
  String get chooseFromGallery => 'Valitse galleriasta';

  @override
  String get removePhoto => 'Poista kuva';

  @override
  String get nameRequired => 'Nimi *';

  @override
  String get enterName => 'Anna nimi';

  @override
  String get category => 'Luokka';

  @override
  String get measuredIn => 'Mittayksikkö';

  @override
  String get grams => 'grammat';

  @override
  String get portionSize => 'Annoksen / kappaleen koko';

  @override
  String get optional => 'Valinnainen';

  @override
  String get portionCalled => 'Nimitys';

  @override
  String get portionCalledHelp => 'esim. viipale, kpl, lasi';

  @override
  String nutritionPer100(String unit) {
    return 'Ravintoarvot / 100 $unit';
  }

  @override
  String get caloriesRequired => 'Energia *';

  @override
  String get required => 'Pakollinen';

  @override
  String get enterSizeAboveZero => 'Anna koko, joka on yli 0';

  @override
  String get enterValidNumber => 'Anna kelvollinen luku';

  @override
  String get saveFood => 'Tallenna ruoka';

  @override
  String get categoryFruitsVegetables => 'Hedelmät ja vihannekset';

  @override
  String get categoryMeatFish => 'Liha ja kala';

  @override
  String get categoryDairyEggs => 'Maitotuotteet ja munat';

  @override
  String get categoryBreadGrains => 'Leipä ja viljat';

  @override
  String get categoryMeals => 'Ateriat';

  @override
  String get categorySnacksSweets => 'Välipalat ja makeiset';

  @override
  String get categoryDrinks => 'Juomat';

  @override
  String get categoryOther => 'Muut';

  @override
  String get exportFoods => 'Vie ruoat tiedostoon';

  @override
  String get importFoods => 'Tuo ruokia tiedostosta';

  @override
  String get noFoodsToExport =>
      'Sinulla ei ole tallennettuja ruokia vietäväksi.';

  @override
  String exportedFoods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ruokaa viety.',
      one: '1 ruoka viety.',
    );
    return '$_temp0';
  }

  @override
  String get exportFailed => 'Tiedostoa ei voitu tallentaa.';

  @override
  String get notAFoodFile => 'Tämä ei ole BiteScale-ruokatiedosto.';

  @override
  String importNothingNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kaikki tiedoston $count ruokaa ovat jo sovelluksessa.',
      one: 'Tiedoston ruoka on jo sovelluksessa.',
    );
    return '$_temp0';
  }

  @override
  String importFoundFoods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tiedostossa on $count ruokaa.',
      one: 'Tiedostossa on 1 ruoka.',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count on jo sovelluksessa täsmälleen samanlaisina, joten ne ohitetaan.',
      one: '1 on jo sovelluksessa täsmälleen samanlaisena, joten se ohitetaan.',
    );
    return '$_temp0';
  }

  @override
  String get importNewFoods => 'Uudet ruoat';

  @override
  String get importSimilarFoods => 'Samankaltaisia kuin omat ruokasi';

  @override
  String get importSimilarHelp => 'Vain erot näytetään.';

  @override
  String get selectAll => 'Valitse kaikki';

  @override
  String get selectNone => 'Poista valinnat';

  @override
  String get yours => 'Omasi';

  @override
  String get imported => 'Tuotava';

  @override
  String get keepMine => 'Pidä omani';

  @override
  String get useImported => 'Korvaa omani tuotavalla';

  @override
  String get keepBoth => 'Pidä molemmat';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tuo $count ruokaa',
      one: 'Tuo 1 ruoka',
      zero: 'Ei tuotavaa',
    );
    return '$_temp0';
  }

  @override
  String importDone(int added, int replaced) {
    return 'Lisätty $added, korvattu $replaced.';
  }

  @override
  String get fieldName => 'Nimi';

  @override
  String get fieldUnit => 'Yksikkö';

  @override
  String get fieldCalories => 'Energia / 100';

  @override
  String get fieldPhoto => 'Kuva';

  @override
  String get noPhoto => 'Ei kuvaa';

  @override
  String get caloriesByCategory => 'Kalorit luokittain';

  @override
  String get smallerCategories => 'Pienemmät luokat';

  @override
  String allFromCategory(String category) {
    return 'Kaikki päivän kalorit ovat luokasta $category.';
  }

  @override
  String get manageCategories => 'Hallitse luokkia';

  @override
  String get customCategoriesHelp =>
      'Itse luomasi luokat. Valmiita luokkia ei voi poistaa.';

  @override
  String get noCustomCategories =>
      'Et ole luonut omia luokkia. Valmiita luokkia ei voi poistaa.';

  @override
  String foodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ruokaa',
      one: '1 ruoka',
      zero: 'Ei ruokia',
    );
    return '$_temp0';
  }

  @override
  String get removeCategory => 'Poista luokka';

  @override
  String removeCategoryTitle(String name) {
    return 'Poistetaanko luokka \"$name\"?';
  }

  @override
  String removeCategoryBody(int count, String other) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ruokaa siirretään luokkaan $other.',
      one: '1 ruoka siirretään luokkaan $other.',
      zero: 'Mikään ruoka ei käytä sitä.',
    );
    return '$_temp0';
  }

  @override
  String get close => 'Sulje';

  @override
  String get shareFoods => 'Jaa ruokia';

  @override
  String get shareFood => 'Jaa tämä ruoka';

  @override
  String get shareFoodsHelp =>
      'Valitse lähetettävät ruoat. Vastaanottaja avaa tiedoston BiteScalella ja valitsee, mitkä lisätään.';

  @override
  String shareButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jaa $count ruokaa',
      one: 'Jaa 1 ruoka',
      zero: 'Valitse jaettavat ruoat',
    );
    return '$_temp0';
  }

  @override
  String shareFoodsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tässä $count ruokaa BiteScaleen. Avaa liitetiedosto BiteScalella lisätäksesi ne.',
      one: 'Tässä ruoka BiteScaleen. Avaa liitetiedosto BiteScalella lisätäksesi sen.',
    );
    return '$_temp0';
  }

  @override
  String get shareFoodsSubject => 'BiteScale-ruokia';

  @override
  String get shareFailed => 'Ruokien jakaminen ei onnistunut.';
}
