# Caddy with Route53 DNS Plugin

Docker image with Caddy web server and Route53 DNS plugin for automatic HTTPS via DNS-01 ACME challenge.

## Why This Exists

>Hi!
>I’ll probably rewrite this part a few more times, so make sure you’re using the latest version of the repo.
>
>As someone who loves doing things fast, I prefer using ready-to-go containers instead of building them from scratch.
>This time, it’s my turn to help others do things faster — without any builds.
>
>Here you’ll find an automated setup that explains everything clearly, includes usage samples, and works right out of the box.
>
>To be honest, I built it first and only then realized that similar solutions already exist — but I’ll try to make this one better.
>The repo includes all the samples and recommendations you need for a full understanding of how to use it.
>
>And the best part? It’s fully automated.
>So even if I stop using it (or, you know, die 😅), the containers should keep updating — assuming GitHub doesn’t delete my account!
>
> — **IvanN.co**

## Features

- **Latest Caddy**: Automatically updated when new versions are released
- **AWS Route53 Plugin**: For ACME DNS-01 challenges (perfect for wildcard certificates)
- **Multi-platform**: AMD64 and ARM64 support
- **Fully Automated**: CI/CD pipeline checks for Caddy updates weekly
- **Production Ready**: Optimized for security and performance

## Quick Start

### Pull the Image

```bash
docker pull ivannco/caddy_xcaddy_route53:latest
```

### Run with Docker

```bash
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -p 443:443/udp \
  -e AWS_ACCESS_KEY_ID=your_access_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret_key \
  -e AWS_REGION=us-east-1 \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  -v caddy_data:/data \
  ivannco/caddy_xcaddy_route53:latest
```

### Run with Docker Compose

```bash
docker-compose up -d
```

See [examples/](examples/) for ready-to-use configurations.

## Available Tags

- `latest` - Always the most recent build
- `v2.8.4` - Specific Caddy version
- `caddy-v2.8.4` - Alternative version format

## Example Caddyfile

```caddyfile
example.com {
    tls {
        dns route53
    }
    respond "Hello from Caddy with Route53!"
}
```

### Wildcard Certificate

```caddyfile
*.example.com, example.com {
    tls {
        dns route53
    }

    @blog host blog.example.com
    handle @blog {
        reverse_proxy blog:8080
    }

    @app host app.example.com
    handle @app {
        reverse_proxy app:3000
    }
}
```

## AWS Route53 Setup

### 1. Configure DNS

Ensure your domain uses Route53 for DNS:
- Transfer domain to Route53, or
- Update nameservers to Route53

### 2. IAM Permissions

Create IAM user or role with Route53 permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListHostedZonesByName",
        "route53:GetChange"
      ],
      "Resource": "*"
    },
    { "Effect": "Allow",
      "Action": [
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/ZONEID_OF_krusche_cloud"
    }
  ]
}
```

### 3. Credentials

**Option A: Environment Variables**
```bash
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key
AWS_REGION=us-east-1
```

**Option B: IAM Role** (recommended for AWS environments)
- Attach IAM role to EC2/ECS/EKS
- No credentials needed in environment

## Examples

The [examples/](examples/) directory contains ready-to-use configurations:

### Basic Examples
- **[Simple](examples/Caddyfile.simple)** - Single domain with HTTPS
- **[Reverse Proxy](examples/Caddyfile.reverse-proxy)** - Proxy to backend services
- **[Multiple Domains](examples/Caddyfile.multiple-domains)** - Multiple domains and wildcards

### Full Stack Examples
- **[WordPress](examples/docker-compose.wordpress.yml)** - WordPress with MySQL
- **[Monitoring](examples/docker-compose.monitoring.yml)** - Prometheus + Grafana
- **[Full Stack](examples/docker-compose.full-stack.yml)** - Frontend + Backend + Database

### Production Ready
- **[Advanced](examples/Caddyfile.advanced)** - Security headers, caching, load balancing

See the [examples README](examples/README.md) for detailed guides.

## Common Use Cases

### Static Website

```caddyfile
example.com {
    tls {
        dns route53
    }
    root * /var/www/html
    file_server
    encode gzip
}
```

### Reverse Proxy

```caddyfile
api.example.com {
    tls {
        dns route53
    }
    reverse_proxy backend:8080 {
        health_uri /health
        health_interval 10s
    }
}
```

### Load Balancing

```caddyfile
app.example.com {
    tls {
        dns route53
    }
    reverse_proxy backend1:8080 backend2:8080 backend3:8080 {
        lb_policy round_robin
        health_uri /health
    }
}
```

## Docker Compose Configuration

Minimal `docker-compose.yml`:

```yaml
version: '3.8'

services:
  caddy:
    image: ivannco/caddy_xcaddy_route53:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    environment:
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION:-us-east-1}

volumes:
  caddy_data:
  caddy_config:
```

Create `.env` file:
```bash
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-east-1
```

Run:
```bash
docker-compose up -d
```

## Management

### View Logs

```bash
docker-compose logs -f caddy
```

### Reload Configuration

```bash
docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### List Certificates

```bash
docker-compose exec caddy caddy list-certificates
```

### Validate Configuration

```bash
docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile
```

## Troubleshooting

### Certificate Not Being Issued

1. Verify AWS credentials are correct
2. Check IAM permissions for Route53
3. Ensure domain DNS uses Route53
4. Check logs: `docker-compose logs caddy`
5. Use GPTs to analyze the logs from step 4.

### Cannot Connect to Domain

1. Verify DNS records point to your server: `dig example.com`
2. Check firewall allows ports 80, 443 (If the server is private, make sure you can access these resources somehow (like VPN). Ports 80 and 443 do not need to be open to the world, but they should work for you.
3. Wait for DNS propagation (up to 48 hours)

### Backend Connection Error

1. Verify backend service is running
2. Check service names match in docker-compose
3. Test backend directly: `curl http://backend:8080`

## Security Best Practices

- ✅ Use environment variables for credentials
- ✅ Never commit `.env` to version control
- ✅ Use IAM roles when running in AWS
- ✅ Enable security headers (see [advanced example](examples/Caddyfile.advanced))
- ✅ Keep images updated
- ✅ Restrict access to sensitive endpoints
- ✅ Monitor logs for suspicious activity

## Performance Tips

- ✅ Enable compression (`encode gzip`)
- ✅ Cache static assets
- ✅ Use HTTP/3 (enabled by default on port 443/udp)
- ✅ Configure health checks for backends
- ✅ Use connection pooling

## Building Your Own

Want to customize? Fork this repository and modify:

### Add More Plugins

Edit `Dockerfile`:
```dockerfile
RUN xcaddy build \
    --with github.com/caddy-dns/route53 \
    --with github.com/caddy-dns/cloudflare \
    --with your-custom-plugin
```

### Configure CI/CD

The repository includes GitHub Actions workflows that:
- Check for Caddy updates weekly
- Build multi-platform images
- Push to Docker Hub

See [CONFIG.md](CONFIG.md) for setup instructions.

## Resources

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Route53 Plugin](https://github.com/caddy-dns/route53)
- [AWS Route53](https://docs.aws.amazon.com/route53/)
- [Examples](examples/)

## Support

- GitHub Issues: Report bugs and request features
- Caddy Community: [caddy.community](https://caddy.community/)

## License

This project follows Caddy's Apache 2.0 license.

---

**Built with:**
- [Caddy](https://caddyserver.com/) - Modern web server
- [xcaddy](https://github.com/caddyserver/xcaddy) - Caddy build tool
- [caddy-dns/route53](https://github.com/caddy-dns/route53) - Route53 DNS plugin
