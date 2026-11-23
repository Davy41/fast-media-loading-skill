---
name: fast-media-loading
description: Audit and optimize image, video and other media loading in a web application. Use when the user asks about slow pages, large images or videos, Core Web Vitals (LCP, CLS), lazy loading, responsive images, CDN or caching setup for media, or when building or reviewing components that render images, video or audio.
---

# Fast Media Loading

Goal: make media load fast by sending fewer bytes, serving them from closer to the user, and loading them at the right moment.

## Workflow

1. **Detect the stack** (Next.js, Nuxt, Astro, React/Vite, WordPress, plain HTML, ...) from `package.json`, config files and templates. Prefer the framework's built-in image tooling over hand-rolled markup. See [references/frameworks.md](references/frameworks.md).
2. **Audit first.** Run the bundled script from the project root:
   ```bash
   bash <path-to-skill>/scripts/audit-media.sh . 300
   ```
   It lists oversized media files, legacy formats, and `<img>` / `<video>` tags missing `width`, `height`, `loading` or `preload`. Its output is a starting point, not a verdict: it only sees single-line tags and static files. Also read the components that render media.
3. **Report findings by impact**, highest first, each with file path, the problem and the expected gain.
4. **Fix what the user asked for.** Don't refactor unrelated code and don't add dependencies without asking.
5. **Verify.** Build or run the project if possible, and tell the user how to re-measure (Lighthouse, PageSpeed Insights, DevTools throttled to Slow 4G).

## Checklist

### 1. Shrink the files
- Photos: **AVIF or WebP**, with a JPEG fallback in `<picture>` only if needed. Icons and logos: **SVG**.
- Replace animated **GIFs** with muted, looping `<video>`.
- Video: H.264 MP4 as baseline, optionally WebM/AV1 as extra `<source>`. Long videos use **adaptive streaming (HLS/DASH)** or a hosted service, not one large MP4.
- Details and commands: [references/images.md](references/images.md), [references/video.md](references/video.md).

### 2. Serve the right size
- Use `srcset` and `sizes` so phones don't download desktop-size images.
- Prefer an image CDN/optimizer that resizes and converts on request.
- Always set `width` and `height` (or CSS `aspect-ratio`) to prevent layout shift (CLS).

### 3. Load at the right time
- `loading="lazy"` and `decoding="async"` on below-the-fold images and iframes.
- **Never lazy-load the LCP/hero image.** Give it `fetchpriority="high"`.
- Video: `preload="metadata"` (or `none`), a `poster`, and no autoplay of large files. Autoplay only when muted and `playsinline`.
- Use a low-quality placeholder (blur, BlurHash or dominant colour).

### 4. Deliver from closer to the user
- Put media behind a **CDN** with edge locations near the actual users.
- HTTP/2 or HTTP/3, long cache headers on fingerprinted files, range requests for video.
- Details: [references/caching-and-cdn.md](references/caching-and-cdn.md).

### 5. Measure
- Track **LCP, CLS and total page weight** with Lighthouse and DevTools, and with real-user monitoring (`web-vitals`) if available.

## Priority order when time is short

1. CDN in front of media.
2. WebP/AVIF plus responsive sizes.
3. Lazy-load everything except the hero image.
4. Adaptive streaming for long video.
5. Long-lived cache headers.

## Output format

- **Findings**: short list, each with file path, problem, and expected gain (high/medium/low).
- **Changes made** (or proposed), with code.
- **How to verify**: exact commands or tools to re-measure.

Keep it concise.
