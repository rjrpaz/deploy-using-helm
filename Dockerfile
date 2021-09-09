FROM nginx:1.21.1-alpine
EXPOSE 80/tcp
RUN echo "Hello World" > /usr/share/nginx/html/index.html
