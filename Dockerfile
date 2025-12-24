FROM node:20-alpine

# Install required dependencies INCLUDING PostgreSQL
RUN apk add --no-cache python3 make g++ libc6-compat postgresql-client postgresql-dev

WORKDIR /app

# Copy package files from strapi directory
COPY strapi-app/package*.json ./

# Install all dependencies including pg from package.json
RUN npm install

# Copy the rest of the Strapi app
COPY strapi-app/ ./

RUN npm run build

EXPOSE 1337
CMD ["npm", "start"]