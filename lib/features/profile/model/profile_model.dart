import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 2)
class ProfileModel extends HiveObject {
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
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProfileModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
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
}

abstract final class HobbyList {
  static const List<String> suggestions = [
    'Reading',
    'Writing',
    'Photography',
    'Gaming',
    'Cooking',
    'Traveling',
    'Fitness & Sports',
    'Music',
    'Art & Design',
    'Technology',
    'Finance & Investing',
    'Science',
    'Politics',
    'Movies & TV',
    'Fashion',
    'Nature & Outdoors',
    'Volunteering',
    'Language Learning',
    'Meditation',
    'Business & Entrepreneurship',
  ];
}
