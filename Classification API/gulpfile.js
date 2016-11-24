var gulp = require('gulp');
var ts = require('gulp-typescript');
var nodemon = require('gulp-nodemon');

gulp.task("compile", function() {
    // Creates new typescript project
    var project = ts.createProject({
        "target": "ES5",
        "module": "commonjs",
        "moduleResolution": "node",
        "sourceMap": true,
        "emitDecoratorMetadata": true,
        "experimentalDecorators": true,
        "removeComments": true,
        "noImplicitAny": false
    });

    // Calls for compilation of .ts files
    return gulp.src("./*.ts")
        .pipe(project())
        .pipe(gulp.dest("./deploy/"))
});

gulp.task("default", ["compile"], function() {
    // Adds package.json to deploy directory
    gulp.src(['package.json'])
        .pipe(gulp.dest('./deploy'));

    // Starts nodemon
    return nodemon({
        script: "./deploy/app.js",
        ext: 'ts',
        tasks: ["compile"],
        env: { PORT:3000  }
    });
});