# Using the lightweight alpine version
FROM nginx:alpine

# Copying index.html to the default Nginx public folder
COPY index.html /usr/share/nginx/html/index.html

# Exposing port 80 for the Load Balancer
EXPOSE 80

# Run Command
CMD ["nginx", "-g", "daemon off;"]