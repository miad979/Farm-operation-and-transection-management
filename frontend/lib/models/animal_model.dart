class AnimalModel {
  final int id;
  final String animalIdNumber;
  final String name;
  final String type;
  final String? breed;
  final String? gender;
  final String healthStatus;
  final bool vaccinated;
  final String pregnancyStatus;
  final bool isActive;
  final String? notes;

  AnimalModel({
    required this.id,
    required this.animalIdNumber,
    required this.name,
    required this.type,
    this.breed,
    this.gender,
    required this.healthStatus,
    required this.vaccinated,
    required this.pregnancyStatus,
    required this.isActive,
    this.notes,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] as int,
      animalIdNumber: json['animal_id_number'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      breed: json['breed'] as String?,
      gender: json['gender'] as String?,
      healthStatus: (json['health_status'] as String?) ?? 'Healthy',
      vaccinated: (json['vaccinated'] as bool?) ?? false,
      pregnancyStatus: (json['pregnancy_status'] as String?) ?? 'Not Pregnant',
      isActive: (json['is_active'] as bool?) ?? true,
      notes: json['notes'] as String?,
    );
  }
}
