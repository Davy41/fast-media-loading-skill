# Images

## Format choice

| Content | Use |
|---|---|
| Photos | AVIF (smallest), WebP (widely supported), JPEG fallback |
| Logos, icons, simple illustrations | SVG (minify with SVGO) |
| Screenshots, UI with flat colour | WebP lossless or PNG |
| Animation | Muted looping `<video>`, not GIF |

## Responsive markup

```html
<picture>
  <source type="image/avif"
          srcset="hero-480.avif 480w, hero-960.avif 960w, hero-1600.avif 1600w"
          sizes="100vw">
  <source type="image/webp"
          srcset="hero-480.webp 480w, hero-960.webp 960w, hero-1600.webp 1600w"
          sizes="100vw">
  <img src="hero-960.jpg" width="1600" height="900" alt="Describe the image"
       fetchpriority="high" decoding="async">
</picture>
```

- `sizes` must describe the rendered width, for example `(min-width: 1024px) 33vw, 100vw`. A wrong `sizes` makes the browser pick the wrong file.
- Always give `width` and `height` matching the intrinsic aspect ratio. CSS can still scale the image.
- Hero/LCP image: no `loading="lazy"`, add `fetchpriority="high"`. If it is a CSS background, preload it:
  `<link rel="preload" as="image" href="hero-960.avif" imagesrcset="..." imagesizes="100vw">`
- Everything else below the fold: `loading="lazy" decoding="async"`.

## Generating variants

Node with `sharp`:

```js
import sharp from 'sharp';

for (const width of [480, 960, 1600]) {
  const img = sharp('hero.jpg').resize({ width, withoutEnlargement: true });
  await img.clone().avif({ quality: 50 }).toFile(`hero-${width}.avif`);
  await img.clone().webp({ quality: 78 }).toFile(`hero-${width}.webp`);
  await img.clone().jpeg({ quality: 80, mozjpeg: true }).toFile(`hero-${width}.jpg`);
}
```

ImageMagick:

```bash
magick in.jpg -resize 1600x -quality 80 out.webp
```

## Quality starting points

- AVIF quality 45-60, WebP 75-82, JPEG 75-82. Check visually on the real image; photos with fine texture need higher values.
- Strip metadata (EXIF) unless it is needed.
- Don't upscale. Keep originals outside the served directory.

## Placeholders

- A tiny blurred preview (a base64 data URI of about 20px width) or a dominant-colour background avoids empty boxes.
- Reserve space with `width`/`height` or `aspect-ratio`; the placeholder doesn't fix layout shift on its own.

## User-uploaded images

- Resize and convert on upload (or on first request) and store the variants.
- Enforce a maximum dimension and file size at upload time.
- Never serve the raw original to the page.
