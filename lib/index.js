// Generated by CoffeeScript 1.11.1
(function() {
  var assignOg, cheerio, findElementOrValue, minimatch, processFile, url;

  cheerio = require('cheerio');

  minimatch = require('minimatch');

  url = require('url');

  findElementOrValue = function(file, $, value, defaultValue) {
    var values;
    if (value == null) {
      return [defaultValue];
    } else if (value.indexOf('.') === 0 || value.indexOf('#') === 0) {
      values = [];
      $(value).each(function(i, elem) {
        var element;
        element = $(this);
        if (element.is('img')) {
          return values.push(element.attr('src') || defaultValue);
        } else {
          return values.push(element.text() || defaultValue);
        }
      });
      return values;
    } else {
      values = file[value] || defaultValue;
      if (!Array.isArray(values)) {
        values = [values];
      }
      return values;
    }
  };

  assignOg = function($, tag, values) {
    var j, len, results, value;
    if ((values != null) && values.length > 0) {
      results = [];
      for (j = 0, len = values.length; j < len; j++) {
        value = values[j];
        tag = $('<meta>').attr('property', "og:" + tag).attr('content', value);
        results.push($('head').append(tag));
      }
      return results;
    }
  };

  processFile = function(options, file) {
    var $, description, image, img, sitetype, title;
    $ = cheerio.load(file.contents, options);
    sitetype = 'website';
    title = $("meta[name='title']").attr('content') || $('title').text();
    description = $("meta[name='description']").attr('content');
    image = void 0;
    if (options.sitetype != null) {
      sitetype = options.sitetype;
    }
    if (options.title != null) {
      title = findElementOrValue(file, $, options.title, title);
    }
    if (options.description != null) {
      description = findElementOrValue(file, $, options.description, description);
    }
    if (options.image != null) {
      image = findElementOrValue(file, $, options.image, image);
      if (image && image.length > 0 && (options.siteurl != null)) {
        image = (function() {
          var j, len, results;
          results = [];
          for (j = 0, len = image.length; j < len; j++) {
            img = image[j];
            if (img != null) {
              results.push(url.resolve(options.siteurl, img));
            }
          }
          return results;
        })();
      }
    }
    $('html').attr('prefix', 'og: http://ogp.me/ns#');
    if (options.sitename != null) {
      assignOg($, 'site_name', [options.sitename]);
    }
    assignOg($, 'type', [sitetype]);
    assignOg($, 'title', [title]);
    assignOg($, 'description', [description]);
    assignOg($, 'image', [image]);
    return $.html();
  };

  module.exports = function(options) {
    var filenameMatchesPattern;
    filenameMatchesPattern = function(fn) {
      if (options.pattern) {
        return minimatch(fn, options.pattern);
      } else {
        return true;
      }
    };
    return function(files, metalsmith, done) {
      var file, filename;
      for (filename in files) {
        file = files[filename];
        if (filenameMatchesPattern(filename)) {
          file.contents = new Buffer(processFile(options, file));
        }
      }
      return done();
    };
  };

}).call(this);
