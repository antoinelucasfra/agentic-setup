# Secure Coding & OWASP — Quick Reference

Security-first default. When in doubt, choose the more secure option.

## Checklist

- **Access control**: deny by default, least privilege, validate URLs for SSRF, prevent path traversal.
- **Crypto**: Argon2/bcrypt for passwords, HTTPS in transit, AES-256 at rest. No hardcoded secrets — env vars only.
- **Injection**: parameterized queries (no raw SQL), sanitize shell input, context-aware output encoding (`.textContent` over `.innerHTML`).
- **Config**: disable debug in production, set security headers (CSP, HSTS, X-Content-Type-Options), keep deps updated.
- **Auth**: rotate session IDs on login, HttpOnly+Secure+SameSite cookies, rate-limit login.
- **Deserialization**: prefer JSON over Pickle, validate untrusted input.

## Principle

Explain the risk when you flag a pattern — not just the fix.
