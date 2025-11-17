# Dockerfile for Astro dev server
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install dependencies
# Copy package files first for better layer caching
COPY package*.json ./

# Install all dependencies (including devDependencies for development)
RUN npm ci

# Copy the rest of the application
COPY . .

# Expose Astro dev server port
EXPOSE 4321

# Start the dev server
# Using --host 0.0.0.0 to allow connections from outside the container
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
