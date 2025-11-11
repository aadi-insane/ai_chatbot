# AI Chatbot

This is a web-based chatbot application built with Ruby on Rails 8. It leverages the Hotwire stack (Turbo, Stimulus) for a modern, single-page application-like user experience without writing much custom JavaScript. The backend integrates with AI models through the OpenRouter API to provide intelligent responses.

## Features

- **User Authentication**: Secure user registration and login functionality provided by Devise.
- **Real-time Chat Interface**: A dynamic chat interface powered by Hotwire that updates without full page reloads.
- **Persistent Chat History**: Conversations are saved to the database, allowing users to review past interactions.
- **AI Integration**: Connects to various large language models via OpenRouter.
- **Containerized**: Includes a `Dockerfile` for easy setup and deployment using Docker.

## Technology Stack

- **Backend**: Ruby on Rails 8.0
- **Frontend**: Hotwire (Turbo & Stimulus), Importmap Rails
- **Database**: PostgreSQL
- **Authentication**: Devise
- **AI Service**: OpenRouter
- **Web Server**: Puma
- **Testing**: Minitest, Capybara for system tests

## Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.2.8
- Bundler
- PostgreSQL
- Node.js (for JavaScript runtime)
- Docker and Docker Compose (for containerized setup)

You will also need an **OpenRouter API key**.

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/aadi-insane/ai_chatbot.git
cd ai_chatbot
```

### 2. Configure Environment Variables

This project uses Rails' encrypted credentials (`credentials.yml.enc`) to manage sensitive information. You will need to add your OpenRouter API key to it.

First, set your editor for credentials:

```bash
export EDITOR="code --wait" # Or your preferred editor
```

Now, edit the credentials file:

```bash
rails credentials:edit
```

Add your OpenRouter access token like this:

```yml
open_router:
  access_token: "your_open_router_api_key"
```

Save and close the file. It will be automatically encrypted.

### 3. Install Dependencies

Install the required Ruby gems:

```bash
bundle install
```

### 4. Database Setup

Create and migrate the database. Ensure your PostgreSQL server is running and that the `config/database.yml` file is configured correctly for your environment.

```bash
rails db:create
rails db:migrate
```

### 5. Run the Application

Start the Rails server:

```bash
rails server
```

You can now access the application at [http://localhost:3000](http://localhost:3000).

## Docker Setup

Alternatively, you can use Docker to build and run the application in a containerized environment.

### 1. Build the Docker Image

```bash
docker build -t ai-chatbot .
```

### 2. Run the Container

To run the application, you need to pass the `RAILS_MASTER_KEY` to the container. This key is found in the `config/master.key` file (which should not be committed to version control).

```bash
docker run -p 3000:3000 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  ai-chatbot
```

The application will be available at [http://localhost:3000](http://localhost:3000).

**Note**: For a production-ready Docker setup, it is recommended to use Docker Compose to manage the application and database services together.

## Testing

To run the test suite, use the following command:

```bash
rails test
```

To run system tests, which use a headless browser to simulate user interactions:

```bash
rails test:system
```

## How It Works

- **User Interaction**: Users sign up or log in and are presented with a chat interface.
- **Chat Submission**: When a user sends a message, a `POST` request is sent to the `/chatbot` endpoint.
- **Controller**: The `ChatbotController` receives the request and uses the `ChatbotService` to process the message.
- **Service Layer**: The `ChatbotService` communicates with the OpenRouter API, sending the user's message and receiving a response from the configured AI model.
- **Database**: The user's message and the AI's response are saved as `Message` records, associated with a `Chat` record for that user.
- **Real-time Updates**: The controller responds with Turbo Streams to dynamically update the chat interface with the new messages.

## Contributing

Contributions are welcome! Please feel free to submit a pull request.

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/my-new-feature`).
5. Create a new Pull Request.

## License

This project is licensed under the MIT License.
