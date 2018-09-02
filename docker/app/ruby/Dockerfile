FROM ruby:2.4.2

ARG GIT_URL=https://github.com/isucon/isucon7-qualify.git

WORKDIR /home/isucon/isubata/webapp/ruby

EXPOSE 5000

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-p", "5000", "-t", "10"]
