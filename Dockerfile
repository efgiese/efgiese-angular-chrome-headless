FROM debian:stable-slim

RUN apt-get update -qq
RUN apt-get install -yy wget curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
	apt-get update -qq && apt-get install -y nodejs && \
  npm i -g npm@6

RUN node -v

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y google-chrome-stable xvfb
RUN npm -v
RUN apt update && apt install -y procps
RUN apt update && apt install -y sshpass
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*
