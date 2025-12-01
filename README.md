# Chat Ollama
![logo (ugly)](assets/horrible-logo.png)
![app preview](assets/app-preview.png)


This is a lightweight interface to chat with an Ollama server. You can run it quickly using Docker Compose or install it locally.
I don’t know why Linux users still don’t have a graphical interface, so I built my own.

## Features

* Connect to an Ollama server via URL
* Select a model from available options
* Send messages and receive responses
* Retain conversation context (toggleable)
* Display “thinking” indicator while model generates a response
* Clear chat history
* Highlight code blocks and copy them easily

## Install locally

### Build 
For a first installation you need to build the AppImage
#### Requirements
- Node.js
- NPM
- electron-builder

Run:
```bash
# build & install
sudo ./install.sh -b
```


### Installation
Once it's built you can easily install/uninstall with the same script file.
Run:
```bash
git clone git@github.com:ThomasDurand535/chat-ollama.git
cd ./chat-ollama
chmod +x install.sh

# install
sudo ./install.sh -i
# uninstall
sudo ./install.sh -u
```



## Run with Docker Compose
Simplest way, edit the docker-compose file as needed.


#### Requirements
- Docker
- Docker Compose

Run:

```bash
git clone git@github.com:ThomasDurand535/chat-ollama.git
cd ./chat-ollama

docker compose up -d
# or
docker compose down
```

By default, the interface will be accessible at **[http://localhost:7000](http://localhost:7000)**.
