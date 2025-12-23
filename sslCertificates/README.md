# SSL Certificate for MitchellNet Internal Server

This directory contains the self-signed SSL certificate used by the production server at 192.168.2.10.

## Files

- `mitchellnet-ca.crt` - Certificate Authority certificate (public)
- OpenSSL config used to generate: See instructions in main README.md

## Important Notes

⚠️ **The private key (.key file) is NOT stored in this repository for security reasons.**

The private key remains on the production server at:
- `/etc/ssl/private/selfsigned.key` on 192.168.2.10

## Certificate Details

- **Subject**: CN=MitchellNet Root CA
- **Issuer**: Self-signed
- **Valid for**: 10 years from generation
- **Subject Alternative Names**:
  - DNS: mitchellnet.local
  - DNS: *.mitchellnet.local
  - DNS: localhost
  - IP: 192.168.2.10
  - IP: 127.0.0.1

## Usage

This certificate must be installed and trusted on iOS devices to access the website via Safari without certificate warnings.

See the main README.md for installation instructions.
