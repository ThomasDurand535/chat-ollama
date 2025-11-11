# Chat Ollama

This is a lightweight web interface to chat with an Ollama server. You can run it quickly using Docker Compose.

## Run

```bash
docker compose up -d
```

By default, the interface will be accessible on **[http://localhost:7000](http://localhost:7000)**.

## Features

* Connect to an Ollama server via URL
* Select a model from available options
* Send messages and receive responses
* Retain conversation context (toggleable)
* Display “thinking” indicator while model generates a response
* Clear chat history
* Highlight code blocks and copy them easily
