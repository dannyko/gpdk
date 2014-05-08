# compress and build tasks require uglify-js for optimization. compile is sufficient for creating working (uncompressed) game code.
# Cakefile template from: http://caseybrant.com/2012/03/20/sample-cakefile.html

FILE_NAME = 'gpdk' # the name given to the output .js file
OUTPUT_DIR   = 'lib' # the directory where the output .js file lives

{exec} = require 'child_process'

task 'compile', 'Compiles coffee in src/ to js in OUTPUT_DIR/', ->
  compile()

compile = (callback) ->
  fileString = 'src/game/modules src/game/objects/abstract src/game/objects/base src/physics/objects src/physics/modules src'
  exec "coffee -b -j #{OUTPUT_DIR}/#{FILE_NAME}.js -c #{fileString}", (err, stdout, stderr) ->
    throw err if err
    console.log "Compiled coffee files"
    callback?()