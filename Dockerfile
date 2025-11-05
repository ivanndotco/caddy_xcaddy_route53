# Use CADDY_VERSION to specify a version like "2.8.4" or leave empty for latest
# Use ROUTE53_VERSION to specify plugin version like "v1.6.0" or leave empty for latest
# Examples:
#   docker build --build-arg CADDY_VERSION=2.8.4 --build-arg ROUTE53_VERSION=v1.6.0 .
#   docker build .  (uses latest versions)
ARG CADDY_VERSION=
ARG ROUTE53_VERSION=

FROM caddy:${CADDY_VERSION:+${CADDY_VERSION}-}builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/route53${ROUTE53_VERSION:+@$ROUTE53_VERSION}

FROM caddy:${CADDY_VERSION:+${CADDY_VERSION}-}alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
