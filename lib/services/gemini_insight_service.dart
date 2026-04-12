// lib/services/gemini_insight_service.dart
//
// Calls Gemini 2.5 Flash with a tight structured prompt.
// Falls back to high-quality mock templates if:
//   - API call fails
//   - Response times out (3s)
//   - Response is malformed

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/policy_model.dart';

const String _geminiApiKey = 'AIzaSyBkzYxIGc8wia4JALLx7hSWtrriz0_H83E';
const String _geminiUrl =
    'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey';

class GeminiInsightService {
  /// Generates a 2–3 sentence AI narrative for the simulation result.
  /// Returns the narrative string and a flag indicating if it was AI-generated.
  static Future<({String narrative, bool isAi})> generateNarrative({
    required PolicyModel policy,
    required double reductionPercent,
    required int days,
    required SimulationIntensity intensity,
    required double baseAqi,
    required double finalAqi,
  }) async {
    try {
      final result = await _callGemini(
        policy: policy,
        reductionPercent: reductionPercent,
        days: days,
        intensity: intensity,
        baseAqi: baseAqi,
        finalAqi: finalAqi,
      ).timeout(const Duration(seconds: 5));
      return (narrative: result, isAi: true);
    } catch (_) {
      return (
      narrative: _mockNarrative(policy, reductionPercent, days),
      isAi: false,
      );
    }
  }

  static Future<String> _callGemini({
    required PolicyModel policy,
    required double reductionPercent,
    required int days,
    required SimulationIntensity intensity,
    required double baseAqi,
    required double finalAqi,
  }) async {
    final prompt = '''
You are an air quality policy analyst. Write exactly 2 sentences explaining the environmental impact of the following simulation result. Be specific, scientific, and concise. Do not use bullet points, headers, or markdown. Output only the 2 sentences, nothing else.

Policy: ${policy.name}
Description: ${policy.shortDescription}
Enforcement intensity: ${intensity.label}
Simulation duration: $days days
Starting AQI: ${baseAqi.toStringAsFixed(0)}
Projected AQI after $days days: ${finalAqi.toStringAsFixed(0)}
AQI reduction: ${reductionPercent.toStringAsFixed(1)}%
Primary emission source affected: ${policy.primaryContributor}
Secondary environmental effect: ${policy.secondaryEffect}

Write the 2-sentence explanation now:
''';

    final response = await http.post(
      Uri.parse(_geminiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 150,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (text == null || (text as String).trim().isEmpty) {
      throw Exception('Empty Gemini response');
    }

    return text.trim();
  }

  /// High-quality mock narratives per policy.
  /// Used as fallback — written to the same standard as expected AI output.
  static String _mockNarrative(
      PolicyModel policy,
      double reductionPercent,
      int days,
      ) {
    final pct = reductionPercent.toStringAsFixed(1);

    switch (policy.id) {
      case 'odd_even':
        return 'Restricting vehicles to alternate days cuts road traffic by approximately 40%, '
            'directly reducing nitrogen oxide and fine particulate emissions during peak hours. '
            'Over $days days, this translates to a $pct% AQI improvement as NO₂ levels fall, '
            'breaking the photochemical cycle that produces secondary PM2.5.';

      case 'work_from_home':
        return 'A 50% work-from-home mandate eliminates the most congested commute windows, '
            'reducing vehicular CO and hydrocarbon emissions by roughly 30% during morning and evening peaks. '
            'After $days days of sustained compliance, the $pct% AQI reduction reflects both direct emission '
            'cuts and a measurable drop in ground-level ozone formation.';

      case 'construction_ban':
        return 'Construction activity is responsible for up to 60% of coarse particulate (PM10) loading in urban air, '
            'and halting it removes this source almost entirely within 24–48 hours. '
            'The projected $pct% AQI improvement over $days days is driven primarily by reduced fugitive dust, '
            'which also lowers the PM10-to-PM2.5 conversion rate in stagnant air conditions.';

      case 'industrial_control':
        return 'Heavy industry contributes disproportionately to SO₂ and NOₓ concentrations, '
            'both of which are precursors to sulfate and nitrate aerosols that dominate winter AQI spikes. '
            'Enforcing emission caps achieves the steepest $pct% reduction over $days days because '
            'industrial sources operate continuously, unlike traffic which has natural off-peak lulls.';

      case 'public_transport_boost':
        return 'Shifting commuters to high-capacity public transit reduces the total vehicle-kilometers '
            'traveled in the city by an estimated 25%, with proportional cuts to tailpipe PM2.5 and NOₓ. '
            'The $pct% AQI gain over $days days also incorporates a secondary benefit: '
            'lower traffic density reduces road dust re-suspension, a often-overlooked pollution source.';

      default:
        return 'This policy intervention reduces the primary emission sources contributing to urban AQI. '
            'Over $days days of consistent enforcement, the projected $pct% reduction reflects '
            'measurable improvements in fine particulate and gaseous pollutant concentrations.';
    }
  }
}