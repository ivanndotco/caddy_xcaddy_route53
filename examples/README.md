# Caddy with Route53 - Examples

This directory contains ready-to-use examples for deploying Caddy with Route53 DNS plugin in various scenarios.

## Quick Start

1. **Choose an example** that matches your use case
2. **Copy the files** to your project directory
3. **Create `.env` file** from `.env.example` and fill in your AWS credentials
4. **Update the Caddyfile** with your domain name
5. **Run** `docker-compose up -d`

## Available Examples

### 1. Simple Single Domain

**Files:**
- `Caddyfile.simple`
- `docker-compose.yml`

**Use case:** Basic setup for a single domain with Route53 DNS challenge.

**Features:**
- Single domain HTTPS
- Automatic certificate renewal
- Simple response handler

**Quick start:**
```bash
cp Caddyfile.simple Caddyfile
cp .env.example .env
# Edit .env and Caddyfile with your details
docker-compose up -d
```

---

### 2. Reverse Proxy

**Files:**
- `Caddyfile.reverse-proxy`
- `docker-compose.full-stack.yml`

**Use case:** Reverse proxy for web applications and APIs.

**Features:**
- Multiple subdomains
- Backend health checks
- CORS support
- Access logging
- Custom headers

**Quick start:**
```bash
cp Caddyfile.reverse-proxy Caddyfile
cp docker-compose.full-stack.yml docker-compose.yml
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

---

### 3. Multiple Domains

**Files:**
- `Caddyfile.multiple-domains`
- `docker-compose.yml`

**Use case:** Hosting multiple domains and wildcard subdomains.

**Features:**
- Multiple domains
- Wildcard subdomain support
- Subdomain routing
- www to non-www redirect

**Quick start:**
```bash
cp Caddyfile.multiple-domains Caddyfile
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

---

### 4. Advanced Production Setup

**Files:**
- `Caddyfile.advanced`
- `docker-compose.full-stack.yml`

**Use case:** Production-ready configuration with security and performance.

**Features:**
- Security headers (HSTS, CSP, etc.)
- Compression (gzip, zstd)
- Static file caching
- WebSocket support
- Load balancing
- Custom error pages
- Structured logging

**Quick start:**
```bash
cp Caddyfile.advanced Caddyfile
cp docker-compose.full-stack.yml docker-compose.yml
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

---

### 5. WordPress

**Files:**
- `Caddyfile.wordpress`
- `docker-compose.wordpress.yml`

**Use case:** WordPress site with automatic HTTPS.

**Features:**
- WordPress + MySQL
- Automatic HTTPS via Route53
- www redirect
- Security headers
- Persistent data volumes

**Quick start:**
```bash
cp Caddyfile.wordpress Caddyfile
cp docker-compose.wordpress.yml docker-compose.yml
cp .env.example .env
# Edit .env with your details
docker-compose up -d
```

Access: `https://your-domain.com/wp-admin`

---

### 6. Monitoring Stack

**Files:**
- `Caddyfile.monitoring`
- `docker-compose.monitoring.yml`
- `prometheus.yml`

**Use case:** Prometheus + Grafana monitoring with Caddy.

**Features:**
- Grafana dashboard
- Prometheus metrics
- Node exporter
- Caddy exporter
- Basic authentication
- Subdomain routing

**Quick start:**
```bash
cp Caddyfile.monitoring Caddyfile
cp docker-compose.monitoring.yml docker-compose.yml
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

Access:
- Grafana: `https://grafana.your-domain.com`
- Prometheus: `https://prometheus.your-domain.com`

---

## Configuration Guide

### AWS Route53 Setup

1. **Ensure your domain is using Route53 for DNS**
   - Transfer domain to Route53, or
   - Update nameservers to Route53

2. **Create IAM user or role with Route53 permissions**

Required IAM policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:GetChange"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    }
  ]
}
```

3. **Get credentials**
   - IAM → Users → Security Credentials → Create Access Key
   - Save Access Key ID and Secret Access Key

### Environment Variables

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Edit `.env` with your values:
```bash
# AWS Credentials
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key
AWS_REGION=us-east-1

# Your domain
DOMAIN=example.com
```

### Domain Configuration

In your Caddyfile, replace `example.com` with your actual domain:
```caddyfile
your-domain.com {
    tls {
        dns route53
    }
    respond "Hello World!"
}
```

## Common Tasks

### View Logs

```bash
# All logs
docker-compose logs -f

# Just Caddy
docker-compose logs -f caddy

# Last 100 lines
docker-compose logs --tail=100 caddy
```

### Reload Configuration

After editing Caddyfile:
```bash
docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

Or restart:
```bash
docker-compose restart caddy
```

### Check Certificate Status

```bash
docker-compose exec caddy caddy list-certificates
```

### Test Configuration

Before applying:
```bash
docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile
```

### Backup Certificates

```bash
docker run --rm -v caddy_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/caddy-data-backup.tar.gz /data
```

### Restore Certificates

```bash
docker run --rm -v caddy_data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/caddy-data-backup.tar.gz -C /
```

## Troubleshooting

### Certificate Provisioning Fails

**Problem:** Certificate not being issued

**Solutions:**
1. Check AWS credentials are correct
2. Verify IAM permissions for Route53
3. Ensure domain DNS is using Route53
4. Check Caddy logs: `docker-compose logs caddy`
5. Verify domain ownership in Route53 console

### Connection Timeout

**Problem:** Cannot connect to domain

**Solutions:**
1. Check ports 80 and 443 are open in firewall
2. Verify DNS records point to your server
3. Wait for DNS propagation (up to 48 hours)
4. Test with: `dig your-domain.com`

### Backend Connection Refused

**Problem:** Caddy can't reach backend service

**Solutions:**
1. Ensure backend is running: `docker-compose ps`
2. Check service names match in docker-compose and Caddyfile
3. Verify backend is listening on correct port
4. Check backend health: `docker-compose logs backend`

### Permission Denied

**Problem:** Caddy can't write to volumes

**Solutions:**
1. Check volume permissions
2. Try with sudo: `sudo docker-compose up`
3. Fix volume ownership:
   ```bash
   sudo chown -R 1000:1000 ./caddy_data
   ```

## Best Practices

### Security

- ✅ Always use HTTPS in production
- ✅ Enable HSTS headers
- ✅ Use strong passwords for databases
- ✅ Restrict access to admin panels
- ✅ Keep credentials in `.env`, never commit to git
- ✅ Use IAM roles instead of credentials when in AWS
- ✅ Enable logging for audit trails

### Performance

- ✅ Enable compression (gzip, zstd)
- ✅ Cache static assets
- ✅ Use HTTP/3 (enabled by default)
- ✅ Configure connection pooling
- ✅ Set up health checks

### Maintenance

- ✅ Monitor logs regularly
- ✅ Backup certificate data
- ✅ Test configuration changes before applying
- ✅ Keep Docker images updated
- ✅ Document custom configurations

## Advanced Usage

### Custom Plugins

To add more Caddy plugins, fork the repository and modify the `Dockerfile`:

```dockerfile
RUN xcaddy build \
    --with github.com/caddy-dns/route53 \
    --with github.com/caddy-dns/cloudflare \
    --with your-custom-plugin
```

### Multiple Environments

Create separate docker-compose files:
- `docker-compose.prod.yml`
- `docker-compose.staging.yml`

Run specific environment:
```bash
docker-compose -f docker-compose.staging.yml up -d
```

### External Configuration

Mount configuration from external source:
```yaml
volumes:
  - /etc/caddy/Caddyfile:/etc/caddy/Caddyfile:ro
  - /var/caddy/data:/data
```

## Resources

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Route53 Plugin Docs](https://github.com/caddy-dns/route53)
- [AWS Route53 Guide](https://docs.aws.amazon.com/route53/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Let's Encrypt](https://letsencrypt.org/)

## Support

- GitHub Issues: [Report a bug](https://github.com/your-username/caddy-xcaddy-route53/issues)
- Caddy Community: [forum.caddyserver.com](https://caddy.community/)
- AWS Support: [AWS Console](https://console.aws.amazon.com/support/)

## License

These examples are provided as-is for use with the Caddy Route53 Docker image.
