# PWA Icons TODO

The PWA configuration requires the following icon files:

- `icon-192.png` - 192x192 pixel icon
- `icon-512.png` - 512x512 pixel icon

These should be generated from the `favicon.svg` or replaced with proper brand assets.

To generate from favicon.svg, you can use a tool like:

- ImageMagick: `convert -density 300 -background none favicon.svg -resize 192x192 icon-192.png`
- Online converters
- Design tools (Figma, Sketch, etc.)

For now, the PWA will work but icons won't display until these are added.
