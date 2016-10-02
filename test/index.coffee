assert = require 'assert'
cheerio = require 'cheerio'
Metalsmith = require 'metalsmith'
openGraph = require '../lib'

assertTag = (file, tag, expected) ->
	$ = cheerio.load(file.contents)
	metaTag = $("meta[property='og:#{tag}']").attr('content')
	assert.equal metaTag, expected

describe 'metalsmith-open-graph', ->
	describe 'prefix', ->
		it 'should add a prefix declaration to the HTML tag', (done) ->
			metalsmith = Metalsmith('test/fixtures/general')
			metalsmith
				.use(openGraph({}))
				.build (err, files) ->
					if err
						return done(err)
					$ = cheerio.load files['file.html'].contents
					assert.equal $('html').attr('prefix'), 'og: http://ogp.me/ns#'
					done()

	describe 'site_name', ->
		it 'should add a site_name meta tag when specified', (done) ->
			metalsmith = Metalsmith('test/fixtures/general')
			metalsmith
				.use(openGraph({sitename: 'Terminus'}))
				.build (err, files) ->
					if err
						return done(err)
					$ = cheerio.load files['file.html'].contents
					assertTag files['file.html'], 'site_name', 'Terminus'
					done()

	describe 'type', ->
		it 'should add og:type website to all pages', (done) ->
			metalsmith = Metalsmith('test/fixtures/general')
			metalsmith
				.use(openGraph({}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'type', 'website'
					done()

	describe 'title', ->
		it 'should infer title from the HTML title element', (done) ->
			metalsmith = Metalsmith('test/fixtures/title')
			metalsmith
				.use(openGraph({}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'title', 'Foo'
					done()

		it 'should infer title from the meta title element if present', (done) ->
			metalsmith = Metalsmith('test/fixtures/title')
			metalsmith
				.use(openGraph({}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['fileWithMeta.html'], 'title', 'Slowpoke'
					done()

		it 'should get title from CSS ID if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/title')
			metalsmith
				.use(openGraph({title: '#title-candidate-1'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'title', 'Bar'
					done()

		it 'should get title from CSS class if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/title')
			metalsmith
				.use(openGraph({title: '.title-candidate-2'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'title', 'Baz'
					done()

		it 'should get title from Metalsmith metadata if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/title')
			metalsmith
				.use(openGraph({title: 'myTitle'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'title', 'Blue 42'
					done()

	describe 'description', ->
		it 'should infer description from the meta description element if present', (done) ->
			metalsmith = Metalsmith('test/fixtures/description')
			metalsmith
				.use(openGraph({}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'description', 'Agent Orange'
					done()

		it 'should get description from CSS ID if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/description')
			metalsmith
				.use(openGraph({description: '#description-candidate-1'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'description', 'Norelco'
					done()

		it 'should get description from CSS class if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/description')
			metalsmith
				.use(openGraph({description: '.description-candidate-2'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'description', 'Razor'
					done()

		it 'should get description from Metalsmith metadata if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/description')
			metalsmith
				.use(openGraph({description: 'myDesc'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'description', 'Coming Attractions'
					done()

	describe 'image', ->
		it 'should get image from CSS ID if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/image')
			metalsmith
				.use(openGraph({image: '#image-candidate-1'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'image', '/images/id.jpg'
					done()

		it 'should get image from CSS class if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/image')
			metalsmith
				.use(openGraph({image: '.image-candidate-2'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'image', '/images/class.jpg'
					done()

		it 'should get image from Metalsmith metadata if provided', (done) ->
			metalsmith = Metalsmith('test/fixtures/image')
			metalsmith
				.use(openGraph({image: 'myImage'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'image', '/images/og.jpg'
					done()

		it 'should fully qualify an image URL', (done) ->
			metalsmith = Metalsmith('test/fixtures/image')
			metalsmith
				.use(openGraph({image: 'myImage', siteurl: 'http://example.com/'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['file.html'], 'image', 'http://example.com/images/og.jpg'
					done()

		it 'should write multiple og:image tags', (done) ->
			metalsmith = Metalsmith('test/fixtures/image')
			metalsmith
				.use(openGraph({image: '.image-candidate', siteurl: 'http://example.com/'}))
				.build (err, files) ->
					if err
						return done(err)
					assertTag files['fileMulti.html'], 'image', 'http://example.com/images/foo.jpg,http://example.com/images/bar.jpg'
					done()
