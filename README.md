# fast-media-loading

A [Claude Code](https://docs.claude.com/en/docs/claude-code) skill that helps Claude audit and speed up media loading in web applications: images, video, embeds, caching and CDN setup.

When you ask about slow pages, large images or videos, lazy loading, Core Web Vitals (LCP, CLS) or media caching, Claude loads this skill, scans your project, reports problems by impact, and fixes what you ask it to.

## What it covers

- Modern formats (AVIF, WebP, SVG) and replacing GIFs with video
- Responsive images (`srcset`, `sizes`, `<picture>`) and explicit dimensions
- Lazy loading, `fetchpriority` and preloading the hero/LCP image
- Video delivery: `preload`, posters, `faststart`, HLS/DASH, ffmpeg commands
- CDN, `Cache-Control`, HTTP/2/3, range requests
- Framework notes: Next.js, Nuxt, Astro, Vite/React, WordPress, plain HTML
- A read-only audit script that flags oversized files and tags missing `width`, `loading`, `srcset` or `preload`

## Install

### Option 1: Claude Code plugin marketplace

```
/plugin marketplace add davy41/fast-media-loading-skill
/plugin install fast-media-loading@fast-media-loading-skill
```

### Option 2: Copy the skill folder

For all your projects:

```bash
git clone https://github.com/davy41/fast-media-loading-skill.git
mkdir -p ~/.claude/skills
cp -r fast-media-loading-skill/skills/fast-media-loading ~/.claude/skills/
```

For one project only:

```bash
mkdir -p .claude/skills
cp -r fast-media-loading-skill/skills/fast-media-loading .claude/skills/
```

Restart Claude Code after installing.

## Usage

The skill triggers automatically on relevant requests. Examples:

- "My landing page is slow. Audit the media and fix the biggest problems."
- "Convert the images in `public/` to WebP and update the markup with `srcset`."
- "Why is my LCP so high? It's the hero image."
- "Set up cache headers for static media in nginx."

You can also run the audit script yourself:

```bash
bash skills/fast-media-loading/scripts/audit-media.sh . 300
```

Arguments: project root (default `.`) and the size threshold in KB (default `300`). The script is read-only.

## Repository layout

```
.
├── .claude-plugin/
│   ├── plugin.json            # plugin manifest
│   └── marketplace.json       # lets you install this repo as a marketplace
├── skills/
│   └── fast-media-loading/
│       ├── SKILL.md           # entry point Claude reads
│       ├── references/        # detailed guides, loaded only when needed
│       │   ├── images.md
│       │   ├── video.md
│       │   ├── caching-and-cdn.md
│       │   └── frameworks.md
│       └── scripts/
│           └── audit-media.sh
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Limitations

- The audit script only sees static files and single-line HTML tags. It does not see media rendered by framework components or tags spread over several lines, so Claude also reads the code.
- Recommendations are general. Quality settings and codec choices should be checked visually on your own media.
- Framework options change between versions; check the docs for the version you use.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
