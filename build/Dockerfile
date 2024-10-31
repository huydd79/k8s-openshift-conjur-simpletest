FROM alpine
COPY ./conjur-test* /
RUN apk --update add curl
RUN chmod +x /conjur-test*
CMD ["/conjur-test-init.sh"]