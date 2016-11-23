var gulp = require('gulp');
var ts = require('gulp-typescript');
var nodemon = require('gulp-nodemon');

gulp.task('typescript', function() {
    console.log('Compiling typescript');
    return gulp.src(['./*.ts'])
        .pipe(ts({module: 'commonjs'})).js.pipe(gulp.dest('./deploy'))
});

gulp.task('watch', function() {
    gulp.watch('./*.ts', ['typescript']);
});

gulp.task('serve', ['typescript'], function () {
    nodemon({
        script: './deploy/app.js',
        ext: 'js',
        env: {
            PORT:3000
        },
        ignore: ['./node_modules/**']
    })
    .on('restart', function() {
        console.log('Restarting');
    });
});

gulp.task('deploy', ['serve'], function() {
    return gulp.src(['package.json'])
        .pipe(gulp.dest('./deploy'));
});

gulp.task('default', ['deploy']);