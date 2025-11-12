import 'package:intl/intl.dart';

class WalkPenaltyCalculator {
  static Map<String, dynamic> calculatePenalty({
    required DateTime endTime,
    required double fee,
    required int walkDurationMinutes,
    String? status,
    DateTime? cancelTime,
  }) {
    final now = cancelTime ?? DateTime.now();

    if (status != null && status != 'En curso') {
      return {
        'penalty': 0.0,
        'percentage': 0.0,
        'reason': 'El paseo no estaba en curso, no se aplica penalización.'
      };
    }

    if (now.isAfter(endTime)) {
      return {
        'penalty': 0.0,
        'percentage': 0.0,
        'reason': 'El paseo ya había finalizado al momento de la cancelación.'
      };
    }

    final remainingMinutes = endTime.difference(now).inMinutes;

    final fractionRemaining = remainingMinutes / walkDurationMinutes;

    double penaltyPercentage;

    if (fractionRemaining > 0.5) {
      // Falta más del 50% del paseo
      penaltyPercentage = 0.2; // Penalización leve del 20%
    } else if (fractionRemaining > 0.25) {
      // Falta entre 25% y 50%
      penaltyPercentage = 0.4; // Penalización moderada del 40%
    } else {
      // Falta menos del 20%
      penaltyPercentage = 0.7; // Penalización fuerte del 70%
    }

    final penaltyAmount = double.parse((fee * penaltyPercentage).toStringAsFixed(2));

    return {
      'penalty': penaltyAmount,
      'percentage': penaltyPercentage,
      'remainingMinutes': remainingMinutes,
      'fractionRemaining': fractionRemaining,
      'cancelTime': DateFormat('HH:mm').format(now),
      'endTime': DateFormat('HH:mm').format(endTime),
      'reason': 'Cancelación de paseo en curso.',
    };
  }
}
