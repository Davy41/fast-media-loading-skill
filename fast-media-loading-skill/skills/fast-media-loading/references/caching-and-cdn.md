# Caching and CDN

## CDN

- Serve media from a CDN, not directly from the application server. This is usually the biggest single improvement.
- Check that the CDN has edge locations near your real users. If most users are in one region, test from that region.
- Let the CDN or an image service handle resizing and format negotiation (AVIF/WebP via the `Accept` header) when possible.
- Serve media from a cookie-free hostname or path so requests are smaller and cache-friendlier.

## Cache headers

Fingerprinted files (the filename changes when the content changes, e.g. `hero.3f9a1c.avif`):

```
Cache-Control: public, max-age=31536000, immutable
```

Files whose URL does not change (e.g. `/avatars/42.jpg`):

```
Cache-Control: public, max-age=3600, stale-while-revalidate=86400
```

Plus `ETag` or `Last-Modified` so revalidation is cheap. HTML pages should not get the long-lived policy.

If the response varies by format negotiation, send `Vary: Accept`.

### nginx

```nginx
location ~* \.(avif|webp|jpg|jpeg|png|gif|svg|woff2|mp4|webm)$ {
    add_header Cache-Control "public, max-age=31536000, immutable";
    access_log off;
}
```

Only use `immutable` here if the filenames are fingerprinted.

### Apache (`.htaccess`)

```apache
<IfModule mod_headers.c>
  <FilesMatch "\.(avif|webp|jpe?g|png|gif|svg|woff2|mp4|webm)$">
    Header set Cache-Control "public, max-age=31536000, immutable"
  </FilesMatch>
</IfModule>
```

## Protocol

- Enable HTTP/2 or HTTP/3 so many assets load in parallel on one connection. Domain sharding is no longer useful.
- Enable Brotli or gzip for text assets (SVG, JSON, HTML). Do not compress already-compressed media (JPEG, WebP, AVIF, MP4).

## Hints for the browser

- `<link rel="preconnect" href="https://cdn.example.com" crossorigin>` for a media origin that is used right away.
- `<link rel="preload" as="image" ...>` for the LCP image only if it is not discoverable in the initial HTML.
- Don't preload many files; each preload competes with the others.

## Service worker (optional)

Cache frequently reused media (logos, UI images) with a cache-first strategy, and use a size-limited cache for the rest. Don't cache video ranges naively; partial responses need careful handling.

## Verify

- DevTools Network tab: check `Cache-Control`, `Content-Type`, `Content-Length`, protocol (`h2`/`h3`), and whether a second load comes from cache.
- `curl -I https://example.com/path/to/file.avif` to inspect headers.
