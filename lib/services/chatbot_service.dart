import 'dart:math';
import '../models/chat_message.dart';

class ChatbotService {
  static final List<String> _wasteManagementResponses = [
    "I can help you with waste management! What would you like to know?",
    "Here are some waste sorting tips: Separate organic, plastic, paper, and electronic waste.",
    "Did you know? Composting organic waste can reduce your household waste by 30%!",
    "For electronic waste, always use certified e-waste recycling centers.",
    "Plastic bottles should be cleaned before recycling for better processing.",
    "Paper waste should be kept dry and free from food contamination.",
    "Hazardous waste like batteries and chemicals need special disposal methods.",
  ];

  static final Map<String, List<String>> _keywordResponses = {
    'organic': [
      "Organic waste includes food scraps, vegetable peels, and garden waste. It's perfect for composting!",
      "Tip: Keep organic waste separate and consider starting a compost bin at home.",
    ],
    'plastic': [
      "Plastic waste should be clean and sorted by type. Look for recycling codes on containers.",
      "Remember: Not all plastics are recyclable. Check with your local recycling center.",
    ],
    'paper': [
      "Paper waste is highly recyclable! Keep it dry and remove any plastic coatings.",
      "Newspapers, magazines, and cardboard are all great for recycling.",
    ],
    'electronic': [
      "E-waste contains valuable materials but also harmful substances. Always use certified recyclers.",
      "Many electronics stores offer take-back programs for old devices.",
    ],
    'collection': [
      "You can schedule waste collection through our app. Just create a new request!",
      "Our drivers will pick up your waste at the scheduled time. Make sure it's properly sorted.",
    ],
    'schedule': [
      "To schedule a pickup, go to 'Create Request' and fill in your details.",
      "You can track your collection request in real-time through the app.",
    ],
    'recycle': [
      "Recycling helps reduce landfill waste and conserves natural resources.",
      "The 3 R's: Reduce, Reuse, Recycle - in that order of priority!",
    ],
  };

  static final List<String> _suggestions = [
    "How do I sort my waste?",
    "Schedule a pickup",
    "Recycling tips",
    "What can I compost?",
    "E-waste disposal",
    "Waste reduction tips",
  ];

  static ChatMessage generateResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    String response;

    // Check for keywords
    String? matchedKeyword;
    for (String keyword in _keywordResponses.keys) {
      if (message.contains(keyword)) {
        matchedKeyword = keyword;
        break;
      }
    }

    if (matchedKeyword != null) {
      final responses = _keywordResponses[matchedKeyword]!;
      response = responses[Random().nextInt(responses.length)];
    } else if (message.contains('hello') || message.contains('hi')) {
      response = "Hello! I'm your waste management assistant. How can I help you today?";
    } else if (message.contains('help')) {
      response = "I can help you with:\n• Waste sorting and recycling\n• Scheduling pickups\n• Waste reduction tips\n• Disposal guidelines";
    } else if (message.contains('thank')) {
      response = "You're welcome! Feel free to ask if you have more questions about waste management.";
    } else {
      response = _wasteManagementResponses[Random().nextInt(_wasteManagementResponses.length)];
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  static List<String> getSuggestions() {
    return _suggestions;
  }

  static ChatMessage generateWasteTip() {
    final tips = [
      "💡 Tip: Rinse containers before recycling to avoid contamination.",
      "🌱 Did you know? Food waste makes up about 30% of household waste.",
      "♻️ Fact: Recycling one aluminum can saves enough energy to power a TV for 3 hours.",
      "🗂️ Organize: Use separate bins for different waste types to make sorting easier.",
      "🌍 Impact: Proper waste management can reduce greenhouse gas emissions by 20%.",
    ];

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: tips[Random().nextInt(tips.length)],
      isUser: false,
      timestamp: DateTime.now(),
      type: 'waste_tip',
    );
  }
}