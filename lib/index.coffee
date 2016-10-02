cheerio = require 'cheerio'
minimatch = require 'minimatch'
url = require 'url'

# The plugin will look for OG data in one of the following places:
# 1. If an option is given as ".X", we look for the first element whose CSS class is "X".
#    For example, title: ".title"
# 2. If an option is given as "#X", we look for the first element whose CSS ID is "X".
#    For example, description: "#og-description-span"
# 3. If an option is just "X", we refer to the key "X" in Metalsmith file metadata.
#    For example:
#    ---
#    desc: This is my description
#    ---
#    description: "desc"
#
# In the special case of og:image, assume that CSS matches refer to an <img> tag,
# and use its "src" attribute.
#
# Options can contain the following keys:
#
# siteurl: the base URL to use when rendering og:image tags from relative URLs
# pattern: a minimatch pattern to compare filenames against
# title: a selector as described above
# description: a selector as described above
# image: a selector as described above
#
# Any other options are passed to Cheerio.
#
# If there is no 'title', we use the meta 'title' tag, or html > head > title
# If there is no 'description', we use the meta 'description' tag if there is one
# No default image is supplied
#

findElementOrValue = (file, $, value, defaultValue) ->
	if !value?
		defaultValue
	else if value.indexOf('.') == 0 || value.indexOf('#') == 0
		element = $(value)
		if element.is('img')
			element.attr('src') || defaultValue
		else
			element.text() || defaultValue
	else
		file[value] || defaultValue

assignOg = ($, tag, value) ->
	# TODO: don't overwrite existing OG tags
	if value?
		tag = $('<meta>').attr('property', "og:#{tag}").attr('content', value)
		$('head').append(tag)

processFile = (options, file) ->
	# TODO: weed out non-Cheerio options
	$ = cheerio.load file.contents, options

	title = $("meta[name='title']").attr('content') || $('title').text()
	description = $("meta[name='description']").attr('content')
	image = undefined

	if options.title?
		title = findElementOrValue(file, $, options.title, title)
	if options.description?
		description = findElementOrValue(file, $, options.description, description)
	if options.image?
		image = findElementOrValue(file, $, options.image, image)
		if image && options.siteurl?
			image = url.resolve(options.siteurl, image)

	# Add OG prefix to the HTML tag
	# TODO: don't overwrite an existing prefix attribute
	$('html').attr('prefix', 'og: http://ogp.me/ns#')

	# Add OG tags
	if options.sitename?
		assignOg($, 'site_name', options.sitename)
	assignOg($, 'type', 'website')
	assignOg($, 'title', title)
	assignOg($, 'description', description)
	assignOg($, 'image', image)

	# Return processed HTML
	$.html()

module.exports = (options) ->
	filenameMatchesPattern = (fn) ->
		if options.pattern
			minimatch(fn, options.pattern)
		else
			true

	(files, metalsmith, done) ->
		for filename, file of files when filenameMatchesPattern(filename)
			file.contents = new Buffer(processFile(options, file))
		done()
