# metalsmith-open-graph

[![Build Status](https://travis-ci.org/astralfrontier/metalsmith-open-graph.svg?branch=master)](https://travis-ci.org/astralfrontier/metalsmith-open-graph)
[![Dependencies](https://david-dm.org/astralfrontier/metalsmith-open-graph.svg)](https://david-dm.org/astralfrontier/metalsmith-open-graph.svg)

This is a [Metalsmith](http://www.metalsmith.io/) plugin
for adding Facebook [OpenGraph](http://ogp.me/) tags to a page.

```
open_graph = require('metalsmith-open-graph');

// ...

metalsmith.use(open_graph({
  ...options...
}))
```

The following options are accepted:

- `sitename`: the human-readable name for your site.
- `sitetype`: the OG type of your site, from [this list](http://ogp.me/#types).
- `siteurl`: the base URL for your site, for resolving relative image URLs.
- `pattern`: a [minimatch](https://github.com/isaacs/minimatch) pattern.
  Only source files matching this pattern will be modified.
- `title`: where to find the og:title tag. See below.
- `description`: where to find the og:description tag. See below.
- `image`: where to find the og:image tag. See below.

Any other options are passed to [Cheerio](https://cheerio.js.org/),
which does the actual HTML parsing behind the scenes.

The `og:url` tag is not currently supported, because it's very hard
for the plugin to detect the final version of the page's URL
when other plugins could be in play (e.g. permalink).
If you know in advance what the URL is going to be,
we can try specifying it in metadata somehow.

## Type

Some Open Graph types may require extra metadata.
At present, it is not possible to specify this.

## Title, Description, Image

The plugin will use the `title`, `description`, and `image` options
to look in your HTML and metadata for the content it needs.

- If the option value is ".X" or "#X", it uses that as a CSS selector by class or ID.
- Otherwise, it's used as a key in the Metalsmith metadata.

For example:

```
metalsmith.use(open_graph({
  siteurl: 'http://mysite.io',
  title: '#og-title',
  description: 'ogDescription',
  image: '.og-image'
}))
```

And your input file is this:

```
---
ogDescription: 'My awesome page description'
---

<html>
  <body>
    <h1 id="og-title">My Page</h1>
    <img class="og-image" url="/images/awesome.jpg" />
  </body>
</html>
```

It will write the following HEAD tags:

- og:title: "My Page"
- og:description: "My awesome page description"
- og:image: "http://mysite.io/images/awesome.jpg"

## Common Problems and Workarounds

### Cyrillic or other symbols are being encoded

You can pass an option called `decodeEntities` with a value of false to disable this.
Reported and solved by [Vitaliy Bobrov](https://github.com/vitaliy-bobrov)
