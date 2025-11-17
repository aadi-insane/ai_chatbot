# System Flow and Real-Time Chat Implementation

This document outlines the overall system architecture of the Rails AI Chatbot application and details how a real-time chat experience is achieved using asynchronous JavaScript instead of Action Cable (WebSockets).

## Overall System Flow

The application follows a standard Model-View-Controller (MVC) pattern with a service layer for handling external API calls.

1.  **Authentication**: The application uses the `devise` gem to manage user authentication. The main chat interface is only accessible to signed-in users.

2.  **View**: The primary user interface is rendered from `app/views/home/index.html.erb`. This single page contains:
    *   A sidebar to display a history of previous chats (`@chats`).
    *   The main chat window where messages are displayed.
    *   An input form for the user to type and submit new messages.

3.  **Client-Side Logic**: All client-side interactivity is handled by a large `<script>` tag within `app/views/home/index.html.erb`. This script is responsible for the entire chat experience (see details below).

4.  **Routing**: When a user sends a message, the client-side JavaScript makes a `POST` request to the `/messages` endpoint. This is mapped to the `create` action in the `MessagesController`.

    ```ruby
    # config/routes.rb
    post 'messages', to: 'messages#create'
    resources :chats, only: [:index, :show, :create, :destroy] do
      resources :messages, only: [:create]
    end
    ```

5.  **Controller (`MessagesController`)**: The `create` action in `app/controllers/messages_controller.rb` handles the request. Its responsibilities are:
    *   Find or create a `Chat` instance.
    *   Save the user's new `Message` to the database.
    *   Instantiate and call a `ChatbotService` to get a response from the external AI model.
    *   The service returns a new `Message` object representing the bot's reply.
    *   The controller then renders the user's message and the bot's message into HTML using the `app/views/messages/_message.html.erb` partial.
    *   Finally, it returns a JSON response to the client containing the rendered HTML for both messages and the `chat_id`.

6.  **Service Layer (`ChatbotService`)**: The `app/services/chatbot_service.rb` is responsible for all communication with the external AI. It takes the user's message content, sends it to the AI API (e.g., OpenRouter), and returns the response content. This keeps the controller clean and separates concerns.

7.  **Models**:
    *   `User`: Manages user data via Devise.
    *   `Chat`: Represents a single conversation thread. A user `has_many` chats.
    *   `Message`: Represents a single message within a chat, belonging to both a `Chat` and a `User` (for the sender).

## Simulating Real-Time Chat with JavaScript

The application creates a smooth, real-time feel without the persistent connection of WebSockets. It does this by using a classic asynchronous request/response pattern, often referred to as AJAX.

The entire logic is contained within the `<script>` tag in `app/views/home/index.html.erb`.

### The Process

1.  **Intercepting Form Submission**: An event listener is attached to the "Submit" button. When clicked, it executes `e.preventDefault()`. This is the most critical step, as it stops the browser's default behavior of performing a full-page reload.

    ```javascript
    submitButton.addEventListener("click", function(e) {
      e.preventDefault();
      // ...
    });
    ```

2.  **Sending the Asynchronous Request**: The user's input is captured, and a `fetch` request is sent to the server in the background. This request includes the message content and the necessary CSRF token for security. While waiting, a "typing..." indicator is added to the UI for better user experience.

    ```javascript
    fetch("/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify(payload),
    })
    ```

3.  **Handling the Server Response**: The `.then()` blocks of the `fetch` promise wait for the server to respond. The server sends back a JSON object.

    ```javascript
    .then((response) => response.json())
    .then((data) => {
      // ... process the data
    })
    ```

4.  **Dynamically Updating the DOM**: The `data` object from the server contains the rendered HTML for the user's message (`data.user_message_html`) and the bot's response (`data.bot_message_html`). The JavaScript `appendMessage` function injects this HTML directly into the chat window's DOM.

    ```javascript
    // Function to append a message to the chat window
    function appendMessage(html) {
      chatWindow.insertAdjacentHTML('beforeend', html);
      scrollToBottom();
    }

    // Inside the .then() block
    appendMessage(data.user_message_html);
    appendMessage(data.bot_message_html);
    ```

This cycle of intercepting a user action, making a background request, and dynamically updating the page with the response gives the illusion of a continuous, real-time conversation.

---

## Rendering Formatted AI Responses with Redcarpet

### The Problem
The AI model returns responses formatted in Markdown, which includes newlines, code blocks (using backticks), and other formatting. When this text was rendered directly into the view, the browser did not interpret the Markdown, resulting in a single, unformatted block of text.

### The Solution
To properly display the formatted text, the Markdown content must be converted into HTML before it is rendered in the browser. This was achieved by using the `redcarpet` gem.

### Implementation Steps

1.  **Add the Gem**: The `redcarpet` gem was added to the `Gemfile` to provide Markdown processing capabilities.

    ```ruby
    # Gemfile
    gem "redcarpet"
    ```

2.  **Create a Markdown Helper**: A helper method named `markdown` was created in `app/helpers/application_helper.rb`. This method takes the raw text from the AI, uses `Redcarpet` to convert it into an HTML string, and marks it as `.html_safe` so that Rails will render the tags instead of escaping them.

    ```ruby
    # app/helpers/application_helper.rb
    module ApplicationHelper
      def markdown(text)
        options = {
          filter_html: true,
          hard_wrap: true,
          link_attributes: { rel: 'nofollow', target: "_blank" },
          space_after_headers: true,
          fenced_code_blocks: true
        }

        extensions = {
          autolink: true,
          superscript: true,
          disable_indented_code_blocks: true
        }

        renderer = Redcarpet::Render::HTML.new(options)
        markdown = Redcarpet::Markdown.new(renderer, extensions)

        markdown.render(text).html_safe
      end
    end
    ```

3.  **Update the View Partial**: The `app/views/messages/_message.html.erb` partial was updated to use the new `markdown` helper.

    **Before:**
    ```erb
    <div class="message-content">
      <p><%= message.content %></p>
    </div>
    ```

    **After:**
    ```erb
    <div class="message-content">
      <%= markdown(message.content) %>
    </div>
    ```
    This change ensures that whenever a message is rendered, its content is first passed through the `markdown` helper. The resulting HTML (with `<p>`, `<pre>`, `<code>`, and other tags) is then inserted directly into the view, allowing the browser to display it with the intended formatting.