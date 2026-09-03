FROM nginx:1.31.5-alpine
RUN apk update && apk upgrade
COPY src /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80