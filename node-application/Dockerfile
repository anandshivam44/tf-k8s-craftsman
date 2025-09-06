# Use official Node.js LTS image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Set environment
ENV NODE_ENV=production
ENV PORT=3000
# Provide a sensible default for local/dev-compose; override in prod
ENV MONGODB_URL=mongodb://mongo:27017/database

# Install app dependencies using npm ci for reproducible builds
COPY package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund

# Copy app source
COPY . .

# Ensure non-root ownership
RUN chown -R node:node /app

# Expose the port your app listens on
EXPOSE 3000

# Run as non-root user for security
USER node

# Start the app with PM2 runtime (defined in package.json -> scripts.prod)
CMD ["npm", "run", "prod"]
