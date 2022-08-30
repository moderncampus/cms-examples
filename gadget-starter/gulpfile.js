var gulp = require('gulp');

var jshint = require('gulp-jshint');
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
var rename = require('gulp-rename');

//lint
gulp.task('lint', function() {
  return gulp.src('lib/gadgetlib.js')
  		.pipe(jshint())
  		.pipe(jshint.reporter('default'));
});

//Minify / Uglify
gulp.task('minify', function() {
	return gulp.src('lib/gadgetlib.js')
		.pipe(concat('gadgetlib.min.js'))
		.pipe(gulp.dest('lib'))
		.pipe(uglify())
		.pipe(gulp.dest('lib'));
});

gulp.task('default', ['lint', 'minify']);