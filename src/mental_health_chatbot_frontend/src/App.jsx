import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from "../../declarations/mental_health_chatbot_backend";
const canisterId = 'bkyz2-fmaaa-aaaaa-qaaaq-cai';

// Create an agent instance for local development
const agent = new HttpAgent({
  host: "http://localhost:4943",
  verifyQuerySignatures: false
});

// Global conversation history array (each entry: { sender, content, language })
let conversationHistory = [];
// Current language mode ("en" for English, "sw" for Swahili)
let currentLanguage = "en";

// Initialize speech recognition (Web Speech API)
const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
const recognition = SpeechRecognition ? new SpeechRecognition() : null;
if (recognition) {
  recognition.lang = "en-US";
  recognition.continuous = false;
  recognition.interimResults = false;
}

// Initialize when DOM is loaded
document.addEventListener("DOMContentLoaded", init);

async function init() {
  try {
    await agent.fetchRootKey();
    const chatbotActor = Actor.createActor(idlFactory, { agent, canisterId });
    
    // Set up event listeners
    document.getElementById("sendBtn").addEventListener("click", () => handleSendMessage(chatbotActor));
    document.getElementById("messageInput").addEventListener("keypress", (e) => {
      if (e.key === "Enter") handleSendMessage(chatbotActor);
    });
    
    if (recognition) {
      document.getElementById("micBtn").addEventListener("click", () => {
        recognition.start();
      });
      recognition.addEventListener("result", (e) => {
        const transcript = e.results[0][0].transcript;
        document.getElementById("messageInput").value = transcript;
      });
      recognition.addEventListener("error", (err) => {
        console.error("Speech recognition error:", err);
      });
    }
    
    // Text-to-speech button
    document.getElementById("ttsBtn").addEventListener("click", () => {
      speakText(getLatestBotMessage());
    });
    
    // Translation toggle button
    document.getElementById("translateBtn").addEventListener("click", async () => {
      // Toggle language between English and Swahili
      currentLanguage = currentLanguage === "en" ? "sw" : "en";
      await translateConversation(currentLanguage);
      updateConversationView();
    });
    
    // Initially clear conversation area
    document.getElementById("conversation").innerHTML = "";
    
    // Optionally, load conversation history from backend
    // await updateConversationView(chatbotActor);
  } catch (error) {
    console.error("Initialization error:", error);
    document.getElementById("conversation").textContent = "Failed to initialize: " + error.message;
  }
}
async function handleSendMessage(chatbotActor) {
  const inputElem = document.getElementById("messageInput");
  const message = inputElem.value.trim();
  if (!message) return;
  
  // Record user message in conversation history (assumed language: English)
  conversationHistory.push({ sender: "User", content: message, language: "en" });
  updateConversationView();
  
  try {
    // Send message to backend
    const response = await chatbotActor.sendMessage(message);
    // Assume response is a string (bot reply in English)
    conversationHistory.push({ sender: "Alimah", content: response, language: "en" });
    inputElem.value = "";
    updateConversationView();
    // Automatically announce the bot's reply using TTS
    speakText(response);
  } catch (err) {
    console.error("Error sending message:", err);
    alert("Failed to send message. See console for details.");
  }
}

function updateConversationView() {
  const conversationElem = document.getElementById("conversation");
  conversationElem.innerHTML = ""; // Clear current view

  conversationHistory.forEach(entry => {
    // Create a bubble for each message
    const bubble = document.createElement("div");
    // Base styling for the bubble
    bubble.style.maxWidth = "70%";
    bubble.style.padding = "10px 15px";
    bubble.style.margin = "10px";
    bubble.style.borderRadius = "20px";
    bubble.style.fontSize = "1rem";
    bubble.style.lineHeight = "1.4";
    
    if (entry.sender === "Alimah") {
      // Bot message: align left
      bubble.style.backgroundColor = "#f1f0f0";
      bubble.style.alignSelf = "flex-start";
      bubble.style.marginRight = "auto";
    } else {
      // User message: align right
      bubble.style.backgroundColor = "#dcf8c6";
      bubble.style.alignSelf = "flex-end";
      bubble.style.marginLeft = "auto";
    }
    
    bubble.textContent = entry.content;
    
    // Wrap bubble in a container div with flex styling
    const container = document.createElement("div");
    container.style.display = "flex";
    container.style.flexDirection = "column";
    container.style.width = "100%";
    container.appendChild(bubble);
    
    conversationElem.appendChild(container);
  });
}

// Function to get the latest bot message (for TTS)
function getLatestBotMessage() {
  for (let i = conversationHistory.length - 1; i >= 0; i--) {
    if (conversationHistory[i].sender === "Alimah") return conversationHistory[i].content;
  }
  return "";
}

// Function to perform text-to-speech
function speakText(text) {
  if (!window.speechSynthesis) return;
  const utterance = new SpeechSynthesisUtterance(text);
  // Optionally set language (based on currentLanguage)
  utterance.lang = currentLanguage === "en" ? "en-US" : "sw-KE";
  window.speechSynthesis.speak(utterance);
}

// Function to translate the entire conversation to targetLang ("en" or "sw")
async function translateConversation(targetLang) {
  // For each message, call the translation API if its current language is not targetLang
  const translatePromises = conversationHistory.map(async (entry, index) => {
    if (entry.language !== targetLang) {
      const translated = await translateText(entry.content, entry.language, targetLang);
      // Update the conversationHistory with translated content and language tag
      conversationHistory[index] = { ...entry, content: translated, language: targetLang };
    }
  });
  await Promise.all(translatePromises);
}

// Function to call translation API (using MyMemory as an example)
async function translateText(text, sourceLang, targetLang) {
  const url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${sourceLang}|${targetLang}`;
  try {
    const res = await fetch(url);
    const data = await res.json();
    return data.responseData.translatedText || text;
  } catch (error) {
    console.error("Translation error:", error);
    return text;
  }
}

document.addEventListener("DOMContentLoaded", init);
