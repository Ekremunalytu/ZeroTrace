# SSL/TLS Certificates

## Development
For development, you can use self-signed certificates:

```bash
# Generate self-signed certificate for development
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes \
  -subj "/C=TR/ST=Istanbul/L=Istanbul/O=ZeroTrace/OU=Development/CN=localhost"
```

## Production
For production, use certificates from a trusted CA like Let's Encrypt:

```bash
# Using certbot for Let's Encrypt
sudo certbot certonly --nginx -d yourdomain.com -d api.yourdomain.com
```

Place your production certificates here:
- `cert.pem` - Certificate file
- `key.pem` - Private key file
- `fullchain.pem` - Full certificate chain (recommended)

**IMPORTANT**: Never commit actual certificates to git!
