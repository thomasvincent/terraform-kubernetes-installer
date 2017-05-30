# Pick the latest image
FROM busybox:latest

# Define root directory
ENV ROOT=/kubernetes

# Create app directory
RUN mkdir -p $ROOT
WORKDIR $ROOT

# Copy app dependencies
COPY build $ROOT/

CMD ["/bin/sh"]
