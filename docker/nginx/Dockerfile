FROM nginx:1.17.8-alpine

ENV DOMAIN=forfect.app

# envsubst
RUN apk add gettext bash
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.tmpl /etc/nginx/conf.d
RUN envsubst '\${DOMAIN}' < /etc/nginx/conf.d/nginx.tmpl > /etc/nginx/conf.d/nginx.conf