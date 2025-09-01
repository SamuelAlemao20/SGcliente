
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final double deliveryFee;
  final int deliveryTime;
  final bool isOpen;
  final bool isFeatured;
  final List<String> tags;
  final Address address;
  final WorkingHours workingHours;
  final List<MenuCategory> menuCategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.isOpen,
    this.isFeatured = false,
    this.tags = const [],
    required this.address,
    required this.workingHours,
    this.menuCategories = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    double? deliveryFee,
    int? deliveryTime,
    bool? isOpen,
    bool? isFeatured,
    List<String>? tags,
    Address? address,
    WorkingHours? workingHours,
    List<MenuCategory>? menuCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isOpen: isOpen ?? this.isOpen,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      menuCategories: menuCategories ?? this.menuCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkingHours {
  final Map<String, DaySchedule> schedule;

  WorkingHours({required this.schedule});

  bool isOpenAt(DateTime dateTime) {
    final weekday = _getWeekdayName(dateTime.weekday);
    final daySchedule = schedule[weekday];
    
    if (daySchedule == null || !daySchedule.isOpen) {
      return false;
    }

    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    return _isTimeInRange(timeOfDay, daySchedule.openTime, daySchedule.closeTime);
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'monday', 'tuesday', 'wednesday', 'thursday', 
      'friday', 'saturday', 'sunday'
    ];
    return weekdays[weekday - 1];
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Crosses midnight
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}

class DaySchedule {
  final bool isOpen;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  DaySchedule({
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });
}

class Address {
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.latitude,
    this.longitude,
  });

  String get fullAddress {
    return '$street, $number${complement?.isNotEmpty == true ? ', $complement' : ''}, $neighborhood, $city - $state, $zipCode';
  }
}
