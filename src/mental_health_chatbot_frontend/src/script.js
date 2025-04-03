document.addEventListener('DOMContentLoaded', function () {
  const sendBtn = document.getElementById('sendBtn');
  const messageInput = document.getElementById('messageInput');
  const conversation = document.getElementById('conversation');
  let synth = window.speechSynthesis;
  let voices = [];

  // Initialize speech synthesis
  function initSpeech() {
      voices = synth.getVoices();
      if (voices.length === 0 && synth.onvoiceschanged !== undefined) {
          synth.onvoiceschanged = initSpeech;
      }
  }
  initSpeech();

  // Improved bot response simulation
  function getBotResponse(userMessage) {
      const responses = {
          "hello": "Hello! How are you feeling today?",
          "stress": "I understand stress can be challenging. Let's explore some breathing exercises.",
          "sad": "I'm sorry you're feeling this way. Would you like to talk about it?",
          "default": "Thank you for sharing. Could you elaborate more on that?"
      };
      
      const cleanMsg = userMessage.toLowerCase();
      return responses[cleanMsg] || responses.default;
  }

  function addMessage(text, sender) {
      const messageDiv = document.createElement('div');
      messageDiv.className = `message ${sender}`;
      messageDiv.textContent = text;
      conversation.appendChild(messageDiv);
      conversation.scrollTop = conversation.scrollHeight;
  }

  function speakText(text) {
      if (!synth || !text) return;
      
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.voice = voices.find(v => v.lang === 'en-US') || voices[0];
      utterance.rate = 0.9;
      synth.speak(utterance);
  }

  async function handleSend() {
      const userMessage = messageInput.value.trim();
      if (!userMessage) {
          messageInput.classList.add('error');
          return;
      }

      try {
          messageInput.classList.remove('error');
          addMessage(userMessage, 'user');
          messageInput.value = '';
          sendBtn.disabled = true;

          // Simulate async API call
          const botResponse = await new Promise(resolve => {
              setTimeout(() => {
                  resolve(getBotResponse(userMessage));
              }, 800);
          });

          addMessage(botResponse, 'bot');
          speakText(botResponse);
      } catch (error) {
          console.error('Error:', error);
          addMessage('Sorry, there was an error processing your request.', 'bot');
      } finally {
          sendBtn.disabled = false;
      }
  }

  // Event listeners
  sendBtn.addEventListener('click', handleSend);
  messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          handleSend();
      }
  });
});