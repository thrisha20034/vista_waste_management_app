import 'dart:math';
import '../models/service_request.dart';

class AnalyticsService {
  static Map<String, dynamic> generateWastePrediction(List<ServiceRequest> requests) {
    if (requests.isEmpty) {
      return _getDefaultPrediction();
    }

    // Analyze historical data
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));
    final recentRequests = requests.where((r) => r.createdAt.isAfter(lastMonth)).toList();

    // Calculate trends
    final weeklyAverage = recentRequests.length / 4.0;
    final wasteTypeDistribution = _calculateWasteTypeDistribution(recentRequests);
    final weightTrend = _calculateWeightTrend(recentRequests);

    // Generate predictions
    final nextWeekPrediction = _predictNextWeek(weeklyAverage, wasteTypeDistribution);
    final monthlyForecast = _generateMonthlyForecast(weeklyAverage, wasteTypeDistribution);

    return {
      'weeklyAverage': weeklyAverage,
      'wasteTypeDistribution': wasteTypeDistribution,
      'weightTrend': weightTrend,
      'nextWeekPrediction': nextWeekPrediction,
      'monthlyForecast': monthlyForecast,
      'recommendations': _generateRecommendations(wasteTypeDistribution, weightTrend),
    };
  }

  static Map<String, double> _calculateWasteTypeDistribution(List<ServiceRequest> requests) {
    final distribution = <String, double>{};
    final total = requests.length.toDouble();

    for (final type in WasteType.values) {
      final count = requests.where((r) => r.wasteType == type).length;
      distribution[type.toString().split('.').last] = count / total * 100;
    }

    return distribution;
  }

  static Map<String, double> _calculateWeightTrend(List<ServiceRequest> requests) {
    final trend = <String, double>{};
    final now = DateTime.now();

    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));

      final weekRequests = requests.where((r) =>
      r.createdAt.isAfter(weekStart) && r.createdAt.isBefore(weekEnd)
      ).toList();

      final totalWeight = weekRequests.fold(0.0, (sum, r) => sum + r.estimatedWeight);
      trend['Week ${4 - i}'] = totalWeight;
    }

    return trend;
  }

  static Map<String, dynamic> _predictNextWeek(double weeklyAverage, Map<String, double> distribution) {
    final prediction = <String, dynamic>{};
    final predictedRequests = (weeklyAverage * (0.9 + Random().nextDouble() * 0.2)).round();

    prediction['totalRequests'] = predictedRequests;
    prediction['confidence'] = 85 + Random().nextInt(10);

    final typesPrediction = <String, int>{};
    for (final entry in distribution.entries) {
      typesPrediction[entry.key] = ((predictedRequests * entry.value / 100).round());
    }
    prediction['wasteTypes'] = typesPrediction;

    return prediction;
  }

  static List<Map<String, dynamic>> _generateMonthlyForecast(double weeklyAverage, Map<String, double> distribution) {
    final forecast = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < 4; i++) {
      final weekDate = now.add(Duration(days: i * 7));
      final variation = 0.8 + Random().nextDouble() * 0.4;
      final predictedRequests = (weeklyAverage * variation).round();

      forecast.add({
        'week': 'Week ${i + 1}',
        'date': weekDate,
        'requests': predictedRequests,
        'weight': predictedRequests * 5.5, // Average weight per request
      });
    }

    return forecast;
  }

  static List<String> _generateRecommendations(Map<String, double> distribution, Map<String, double> weightTrend) {
    final recommendations = <String>[];

    // Analyze distribution
    final topWasteType = distribution.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (topWasteType.value > 40) {
      recommendations.add('Focus on ${topWasteType.key} waste reduction programs');
    }

    // Analyze trend
    final trendValues = weightTrend.values.toList();
    if (trendValues.length >= 2) {
      final isIncreasing = trendValues.last > trendValues.first;
      if (isIncreasing) {
        recommendations.add('Waste generation is increasing. Consider awareness campaigns');
      } else {
        recommendations.add('Great! Waste generation is decreasing. Keep up the good work');
      }
    }

    // General recommendations
    recommendations.addAll([
      'Implement composting programs for organic waste',
      'Set up more recycling collection points',
      'Educate users about proper waste segregation',
      'Consider bulk collection schedules for high-demand areas',
    ]);

    return recommendations.take(4).toList();
  }

  static Map<String, dynamic> _getDefaultPrediction() {
    return {
      'weeklyAverage': 12.0,
      'wasteTypeDistribution': {
        'organic': 35.0,
        'plastic': 25.0,
        'paper': 20.0,
        'electronic': 10.0,
        'hazardous': 5.0,
        'mixed': 5.0,
      },
      'weightTrend': {
        'Week 1': 45.0,
        'Week 2': 52.0,
        'Week 3': 48.0,
        'Week 4': 55.0,
      },
      'nextWeekPrediction': {
        'totalRequests': 14,
        'confidence': 88,
        'wasteTypes': {
          'organic': 5,
          'plastic': 4,
          'paper': 3,
          'electronic': 1,
          'hazardous': 1,
          'mixed': 0,
        },
      },
      'monthlyForecast': [
        {'week': 'Week 1', 'requests': 14, 'weight': 77.0},
        {'week': 'Week 2', 'requests': 16, 'weight': 88.0},
        {'week': 'Week 3', 'requests': 13, 'weight': 71.5},
        {'week': 'Week 4', 'requests': 15, 'weight': 82.5},
      ],
      'recommendations': [
        'Focus on organic waste reduction programs',
        'Implement composting programs for organic waste',
        'Set up more recycling collection points',
        'Educate users about proper waste segregation',
      ],
    };
  }
}