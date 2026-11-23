# Framework notes

Use the framework's own image handling when it exists. Check the installed version's docs before changing config, since options change between releases.

## Next.js

```tsx
import Image from 'next/image';

// Hero / LCP image
<Image src="/hero.jpg" alt="..." width={1600} height={900} priority sizes="100vw" />

// Below the fold (lazy by default)
<Image src="/card.jpg" alt="..." width={400} height={300} sizes="(min-width: 768px) 33vw, 100vw" />
```

- `priority` only on the LCP image.
- Always provide `sizes` for responsive layouts, otherwise the browser assumes full viewport width.
- Formats are configured in `next.config.js` via `images.formats` (for example `['image/avif', 'image/webp']`). Remote images need `images.remotePatterns`.
- If you deploy somewhere without a built-in optimizer, configure a custom loader or use an external image CDN.

## Nuxt

Use `@nuxt/image`: `<NuxtImg>` and `<NuxtPicture>` with `sizes`, `format="avif,webp"` and `loading="lazy"`. Configure a provider (IPX, Cloudinary, imgix, ...) in `nuxt.config`.

## Astro

Use `<Image />` or `<Picture />` from `astro:assets`. They generate sized, converted files at build time and set `width`/`height` automatically.

## React + Vite (or other SPA)

- No built-in optimizer. Pre-generate variants at build time (a `sharp` script or a Vite image plugin), or use an image CDN.
- Make sure the LCP image is in the initial HTML or preloaded; images added only after JavaScript runs load late.
- Import small assets so Vite fingerprints them. Put large media on a CDN, not in the JS bundle (avoid inlining big files as base64).

## Vue / Svelte / Angular

- Same rules apply: `srcset`/`sizes`, explicit dimensions, lazy loading below the fold.
- Angular has `NgOptimizedImage` (`<img ngSrc="..." width height priority>`).

## WordPress

- WordPress adds `loading="lazy"` and `srcset` for images in the media library by default, so check theme templates that hard-code `<img>` tags.
- Use an image optimization plugin or a CDN that converts to WebP/AVIF and compresses on upload.
- Don't lazy-load the hero image added by the theme or page builder; exclude it in the plugin's settings.
- Upload reasonably sized originals; the media library does not fix a 6000px photo.

## Plain HTML / static sites

- Generate variants in a build step (`sharp`, ImageMagick, or the static site generator's image plugin).
- Write `<picture>`/`srcset` markup by hand or with a template shortcode.
- Host on a platform with a CDN and set cache headers (see [caching-and-cdn.md](caching-and-cdn.md)).

## Third-party embeds

Maps, video players and social embeds are heavy. Use `loading="lazy"` on iframes, or a click-to-load placeholder that only injects the real embed on interaction.
