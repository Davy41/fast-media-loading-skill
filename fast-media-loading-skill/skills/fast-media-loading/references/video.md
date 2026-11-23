# Video

## Decide how to deliver

| Situation | Use |
|---|---|
| Short clip (under ~15 s), decorative or looping | Muted `<video>` with MP4/WebM, no controls |
| Medium/long video, few viewers, simple site | One well-compressed MP4 with `faststart` |
| Long video, many viewers, mixed networks | Adaptive streaming (HLS/DASH) via a hosted service or your own packaging |

Hosted services (Mux, Cloudflare Stream, Cloudinary, YouTube/Vimeo embeds) handle encoding, adaptive bitrate and CDN delivery. For embeds, lazy-load the iframe or use a click-to-load facade so the player's JavaScript doesn't load until needed.

## Markup

```html
<video controls preload="metadata" poster="poster.webp"
       width="1280" height="720" playsinline>
  <source src="clip.webm" type="video/webm">
  <source src="clip.mp4" type="video/mp4">
</video>
```

- `preload="metadata"` fetches only duration/dimensions. Use `none` for videos far down the page.
- Always set a `poster` so something shows immediately.
- Autoplay only works reliably when `muted` and `playsinline` are set. Don't autoplay large files on mobile data.
- Put the most widely supported source last or first consistently; browsers use the first `<source>` they can play, so order by preference (smaller codec first).

## Encoding with ffmpeg

MP4 (H.264) with `faststart` so playback can begin before the full download:

```bash
ffmpeg -i in.mov -c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p \
  -movflags +faststart -c:a aac -b:a 128k out.mp4
```

WebM (VP9):

```bash
ffmpeg -i in.mov -c:v libvpx-vp9 -crf 32 -b:v 0 -c:a libopus out.webm
```

AV1 (smaller, slower to encode, less universal playback):

```bash
ffmpeg -i in.mov -c:v libsvtav1 -crf 35 -c:a libopus out-av1.webm
```

GIF to MP4:

```bash
ffmpeg -i in.gif -movflags +faststart -pix_fmt yuv420p \
  -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" out.mp4
```

Poster frame:

```bash
ffmpeg -i in.mp4 -ss 00:00:01 -frames:v 1 poster.jpg
```

Lower `-crf` means higher quality and larger files. Typical range is 20-28 for H.264.

## Reduce what you encode

- Scale down: most web video doesn't need more than 1080p, and often 720p is enough for in-page players.
- Trim silent or unused sections, and remove the audio track from decorative clips (`-an`).
- Keep the frame rate at 30 fps or lower unless the content needs more.

## Adaptive streaming (HLS)

Adaptive streaming needs several renditions (for example 360p, 720p, 1080p) plus a master playlist. A single-rendition HLS output is only segmented, not adaptive:

```bash
ffmpeg -i in.mp4 -c:v libx264 -c:a aac -hls_time 6 -hls_playlist_type vod \
  -hls_segment_filename "seg_%03d.ts" out.m3u8
```

For real adaptive bitrate, use a packaging tool or a hosted service. Safari plays HLS natively; other browsers need a player library such as hls.js.

## Server requirements

- Support HTTP range requests (`Accept-Ranges: bytes`) so seeking and resuming work.
- Serve with the correct `Content-Type` (`video/mp4`, `video/webm`).
- Serve from a CDN. See [caching-and-cdn.md](caching-and-cdn.md).

## Audio

Use AAC/MP4 or Opus/WebM, `preload="none"` or `metadata`, and never autoplay.
