import Text "mo:base/Text";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";

actor Alimah {
  // Define types for our mental health chatbot
  type Message = {
    sender: Text;
    content: Text;
    timestamp: Int;
  };

  type ConversationState = {
    history: [Message];
    userName: Text;
    userPreferences: UserPreferences;
  };

  type UserPreferences = {
    favoriteActivities: [Text];
    copingStrategies: [Text];
    supportNetwork: [Text];
  };

  type ResourceCategory = {
    name: Text;
    resources: [Resource];
  };

  type Resource = {
    title: Text;
    description: Text;
    link: ?Text;
  };

  // Mutable state to hold conversation data
  stable var state : ConversationState = {
    history = [];
    userName = "friend";
    userPreferences = {
      favoriteActivities = [];
      copingStrategies = [];
      supportNetwork = [];
    };
  };

  // Stable counter for cycling through quiz questions
  stable var quizIndex : Nat = 0;

  // Knowledge base for Alimah
  let _wellnessActivities : [Text] = [
    "deep breathing exercises", 
    "progressive muscle relaxation",
    "guided meditation",
    "gentle stretching",
    "mindful walking",
    "journaling your thoughts",
    "listening to calming music",
    "connecting with a loved one"
  ];

  let musicSuggestions : [Text] = [
    "calming classical music like Debussy's Clair de Lune",
    "gentle nature sounds like rainfall or ocean waves",
    "low-fi beats to help you unwind",
    "acoustic covers of your favorite songs",
    "ambient music designed for mindfulness"
  ];

  let workoutSuggestions : [Text] = [
    "a gentle yoga session focusing on deep breathing",
    "a quiet walk in nature",
    "light stretching exercises to ease tension",
    "tai chi for balance and calm",
    "dancing to your favorite soothing tunes"
  ];

  let mentalHealthResources : [ResourceCategory] = [
    {
      name = "Crisis Support";
      resources = [
        {
          title = "National Suicide Prevention Lifeline";
          description = "24/7 support for those in distress";
          link = ?"988";
        },
        {
          title = "Crisis Text Line";
          description = "Text HOME to 741741 for crisis support";
          link = ?"741741";
        }
      ];
    },
    {
      name = "Self-Help";
      resources = [
        {
          title = "Mindfulness Practices";
          description = "Daily exercises to promote mindfulness and calm";
          link = null;
        },
        {
          title = "Sleep Hygiene";
          description = "Tips for improving sleep quality";
          link = null;
        }
      ];
    }
  ];

  // Array of quiz questions on mental health
  private func getRandomQuizQuestion() : Text {
    let questions : [Text] = [
      "On a scale from 1 to 10, how would you rate your current mood?",
      "Do you find it challenging to relax during stressful times?",
      "How often do you take a moment to reflect on your feelings?",
      "Which of these helps you the most: reading an inspiring article, listening to calming music, or going for a quiet walk?"
    ];
    let idx = quizIndex % Array.size(questions);
    quizIndex += 1;
    return questions[idx];
  };

  // Helper functions
  private func addToHistory(sender: Text, content: Text, time: Int) : () {
    let message : Message = {
      sender = sender;
      content = content;
      timestamp = time;
    };
    
    let currentHistory = Buffer.fromArray<Message>(state.history);
    currentHistory.add(message);
    
    state := {
      history = Buffer.toArray(currentHistory);
      userName = state.userName;
      userPreferences = state.userPreferences;
    };
  };

  private func containsText(text: Text, pattern: Text) : Bool {
    let textLower = Text.toLowercase(text);
    let patternLower = Text.toLowercase(pattern);
    Text.contains(textLower, #text patternLower)
  };

  private func containsAny(text: Text, patterns: [Text]) : Bool {
    for (pattern in patterns.vals()) {
      if (containsText(text, pattern)) {
        return true;
      };
    };
    return false;
  };

  private func getRandomElement(array: [Text]) : Text {
    if (Array.size(array) == 0) {
      return "";
    };
    return array[0];
  };

  private func generateMusicResponse() : Text {
    "Sometimes, a soothing melody can help ease your mind. Have you considered listening to " # 
    getRandomElement(musicSuggestions) #
    "? It might be a gentle way to lift your spirits.";
  };

  private func generateWorkoutResponse() : Text {
    "Physical movement—even a quiet walk or gentle stretching—can help clear your mind. Maybe try " # 
    getRandomElement(workoutSuggestions) #
    " for a moment of peace.";
  };

  private func generateSleepResponse() : Text {
    "I see you’re having trouble sleeping. Sometimes a calm, consistent bedtime routine and practicing sleep hygiene—like avoiding screens before bed—can help. Would you like some more tips or resources on sleep?";
  };

  private func generateSevereResponse() : Text {
    "I'm truly concerned about what you're sharing. It sounds like you're in a lot of pain. While I'm here to support you, it might be really important to speak with a trusted healthcare professional as soon as possible. Please consider reaching out to someone who can offer immediate help.";
  };

  private func generateGeneralResponse() : Text {
    "Thank you for sharing, " # state.userName # ". Sometimes, simple acts of self-care—like reading a comforting article, listening to calming music, or taking a quiet moment for yourself—can help. I'm here to listen. Would you like to talk more about how you're feeling or try a simple mindfulness exercise?";
  };

  // Public functions
  public query func getConversationHistory() : async [Message] {
    state.history;
  };

  public func setUserName(name: Text) : async Text {
    state := {
      history = state.history;
      userName = name;
      userPreferences = state.userPreferences;
    };
    
    "Hello, " # name # "! I'm Alimah, your supportive companion. I'm here to listen and chat whenever you need. How are you feeling today?";
  };

  public func addUserPreference(category: Text, item: Text) : async Bool {
    var updated = false;
    
    if (category == "activities") {
      let currentActivities = Buffer.fromArray<Text>(state.userPreferences.favoriteActivities);
      currentActivities.add(item);
      
      state := {
        history = state.history;
        userName = state.userName;
        userPreferences = {
          favoriteActivities = Buffer.toArray(currentActivities);
          copingStrategies = state.userPreferences.copingStrategies;
          supportNetwork = state.userPreferences.supportNetwork;
        };
      };
      updated := true;
    } else if (category == "coping") {
      let currentStrategies = Buffer.fromArray<Text>(state.userPreferences.copingStrategies);
      currentStrategies.add(item);
      
      state := {
        history = state.history;
        userName = state.userName;
        userPreferences = {
          favoriteActivities = state.userPreferences.favoriteActivities;
          copingStrategies = Buffer.toArray(currentStrategies);
          supportNetwork = state.userPreferences.supportNetwork;
        };
      };
      updated := true;
    } else if (category == "support") {
      let currentSupport = Buffer.fromArray<Text>(state.userPreferences.supportNetwork);
      currentSupport.add(item);
      
      state := {
        history = state.history;
        userName = state.userName;
        userPreferences = {
          favoriteActivities = state.userPreferences.favoriteActivities;
          copingStrategies = state.userPreferences.copingStrategies;
          supportNetwork = Buffer.toArray(currentSupport);
        };
      };
      updated := true;
    };
    
    updated;
  };

  public func greet(name: Text) : async Text {
    "Hello, " # name # "! I'm Alimah, your supportive companion. How are you feeling today?";
  };

  // Main interaction function
  public shared (message) func sendMessage(userMessage: Text) : async Text {
    let currentTime = 0; // For simplicity; replace with a proper timestamp if needed
    
    // Record the user's message
    addToHistory(Principal.toText(message.caller), userMessage, currentTime);
    
    // Analyze the user's message and generate an appropriate response
    let response = if (containsAny(userMessage, ["suicid", "kill myself", "end my life", "don't want to live"])) {
      generateSevereResponse();
    } else if (containsAny(userMessage, ["music", "listen", "song", "melody", "tune"])) {
      generateMusicResponse();
    } else if (containsAny(userMessage, ["workout", "exercise", "run", "jog", "gym", "physical", "move"])) {
      generateWorkoutResponse();
    } else if (containsAny(userMessage, ["sleep", "insomnia", "trouble sleeping"])) {
      generateSleepResponse();
    } else if (containsAny(userMessage, ["quiz", "test", "assessment"])) {
      "Let's try a mental health quiz: " # getRandomQuizQuestion();
    } else if (containsText(userMessage, "anxiety")) {
      "I understand anxiety can be overwhelming, " # state.userName # ". Sometimes, a few slow, mindful breaths can help ground you. Would you like to try a brief breathing exercise?";
    } else if (containsText(userMessage, "depression")) {
      "I'm here with you, " # state.userName # ". When depression feels heavy, even small acts of self-care—like reading a comforting article or listening to gentle music—can help. How have you been coping lately?";
    } else if (containsText(userMessage, "stress")) {
      "It sounds like you're under a lot of stress, " # state.userName # ". Perhaps taking a short break to enjoy some soothing music or reading something uplifting might ease the tension. What do you think?";
    } else if (containsText(userMessage, "lonely")) {
      "Feeling lonely can be very painful, " # state.userName # ". Remember, you're not alone. Sometimes reaching out to a friend or engaging in a comforting activity can help. Would you like some suggestions?";
    } else if (containsAny(userMessage, ["tired", "exhausted", "no energy", "fatigue"])) {
      "It sounds like you're really tired, " # state.userName # ". Maybe it's time to rest and take care of yourself. Even a short nap or quiet moment can help recharge your energy.";
    } else {
      generateGeneralResponse();
    };
    
    // Record Alimah's response
    addToHistory("Alimah", response, currentTime);
    
    response;
  };

  public query func getResources(category: Text) : async [Resource] {
    for (cat in mentalHealthResources.vals()) {
      if (Text.toLowercase(cat.name) == Text.toLowercase(category)) {
        return cat.resources;
      };
    };
    return [];
  };
}
