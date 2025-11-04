# Use CADDY_VERSION to specify a version like "2.8.4" or leave empty for latest
# Examples:
#   docker build --build-arg CADDY_VERSION=2.8.4 .  (uses caddy:2.8.4-builder)
#   docker build .                                    (uses caddy:builder)
ARG CADDY_VERSION=

FROM caddy:${CADDY_VERSION:+${CADDY_VERSION}-}builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/route53

FROM caddy:${CADDY_VERSION:+${CADDY_VERSION}-}alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
