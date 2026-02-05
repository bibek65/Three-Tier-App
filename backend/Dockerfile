FROM node:20-alpine

# Create app directory with proper permissions
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy entrypoint script and make executable
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Copy source code
COPY src/ ./src/

EXPOSE 5001

CMD ["./entrypoint.sh"]