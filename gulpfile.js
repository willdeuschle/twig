'use-strict';

var gulp = require('gulp');
var exec = require('child_process').exec;
var gutil = require('gulp-util');


var cmd = 'elm-make src/App.elm --output dist/elm-water.js';

gulp.task('default', ['elm']);

gulp.task('elm', function() {
  exec(cmd, function(err, stdout, stderr) {
      if (err) {
        gutil.log(gutil.colors.red('elm make: '), gutil.colors.red(stderr));
      } else {
        gutil.log(gutil.colors.green('elm make: '), gutil.colors.green(stdout));
      }
    });
  }
);
