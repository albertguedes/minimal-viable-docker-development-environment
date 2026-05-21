#
# generate-ssl.sh - Generate self-signed SSL certificate for development
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
#
# Distributed under the MIT License. See LICENSE for more information.
#

set -e

SSL_DIR="$(dirname "$0")/../ssl"
mkdir -p "$SSL_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout "$SSL_DIR/server.key" \
    -out "$SSL_DIR/server.crt" \
    -subj "/C=BR/ST=SP/L=SaoPaulo/O=MinimalViable/CN=localhost"

chmod 600 "$SSL_DIR/server.key"
chmod 644 "$SSL_DIR/server.crt"

echo "SSL certificates generated in $SSL_DIR"