# NewLane Brokers — Legal pages (App Store links)

Static pages for App Store Connect / Play Console.

## URLs after deploy

Replace `BASE` with your public host (HTTPS preferred):

| Page | URL |
|------|-----|
| Index | `BASE/legal/` |
| **Privacy Policy** (required) | `BASE/legal/privacy.html` |
| **Terms** | `BASE/legal/terms.html` |
| **Support** (required) | `BASE/legal/support.html` |
| Security | `BASE/legal/security.html` |
| About | `BASE/legal/about.html` |

Example if hosted on the NewLane VPS under nginx:

- Privacy: `http://159.223.149.54/legal/privacy.html`
- Support: `http://159.223.149.54/legal/support.html`
- Terms: `http://159.223.149.54/legal/terms.html`

**App Store tip:** Apple prefers **HTTPS**. If the IP is HTTP-only, put these on a domain with SSL (e.g. `https://marsblue.co/newlane/legal/...`) or enable Let's Encrypt on the server.

## Deploy on VPS (nginx)

```bash
# from your Mac, after git pull of this repo — or copy the legal folder
sudo mkdir -p /var/www/html/legal
sudo cp -r legal/* /var/www/html/legal/
sudo chown -R www-data:www-data /var/www/html/legal
```

Then open in browser:
`http://YOUR_SERVER_IP/legal/privacy.html`

## App Store Connect fields

App Information / App Privacy / Version:

- **Privacy Policy URL** → `.../legal/privacy.html`
- **Support URL** → `.../legal/support.html`
- **Marketing URL** (optional) → `.../legal/about.html`
- **Terms of Use (EULA)** → `.../legal/terms.html` (or Apple Standard EULA)

Support email: `gabrielr@marsblue.co`
