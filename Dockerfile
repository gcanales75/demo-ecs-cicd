FROM httpd:2.4

RUN apt-get update -y && apt-get install -y wget
COPY website/index.html /usr/local/apache2/htdocs/
COPY website/font /usr/local/apache2/htdocs/font
COPY website/images /usr/local/apache2/htdocs/images

EXPOSE 80

CMD wget 'http://169.254.170.2/v2/metadata' -O /usr/local/apache2/htdocs/metadata.json && apachectl -D FOREGROUND