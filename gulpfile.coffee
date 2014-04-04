gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
coffeelint = require 'gulp-coffeelint'
uglify = require 'gulp-uglify'
watch = require 'gulp-watch'
nodemon = require 'gulp-nodemon'
sass = require 'gulp-ruby-sass'
size = require 'gulp-size'
todo = require 'gulp-todo'
cache = require 'gulp-cached'
plato = require 'gulp-plato'
plumber = require 'gulp-plumber'
livereload = require 'gulp-livereload'
rev = require 'gulp-rev'
minifyCSS = require 'gulp-minify-css'
bytediff = require 'gulp-bytediff'
mocha = require 'gulp-mocha'


path =
	docs:
		front:
			js: "docs/js"
			css: "docs/css"
			coffee: "docs/coffee"
			vendor:
				bower: "docs/js/bower"
				libs: "docs/js/libs"
		server:
			app: "docs/server/app.coffee"


	kit:
		coffee: "coffee"
		sass: "sass"
		vendor:
			bower: "js/bower"
			libs: "js/libs"

	dev: "development"

	build:
		js: "build/js"
		css: "build/css"







# ====================== DEVELOPER TASKS

# Concatenate all vendors into one file
# This vendor js is only for maxmertkit.js, no docs vendors here
gulp.task 'kitVendor', ->

	files = [
		"#{path.kit.vendor.bower}/jquery/jquery.js"
		# "#{path.kit.vendor.bower}/jquery.event.swipe/jquery.event.swipe.js"
		"#{path.kit.vendor.bower}/threejs/build/three.js"
		"#{path.kit.vendor.bower}/sparksjs/Sparks.js"
		"#{path.kit.vendor.bower}/tweenjs/Tween.js"
		
		"#{path.kit.vendor.libs}/threejs.mtlLoader.js"
	]

	gulp.src( files )
		.pipe( cache('kitVendor') )
		.pipe( concat 'vendor.js' )
		.pipe( size( showFiles: yes ) )
		.pipe( gulp.dest "#{path.docs.front.js}" )
		.pipe( livereload() )



# Compile all kit coffee files
# No uglyfying
gulp.task 'kitCoffee', ->

	files = [
		"#{path.kit.coffee}/maxmertkit.coffee"
		"#{path.kit.coffee}/**/*.coffee"
	]

	gulp.src( files )
		.pipe( plumber() )
		.pipe( cache('kitCoffee') )
		.pipe( coffeelint() )
		.pipe( coffee( map: yes ).on( 'error', gutil.log ) )
		.pipe( concat 'maxmertkit.js' )
		.pipe( size( showFiles: yes ) )
		.pipe( gulp.dest "#{path.docs.front.js}" )
		.pipe( livereload() )


# Compile all kit sass
# No minification
gulp.task 'kitSass', ->

	files = [
		"#{path.kit.sass}/main.sass"
	]

	gulp.src( files )
		.pipe( plumber() )
		.pipe( cache('kitSass') )
		.pipe( sass( sourcemap: yes ) )
		.pipe( size( showFiles: yes ) )
		.pipe( gulp.dest "#{path.docs.front.css}" )
		.pipe( livereload() )



# Create todo.md to maintain all todos in js files
# In coffee use multiline comments
gulp.task 'kitTodo', ->

	files = "#{path.docs.front.js}/maxmertkit.js"
	dest = "#{path.docs.front.js}"

	gulp.src( files )
		.pipe( cache('kitTodo') )
		.pipe( todo() )
		.pipe( gulp.dest './' )












# ====================== DOCUMENTATION TASKS

gulp.task 'docsVendor', ->

	files = [
		"#{path.docs.front.vendor.bower}/angular/angular.js"
		"#{path.docs.front.vendor.bower}/angular-route/angular-route.js"
		"#{path.docs.front.vendor.bower}/highlightjs/highlight.pack.js"
		"#{path.docs.front.vendor.bower}/angular-highlightjs/angular-highlightjs.js"
		
		"#{path.docs.front.vendor.libs}/scrollTo.angular.js"
		
	]

	gulp.src( files )
		.pipe( cache('docsVendor') )
		.pipe( concat 'docsvendor.js' )
		.pipe( size( showFiles: yes ) )
		.pipe( gulp.dest "#{path.docs.front.js}" )
		.pipe( livereload() )



gulp.task 'docsApp', ->

	files = [
		"#{path.docs.front.coffee}/app.coffee"
	]

	gulp.src( files )
		.pipe( cache('docsApp') )
		.pipe( coffeelint() )
		.pipe( coffee( map: yes ).on( 'error', gutil.log ) )
		.pipe( size( showFiles: yes ) )
		.pipe( gulp.dest "#{path.docs.front.js}" )
		.pipe( livereload() )


# Compile all kit sass
# No minification
gulp.task 'docsSass', ->

	files = [
		"#{path.kit.sass}/developer.sass"
	]

	gulp.src( files )
		.pipe( plumber() )
		.pipe( cache('docsSass') )
		.pipe( sass( sourcemap: yes ) )
		.pipe( size( showFiles: yes ) )
		.pipe( gulp.dest "#{path.docs.front.css}" )
		.pipe( livereload() )



# Starts node server
gulp.task 'nodemon', ->
	nodemon( 
		script: path.docs.server.app
		ext: 'server/**/*.coffee server/**/*.html'
	)
		# .on('restart', 'default')









# ================ TESTS TASKS

gulp.task 'test', ->
	gulp.src( "test/kit.coffee" )
		.pipe( mocha() )










# ================ GLOBAL TASKS

gulp.task 'watch', ->
	gulp.watch "#{path.kit.coffee}/**/*.coffee", [ 'kitCoffee' ]
	gulp.watch "#{path.docs.front.js}/maxmertkit.js", [ 'kitTodo' ]
	gulp.watch [ "#{path.kit.vendor.bower}/**/*.js", "#{path.kit.vendor.libs}/**/*.js" ], [ 'kitVendor' ]
	gulp.watch "#{path.kit.sass}/**/*.sass", [ 'kitSass' ]
	
	gulp.watch [ "#{path.docs.front.vendor.bower}/**/*.js", "#{path.docs.front.vendor.libs}/**/*.js" ], [ 'kitVendor' ]
	gulp.watch "#{path.kit.sass}/developer.sass", [ 'docsSass' ]


gulp.task( 'default', [ 'kitVendor', 'kitCoffee', 'kitSass', 		'docsVendor', 'docsApp', 'docsSass' ], ->
	gulp.tasks.nodemon.fn()
	gulp.tasks.watch.fn()
	gulp.tasks.kitTodo.fn()
)









# ====================== BUILD TASKS

gulp.task 'build', [ 'kitCoffee', 'kitSass' ], ->

	
	gulp.src( "#{path.docs.front.js}/maxmertkit.js" )
		.pipe( bytediff.start() )
		.pipe( uglify() )
		.pipe( bytediff.stop() )
		.pipe( gulp.dest "#{path.build.js}" )
		
		.pipe( rev() )
		.pipe( gulp.dest "#{path.build.js}" )

	
	gulp.src( "#{path.docs.front.css}/main.css" )
		.pipe( bytediff.start() )
		.pipe( minifyCSS() )
		.pipe( bytediff.stop() )
		.pipe( gulp.dest "#{path.build.css}" )
		
		.pipe( rev() )
		.pipe( gulp.dest "#{path.build.css}" )



	gulp.src( "#{path.docs.front.js}/maxmertkit.js" )
		.pipe( plato "#{path.dev}/report" )


