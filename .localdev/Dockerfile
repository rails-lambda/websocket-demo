FROM public.ecr.aws/lambda/ruby:3.2 as builder
RUN yum install -y git
COPY src /var/task
ENV BUNDLE_SILENCE_ROOT_WARNING=true
ENV BUNDLE_GEMFILE=/var/task/Gemfile
ENV BUNDLE_PATH=/var/task/vendor/bundle
RUN bundle install

FROM public.ecr.aws/lambda/ruby:3.2
RUN yum install -y curl
COPY --from=ghcr.io/rails-lambda/tailscale-extension-amzn:1 /opt /opt
COPY --from=builder /var/task /var/task
ENV BUNDLE_SILENCE_ROOT_WARNING=true
ENV BUNDLE_GEMFILE=/var/task/Gemfile
ENV BUNDLE_PATH=/var/task/vendor/bundle
CMD ["app.handler"]
