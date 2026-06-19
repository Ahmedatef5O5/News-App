import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
part 'profile_model.g.dart';

@HiveType(typeId: 2)
// ignore: must_be_immutable
class ProfileModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? firstName;

  @HiveField(2)
  final String? lastName;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? hobby;

  @HiveField(6)
  final String? country;

  @HiveField(7)
  final List<String> preferredCategories;

  @HiveField(8)
  final bool isOnboarded;

  ProfileModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.phone,
    this.hobby,
    this.country,
    this.preferredCategories = const [],
    this.isOnboarded = false,
  });

  String get displayName {
    final name =
        [firstName, lastName].where((p) => p != null && p.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : 'NewsWave User';
  }

  String get initials {
    final f = firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final l = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    return (f + l).isNotEmpty ? (f + l) : 'N';
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      hobby: map['hobby'] as String?,
      country: map['country'] as String?,
      preferredCategories: _parseCategories(map['preferred_categories']),
      isOnboarded: map['is_onboarded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'hobby': hobby,
      'country': country,
      'preferred_categories': preferredCategories,
      'is_onboarded': isOnboarded,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? phone,
    String? hobby,
    String? country,
    List<String>? preferredCategories,
    bool? isOnboarded,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      hobby: hobby ?? this.hobby,
      country: country ?? this.country,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  static List<String> _parseCategories(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        avatarUrl,
        phone,
        hobby,
        country,
        preferredCategories,
        isOnboarded,
      ];
}

abstract final class CountriesList {
  static const List<String> all = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahrain',
    'Bangladesh',
    'Belarus',
    'Belgium',
    'Belize',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Brazil',
    'Bulgaria',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Chile',
    'China',
    'Colombia',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Estonia',
    'Ethiopia',
    'Finland',
    'France',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Guatemala',
    'Honduras',
    'Hungary',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kuwait',
    'Latvia',
    'Lebanon',
    'Libya',
    'Lithuania',
    'Luxembourg',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Mexico',
    'Moldova',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Nigeria',
    'North Korea',
    'Norway',
    'Oman',
    'Pakistan',
    'Palestine',
    'Panama',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Somalia',
    'South Africa',
    'South Korea',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tanzania',
    'Thailand',
    'Tunisia',
    'Turkey',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];
  static const Map<String, String> _arabicNames = {
    'Afghanistan': 'أفغانستان',
    'Albania': 'ألبانيا',
    'Algeria': 'الجزائر',
    'Andorra': 'أندورا',
    'Angola': 'أنغولا',
    'Argentina': 'الأرجنتين',
    'Armenia': 'أرمينيا',
    'Australia': 'أستراليا',
    'Austria': 'النمسا',
    'Azerbaijan': 'أذربيجان',
    'Bahrain': 'البحرين',
    'Bangladesh': 'بنغلاديش',
    'Belarus': 'بيلاروسيا',
    'Belgium': 'بلجيكا',
    'Belize': 'بليز',
    'Bolivia': 'بوليفيا',
    'Bosnia and Herzegovina': 'البوسنة والهرسك',
    'Brazil': 'البرازيل',
    'Bulgaria': 'بلغاريا',
    'Cambodia': 'كمبوديا',
    'Cameroon': 'الكاميرون',
    'Canada': 'كندا',
    'Chile': 'تشيلي',
    'China': 'الصين',
    'Colombia': 'كولومبيا',
    'Costa Rica': 'كوستاريكا',
    'Croatia': 'كرواتيا',
    'Cuba': 'كوبا',
    'Cyprus': 'قبرص',
    'Czech Republic': 'جمهورية التشيك',
    'Denmark': 'الدنمارك',
    'Ecuador': 'الإكوادور',
    'Egypt': 'مصر',
    'El Salvador': 'السلفادور',
    'Estonia': 'إستونيا',
    'Ethiopia': 'إثيوبيا',
    'Finland': 'فنلندا',
    'France': 'فرنسا',
    'Georgia': 'جورجيا',
    'Germany': 'ألمانيا',
    'Ghana': 'غانا',
    'Greece': 'اليونان',
    'Guatemala': 'غواتيمالا',
    'Honduras': 'هندوراس',
    'Hungary': 'المجر',
    'India': 'الهند',
    'Indonesia': 'إندونيسيا',
    'Iran': 'إيران',
    'Iraq': 'العراق',
    'Ireland': 'أيرلندا',
    'Israel': 'إسرائيل',
    'Italy': 'إيطاليا',
    'Jamaica': 'جامايكا',
    'Japan': 'اليابان',
    'Jordan': 'الأردن',
    'Kazakhstan': 'كازاخستان',
    'Kenya': 'كينيا',
    'Kuwait': 'الكويت',
    'Latvia': 'لاتفيا',
    'Lebanon': 'لبنان',
    'Libya': 'ليبيا',
    'Lithuania': 'ليتوانيا',
    'Luxembourg': 'لوكسمبورغ',
    'Malaysia': 'ماليزيا',
    'Maldives': 'المالديف',
    'Mali': 'مالي',
    'Malta': 'مالطا',
    'Mexico': 'المكسيك',
    'Moldova': 'مولدوفا',
    'Morocco': 'المغرب',
    'Mozambique': 'موزمبيق',
    'Myanmar': 'ميانمار',
    'Nepal': 'نيبال',
    'Netherlands': 'هولندا',
    'New Zealand': 'نيوزيلندا',
    'Nicaragua': 'نيكاراغوا',
    'Nigeria': 'نيجيريا',
    'North Korea': 'كوريا الشمالية',
    'Norway': 'النرويج',
    'Oman': 'عُمان',
    'Pakistan': 'باكستان',
    'Palestine': 'فلسطين',
    'Panama': 'بنما',
    'Paraguay': 'باراغواي',
    'Peru': 'بيرو',
    'Philippines': 'الفلبين',
    'Poland': 'بولندا',
    'Portugal': 'البرتغال',
    'Qatar': 'قطر',
    'Romania': 'رومانيا',
    'Russia': 'روسيا',
    'Rwanda': 'رواندا',
    'Saudi Arabia': 'المملكة العربية السعودية',
    'Senegal': 'السنغال',
    'Serbia': 'صربيا',
    'Singapore': 'سنغافورة',
    'Slovakia': 'سلوفاكيا',
    'Slovenia': 'سلوفينيا',
    'Somalia': 'الصومال',
    'South Africa': 'جنوب أفريقيا',
    'South Korea': 'كوريا الجنوبية',
    'Spain': 'إسبانيا',
    'Sri Lanka': 'سريلانكا',
    'Sudan': 'السودان',
    'Sweden': 'السويد',
    'Switzerland': 'سويسرا',
    'Syria': 'سوريا',
    'Taiwan': 'تايوان',
    'Tanzania': 'تنزانيا',
    'Thailand': 'تايلاند',
    'Tunisia': 'تونس',
    'Turkey': 'تركيا',
    'Uganda': 'أوغندا',
    'Ukraine': 'أوكرانيا',
    'United Arab Emirates': 'الإمارات العربية المتحدة',
    'United Kingdom': 'المملكة المتحدة',
    'United States': 'الولايات المتحدة الأمريكية',
    'Uruguay': 'أوروغواي',
    'Uzbekistan': 'أوزبكستان',
    'Venezuela': 'فنزويلا',
    'Vietnam': 'فيتنام',
    'Yemen': 'اليمن',
    'Zambia': 'زامبيا',
    'Zimbabwe': 'زيمبابوي',
  };

  /// Returns the display name for a country key in the given locale.
  static String displayName(String key, {required bool isArabic}) {
    if (isArabic) return _arabicNames[key] ?? key;
    return key;
  }

  /// Returns sorted display names mapped back to their raw keys.
  static List<MapEntry<String, String>> sortedEntries(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final entries = all
        .map((key) => MapEntry(key, displayName(key, isArabic: isArabic)))
        .toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries;
  }
}

enum Hobby {
  reading,
  writing,
  photography,
  gaming,
  cooking,
  traveling,
  fitnessSports,
  music,
  artDesign,
  technology;

  String localize(AppLocalizations l10n) => switch (this) {
        Hobby.reading => l10n.hobbyReading,
        Hobby.writing => l10n.hobbyWriting,
        Hobby.photography => l10n.hobbyPhotography,
        Hobby.gaming => l10n.hobbyGaming,
        Hobby.cooking => l10n.hobbyCooking,
        Hobby.traveling => l10n.hobbyTraveling,
        Hobby.fitnessSports => l10n.categorySports,
        Hobby.music => l10n.hobbyMusic,
        Hobby.artDesign => l10n.hobbyArtDesign,
        Hobby.technology => l10n.hobbyTechnology,
      };
}
