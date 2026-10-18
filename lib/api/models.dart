double asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int asInt(dynamic value) {
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}

class CaloraUser {
  CaloraUser({required this.id, required this.name, this.email, required this.role, this.profile});

  final String id;
  final String name;
  final String? email;
  final String role;
  final Profile? profile;

  factory CaloraUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return CaloraUser(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      email: json['email']?.toString(),
      role: '${json['role'] ?? 'USER'}',
      profile: profile is Map<String, dynamic> ? Profile.fromJson(profile) : null,
    );
  }
}

class Profile {
  Profile({
    required this.bb,
    required this.tb,
    required this.age,
    required this.sex,
    required this.activity,
    required this.goal,
    required this.targetWeightKg,
    required this.rateKgPerWeek,
    required this.dietaryPreference,
    required this.allergies,
    required this.dislikedFoods,
    required this.timezone,
  });

  final double bb;
  final double tb;
  final double age;
  final String sex;
  final String activity;
  final String goal;
  final double targetWeightKg;
  final double rateKgPerWeek;
  final String dietaryPreference;
  final String allergies;
  final String dislikedFoods;
  final String timezone;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      bb: asDouble(json['bb']),
      tb: asDouble(json['tb']),
      age: asDouble(json['age']),
      sex: '${json['sex'] ?? 'male'}',
      activity: '${json['activity'] ?? 'moderate'}',
      goal: '${json['goal'] ?? 'maintain'}',
      targetWeightKg: asDouble(json['targetWeightKg'] ?? json['bb']),
      rateKgPerWeek: asDouble(json['rateKgPerWeek'] ?? 0.25),
      dietaryPreference: '${json['dietaryPreference'] ?? 'none'}',
      allergies: '${json['allergies'] ?? ''}',
      dislikedFoods: '${json['dislikedFoods'] ?? ''}',
      timezone: '${json['timezone'] ?? 'Asia/Bangkok'}',
    );
  }

  Map<String, dynamic> toJson() => {
        'bb': bb,
        'tb': tb,
        'age': age,
        'sex': sex,
        'activity': activity,
        'goal': goal,
        'targetWeightKg': targetWeightKg,
        'rateKgPerWeek': rateKgPerWeek,
        'dietaryPreference': dietaryPreference,
        'allergies': allergies,
        'dislikedFoods': dislikedFoods,
        'timezone': timezone,
      };
}

class FoodEntry {
  FoodEntry({
    required this.id,
    required this.meal,
    required this.category,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
    this.source = 'MANUAL',
  });

  final String id;
  final String meal;
  final String category;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final String createdAt;
  final String source;

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: '${json['id']}',
      meal: '${json['meal'] ?? ''}',
      category: '${json['category'] ?? 'snack'}',
      kcal: asDouble(json['kcal']),
      protein: asDouble(json['protein']),
      carbs: asDouble(json['carbs']),
      fat: asDouble(json['fat']),
      createdAt: '${json['createdAt'] ?? ''}',
      source: '${json['source'] ?? 'MANUAL'}',
    );
  }
}

class ActivityEntry {
  ActivityEntry({required this.id, required this.name, required this.activityType, required this.startedAt, this.durationSeconds});

  final String id;
  final String name;
  final String activityType;
  final String startedAt;
  final int? durationSeconds;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) {
    return ActivityEntry(
      id: '${json['id']}',
      name: '${json['name'] ?? json['activityType'] ?? 'Activity'}',
      activityType: '${json['activityType'] ?? ''}',
      startedAt: '${json['startedAt'] ?? ''}',
      durationSeconds: json['durationSeconds'] == null ? null : asInt(json['durationSeconds']),
    );
  }
}

class WeightEntry {
  WeightEntry({required this.id, required this.weightKg, required this.measuredAt});

  final String id;
  final double weightKg;
  final String measuredAt;

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: '${json['id']}',
      weightKg: asDouble(json['weightKg']),
      measuredAt: '${json['measuredAt'] ?? ''}',
    );
  }
}

class MealSuggestion {
  MealSuggestion({required this.name, required this.kcal, required this.protein, required this.carbs, required this.fat});

  final String name;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      name: '${json['name'] ?? ''}',
      kcal: asDouble(json['kcal']),
      protein: asDouble(json['protein']),
      carbs: asDouble(json['carbs']),
      fat: asDouble(json['fat']),
    );
  }
}

class KitchenLunch {
  KitchenLunch({required this.name, required this.calories, required this.proteinG, required this.carbsG, required this.fatG});

  final String name;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  factory KitchenLunch.fromJson(Map<String, dynamic> json) {
    return KitchenLunch(
      name: '${json['name'] ?? 'Lunch'}',
      calories: asDouble(json['calories']),
      proteinG: asDouble(json['proteinG']),
      carbsG: asDouble(json['carbsG']),
      fatG: asDouble(json['fatG']),
    );
  }
}

class Dashboard {
  Dashboard({
    required this.remainingKcal,
    required this.consumedKcal,
    required this.targetKcal,
    required this.remainingProtein,
    required this.remainingCarbs,
    required this.remainingFat,
    required this.goalLabel,
    required this.currentKg,
    required this.targetKg,
    required this.effectiveDailyTarget,
    this.tonight,
    this.lunch,
    this.weightTrend,
    this.averageCalories = 0,
    this.averageProtein = 0,
    this.loggingCompleteness = 0,
    this.daysLogged = 0,
    this.windowDays = 7,
    this.activityEnergyAverage = 0,
    this.confidence = 'LOW',
    this.profile,
    this.foods = const [],
    this.activities = const [],
    this.weights = const [],
  });

  final double remainingKcal;
  final double consumedKcal;
  final double targetKcal;
  final double remainingProtein;
  final double remainingCarbs;
  final double remainingFat;
  final String goalLabel;
  final double? currentKg;
  final double? targetKg;
  final double effectiveDailyTarget;
  final MealSuggestion? tonight;
  final KitchenLunch? lunch;
  final double? weightTrend;
  final double averageCalories;
  final double averageProtein;
  final double loggingCompleteness;
  final int daysLogged;
  final int windowDays;
  final double activityEnergyAverage;
  final String confidence;
  final Profile? profile;
  final List<FoodEntry> foods;
  final List<ActivityEntry> activities;
  final List<WeightEntry> weights;

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    final today = _map(json['today']);
    final remaining = _map(today['remaining']);
    final consumed = _map(today['consumed']);
    final targets = _map(today['targets']);
    final tonight = _map(json['tonight']);
    final meal = tonight['meal'];
    final tomorrow = _map(json['tomorrow']);
    final lunch = tomorrow['lunch'];
    final goal = _map(json['goalSummary']);
    final rolling = _map(tomorrow['rollingState']);
    final profile = json['profile'];
    return Dashboard(
      remainingKcal: asDouble(remaining['kcal']),
      consumedKcal: asDouble(consumed['kcal']),
      targetKcal: asDouble(targets['kcal']),
      remainingProtein: asDouble(remaining['protein']),
      remainingCarbs: asDouble(remaining['carbs']),
      remainingFat: asDouble(remaining['fat']),
      goalLabel: '${goal['label'] ?? 'Maintain weight'}',
      currentKg: goal['currentKg'] == null ? null : asDouble(goal['currentKg']),
      targetKg: goal['targetKg'] == null ? null : asDouble(goal['targetKg']),
      effectiveDailyTarget: asDouble(tomorrow['effectiveDailyTarget']),
      tonight: meal is Map<String, dynamic> ? MealSuggestion.fromJson(meal) : null,
      lunch: lunch is Map<String, dynamic> ? KitchenLunch.fromJson(lunch) : null,
      weightTrend: rolling['weightTrend'] == null ? null : asDouble(rolling['weightTrend']),
      averageCalories: asDouble(rolling['averageCalories']),
      averageProtein: asDouble(rolling['averageProtein']),
      loggingCompleteness: asDouble(rolling['loggingCompleteness']),
      daysLogged: asInt(rolling['daysLogged']),
      windowDays: asInt(rolling['windowDays'] ?? 7),
      activityEnergyAverage: asDouble(rolling['activityEnergyAverage']),
      confidence: '${rolling['confidence'] ?? tomorrow['confidence'] ?? 'LOW'}',
      profile: profile is Map<String, dynamic> ? Profile.fromJson(profile) : null,
      foods: _list(json['foodLogs'], FoodEntry.fromJson),
      activities: _list(json['activities'], ActivityEntry.fromJson),
      weights: _list(json['weights'], WeightEntry.fromJson),
    );
  }
}

class Analysis {
  Analysis({
    required this.mealName,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.sodium,
    required this.source,
    this.summary = '',
  });

  final String mealName;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double sodium;
  final String source;
  final String summary;

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      mealName: '${json['mealName'] ?? ''}',
      kcal: asDouble(json['kcal']),
      protein: asDouble(json['protein']),
      carbs: asDouble(json['carbs']),
      fat: asDouble(json['fat']),
      sugar: asDouble(json['sugar']),
      sodium: asDouble(json['sodium']),
      source: '${json['source'] ?? 'PHOTO_ESTIMATE'}',
      summary: '${json['summary'] ?? ''}',
    );
  }
}

Map<String, dynamic> _map(dynamic value) => value is Map<String, dynamic> ? value : <String, dynamic>{};

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) parse) {
  if (value is! List) return [];
  return value.whereType<Map<String, dynamic>>().map(parse).toList();
}
