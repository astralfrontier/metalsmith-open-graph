assert = require 'assert'
cheerio = require 'cheerio'
Metalsmith = require 'metalsmith'
openGraph = require '../lib'

assertTag = (file, tag, expected) ->
	$ = cheerio.load(file.contents)
	metaTag = $("meta[property='og:#{tag}']").attr('content')
	assert.equal metaTag, expected

buildAndAssert = (done, options, fixtures, callback) ->
        metalsmith = Metalsmith("test/fixtures/#{fixtures}")
        metalsmith
                .use(openGraph(options))
                .build (err, files) ->
                        if err
                                return done(err)
                        callback(files)
                        done()

describe 'metalsmith-open-graph', ->
        describe 'prefix', ->
                it 'should add a prefix declaration to the HTML tag', (done) ->
                        buildAndAssert done, {}, 'general', (files) ->
                                $ = cheerio.load files['file.html'].contents
                                assert.equal $('html').attr('prefix'), 'og: http://ogp.me/ns#'

        describe 'site_name', ->
                it 'should add a site_name meta tag when specified', (done) ->
                        buildAndAssert done, {sitename: 'Terminus'}, 'general', (files) ->
                                $ = cheerio.load files['file.html'].contents
                                assertTag files['file.html'], 'site_name', 'Terminus'

        describe 'type', ->
                it 'should add og:type website to all pages by default', (done) ->
                        buildAndAssert done, {}, 'general', (files) ->
                                assertTag files['file.html'], 'type', 'website'

                it 'should add og:type if a sitetype is specified', (done) ->
                        buildAndAssert done, {sitetype: 'article'}, 'general', (files) ->
                                assertTag files['file.html'], 'type', 'article'

	describe 'title', ->
		it 'should infer title from the HTML title element', (done) ->
			buildAndAssert done, {}, 'title', (files) ->
				assertTag files['file.html'], 'title', 'Foo'

		it 'should infer title from the meta title element if present', (done) ->
			buildAndAssert done, {}, 'title', (files) ->
				assertTag files['fileWithMeta.html'], 'title', 'Slowpoke'

		it 'should get title from CSS ID if provided', (done) ->
			buildAndAssert done, {title: '#title-candidate-1'}, 'title', (files) ->
				assertTag files['file.html'], 'title', 'Bar'

		it 'should get title from CSS class if provided', (done) ->
			buildAndAssert done, {title: '.title-candidate-2'}, 'title', (files) ->
				assertTag files['file.html'], 'title', 'Baz'

		it 'should get title from Metalsmith metadata if provided', (done) ->
			buildAndAssert done, {title: 'myTitle'}, 'title', (files) ->
				assertTag files['file.html'], 'title', 'Blue 42'

	describe 'description', ->
		it 'should infer description from the meta description element if present', (done) ->
			buildAndAssert done, {}, 'description', (files) ->
				assertTag files['file.html'], 'description', 'Agent Orange'

		it 'should get description from CSS ID if provided', (done) ->
			buildAndAssert done, {description: '#description-candidate-1'}, 'description', (files) ->
				assertTag files['file.html'], 'description', 'Norelco'

		it 'should get description from CSS class if provided', (done) ->
			buildAndAssert done, {description: '.description-candidate-2'}, 'description', (files) ->
				assertTag files['file.html'], 'description', 'Razor'

		it 'should get description from Metalsmith metadata if provided', (done) ->
			buildAndAssert done, {description: 'myDesc'}, 'description', (files) ->
				assertTag files['file.html'], 'description', 'Coming Attractions'

	describe 'image', ->
		it 'should get image from CSS ID if provided', (done) ->
			buildAndAssert done, {image: '#image-candidate-1'}, 'image', (files) ->
				assertTag files['file.html'], 'image', '/images/id.jpg'

		it 'should get image from CSS class if provided', (done) ->
			buildAndAssert done, {image: '.image-candidate-2'}, 'image', (files) ->
				assertTag files['file.html'], 'image', '/images/class.jpg'

		it 'should get image from Metalsmith metadata if provided', (done) ->
			buildAndAssert done, {image: 'myImage'}, 'image', (files) ->
				assertTag files['file.html'], 'image', '/images/og.jpg'

		it 'should fully qualify an image URL', (done) ->
			buildAndAssert done, {image: 'myImage', siteurl: 'http://example.com/'}, 'image', (files) ->
				assertTag files['file.html'], 'image', 'http://example.com/images/og.jpg'

		it 'should write multiple og:image tags', (done) ->
			buildAndAssert done, {image: '.image-candidate', siteurl: 'http://example.com/'}, 'image', (files) ->
				assertTag files['fileMulti.html'], 'image', 'http://example.com/images/foo.jpg,http://example.com/images/bar.jpg'
