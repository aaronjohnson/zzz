class Habit {
  final int? id;
  final String name;
  final String shortDesc;
  final String longDesc;
  final String category;
  final int displayOrder;
  final bool isActive;

  Habit({
    this.id,
    required this.name,
    required this.shortDesc,
    required this.longDesc,
    required this.category,
    required this.displayOrder,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'short_desc': shortDesc,
      'long_desc': longDesc,
      'category': category,
      'display_order': displayOrder,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      shortDesc: map['short_desc'] as String,
      longDesc: map['long_desc'] as String,
      category: map['category'] as String,
      displayOrder: map['display_order'] as int,
      isActive: (map['is_active'] as int) == 1,
    );
  }
}
