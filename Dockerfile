FROM nginx:1.29.6-alpine
COPY src /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80