exports.config =
  # See http://brunch.readthedocs.org/en/latest/config.html for documentation.
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
        'test/javascripts/test.js': /^test(\/|\\)(?!vendor)/
        'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.before.
        before: [
          'vendor/scripts/console-helper.js',
          'vendor/scripts/jquery-1.8.2.js',
          'vendor/scripts/underscore-1.4.0.js',
          'vendor/scripts/backbone-0.9.2.js',
          'vendor/scripts/bootstrap.min.js',
          'vendor/scripts/jquery.jqplot.js',
          'vendor/scripts/jquery.jqplot.cursor.js',
          'vendor/scripts/jquery.jqplot.dateAxisRenderer.js',
          'vendor/scripts/jquery.highcharts.a',
          'vendor/scripts/jquery.highcharts.exporting'
        ]

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        before: ['vendor/styles/normalize-1.0.1.css']
        after: ['vendor/styles/helpers.css']

    templates:
      joinTo: 'javascripts/app.js'
