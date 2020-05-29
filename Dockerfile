FROM node:latest

WORKDIR /app

COPY package.json server.js yarn.lock /app/

RUN yarn install

EXPOSE 8081

ENTRYPOINT yarn start