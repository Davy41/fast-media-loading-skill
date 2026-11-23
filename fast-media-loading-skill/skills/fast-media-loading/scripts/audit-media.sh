#!/usr/bin/env bash
# audit-media.sh - quick, read-only audit of media loading problems in a project.
#
# Usage: audit-media.sh [project-root] [max-size-kb]
#   project-root  directory to scan (default: .)
#   max-size-kb   flag media files larger than this (default: 300)
#
# Limits: only static files and single-line tags are checked. Tags that span
# several lines, and media rendered by framework components, are not seen here.

set -u

ROOT="${1:-.}"
MAX_KB="${2:-300}"

if [ ! -d "$ROOT" ]; then
  echo "error: '$ROOT' is not a directory" >&2
  exit 1
fi

PRUNE=( \( -name node_modules -o -name .git -o -name dist -o -name build -o -name .next -o -name .nuxt -o -name .output -o -name vendor -o -name coverage \) -prune -o )
MEDIA_EXT=( \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.avif' -o -iname '*.svg' -o -iname '*.mp4' -o -iname '*.mov' -o -iname '*.webm' -o -iname '*.mp3' -o -iname '*.wav' \) )
SRC_INCLUDES=( --include='*.html' --include='*.htm' --include='*.jsx' --include='*.tsx' --include='*.vue' --include='*.svelte' --include='*.astro' --include='*.php' --include='*.erb' --include='*.twig' --include='*.njk' --include='*.liquid' --include='*.md' --include='*.mdx' )
EXCLUDE_DIRS=( --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=.nuxt --exclude-dir=.output --exclude-dir=vendor )

section() { printf '\n== %s ==\n' "$1"; }

echo "Media audit of: $ROOT (size threshold: ${MAX_KB} KB)"

section "1. Media files larger than ${MAX_KB} KB"
found=0
while IFS= read -r f; do
  kb=$(( ( $(wc -c < "$f") + 1023 ) / 1024 ))
  printf '%8s KB  %s\n' "$kb" "$f"
  found=1
done < <(find "$ROOT" "${PRUNE[@]}" -type f "${MEDIA_EXT[@]}" -size +"${MAX_KB}"k -print 2>/dev/null | sort)
[ "$found" -eq 0 ] && echo "none"

section "2. Legacy formats (consider WebP/AVIF, or MP4/WebM instead of GIF)"
for ext in jpg jpeg png gif; do
  n=$(find "$ROOT" "${PRUNE[@]}" -type f -iname "*.${ext}" -print 2>/dev/null | wc -l | tr -d ' ')
  printf '%-5s %s files\n' ".${ext}" "$n"
done
gifs=$(find "$ROOT" "${PRUNE[@]}" -type f -iname '*.gif' -print 2>/dev/null | head -20)
if [ -n "$gifs" ]; then
  echo "GIF files (replace with muted looping <video>):"
  echo "$gifs" | sed 's/^/  /'
fi

section "3. <img> tags missing width/height (layout shift)"
out=$(grep -rnE "${SRC_INCLUDES[@]}" "${EXCLUDE_DIRS[@]}" '<img[ >]' "$ROOT" 2>/dev/null \
  | grep -vE 'width=' )
[ -n "$out" ] && echo "$out" || echo "none found on single-line tags"

section "4. <img> tags without loading= (lazy-load below-the-fold images; keep hero eager)"
out=$(grep -rnE "${SRC_INCLUDES[@]}" "${EXCLUDE_DIRS[@]}" '<img[ >]' "$ROOT" 2>/dev/null \
  | grep -vE 'loading=' )
[ -n "$out" ] && echo "$out" || echo "none found on single-line tags"

section "5. <img> tags without srcset (responsive sizes)"
out=$(grep -rnE "${SRC_INCLUDES[@]}" "${EXCLUDE_DIRS[@]}" '<img[ >]' "$ROOT" 2>/dev/null \
  | grep -vE 'srcset=|srcSet=' )
[ -n "$out" ] && echo "$out" || echo "none found on single-line tags"

section "6. <video> tags without preload= or poster="
out=$(grep -rnE "${SRC_INCLUDES[@]}" "${EXCLUDE_DIRS[@]}" '<video[ >]' "$ROOT" 2>/dev/null \
  | grep -vE 'preload=.*poster=|poster=.*preload=' )
[ -n "$out" ] && echo "$out" || echo "none found on single-line tags"

section "7. <iframe> embeds without loading=\"lazy\""
out=$(grep -rnE "${SRC_INCLUDES[@]}" "${EXCLUDE_DIRS[@]}" '<iframe[ >]' "$ROOT" 2>/dev/null \
  | grep -vE 'loading=' )
[ -n "$out" ] && echo "$out" || echo "none found on single-line tags"

echo
echo "Done. Review results manually: the hero/LCP image should NOT be lazy-loaded."
exit 0
