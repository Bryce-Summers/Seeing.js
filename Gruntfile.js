module.exports = function (grunt) {
  grunt.initConfig({
    includeSource: {
      options: {
        basePath: './'
      },
      myTarget: {
        files: {
          'index.html': 'index.tpl.html'
        }
      }
    },
    uglify: {
        bar: {
            // uglify task "bar" target options and files go here.
        }
    },

    concat: {
        options: {
            separator: '\n',
            banner: '/*! A project by Bryce Summers.\n *  Single File concatenated by Grunt Concatenate on <%= grunt.template.today("dd-mm-yyyy") %>\n */\n'
        },
        dist: {
            // Include one level down, two levels down, three levels down, then main
            src: ['src/namespace.js', 'lib/*/*.js', 'lib/*/*/*.js', 'lib/*/*/*/*.js'],
            dest: 'builds/a_current_build.js',
        },
    },

  });
 
  // Source Inclusion.
  grunt.loadNpmTasks('grunt-include-source');

  // Minification and Uglification.
  grunt.loadNpmTasks('grunt-contrib-uglify');

  // File concatenation into one file.
  grunt.loadNpmTasks('grunt-contrib-concat');

  grunt.registerTask('default', function (target) {
    //grunt.task.run('includeSource');
    grunt.task.run('concat');
  });
};