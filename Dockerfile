# Base on offical Node.js Alpine image
FROM --platform=linux/amd64 node:18-buster as builder

# Set working directory
WORKDIR /usr/app

# Copy package.json and package-lock.json before other files
# Utilise Docker cache to save re-installing dependencies if unchanged
COPY package*.json ./


# Install dependencies
RUN npm install -g next
RUN npm install

# Copy all files
COPY ./ ./

# Build app
RUN npm run build

####################################################### 

# bundle static assets with nginx
FROM nginx:1.21.0-alpine as production
ENV NODE_ENV production

WORKDIR /usr/app

# Remove any existing config files
RUN rm /etc/nginx/conf.d/*

# Copy nginx config files
# *.conf files in conf.d/ dir get included in main config
COPY ./config/nginx /etc/nginx/

# COPY package.json next.config.js .env* ./
# COPY --from=builder /usr/app/public ./public
COPY --from=builder /usr/app/.next ./.next
COPY --from=builder /usr/app/node_modules ./node_modules

# expose port 80 for nginx
EXPOSE 80
# start nginx
CMD ["nginx", "-g", "daemon off;"]