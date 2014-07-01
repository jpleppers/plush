namespace :plush do
  desc "Compile Handlebars templates"
  task :handlebars do
    for file in Dir.glob('app/templates/*.haml')
      filename = file.split('/').last.gsub('.haml', '')
      original_path = 'app/templates'
      output_path = 'app/assets/javascripts/plush/templates'

      puts "compiling #{filename}"
      system "haml #{original_path}/#{filename}.haml #{original_path}/#{filename}.handlebars"
      system "handlebars #{original_path}/#{filename}.handlebars -f #{output_path}/#{filename}.js"
      system "rm #{original_path}/#{filename}.handlebars"
    end
  end



  namespace :assets do
    compiled_dir = Plush::Engine.config.root.join("compiled")
    dist_dir = Plush::Engine.config.root.join("dist")
    assets_dir = Plush::Engine.config.root.join("app/assets")
    sprockets = Sprockets::Environment.new(Pathname.new(File.dirname(__FILE__))) { |env| env.logger = Logger.new(STDOUT)}

    FileUtils.mkdir_p compiled_dir
    FileUtils.mkdir_p dist_dir

    desc "Compile JS and CSS assets (non-minified and minified versions)"
    task :compile => [:compile_js, :compile_css]

    desc "Compile JS assets (non-minified and minified versions)"
    task :compile_js do
      sprockets.append_path(assets_dir.join('javascripts').to_s)


      asset = sprockets['plush.js.coffee']
      asset.write_to Pathname.new(compiled_dir).join("plush-#{Plush::VERSION}.js")
      asset.write_to Pathname.new(dist_dir).join("plush.js")

      sprockets.js_compressor = Uglifier.new(mangle: true)

      asset = sprockets['plush.js.coffee']
      asset.write_to Pathname.new(compiled_dir).join("plush-#{Plush::VERSION}.min.js")
      asset.write_to Pathname.new(dist_dir).join("plush.min.js")

      puts "successfully compiled js assets"
    end

    desc "Compile CSS assets (non-minified and minified versions)"
    task :compile_css do
      sprockets.append_path(assets_dir.join('stylesheets').to_s)

      asset = sprockets['plush.css.sass']
      asset.write_to Pathname.new(compiled_dir).join("plush-#{Plush::VERSION}.css")
      asset.write_to Pathname.new(dist_dir).join("plush.css")

      sprockets.css_compressor = YUI::CssCompressor.new

      asset = sprockets['plush.css.sass']
      asset.write_to Pathname.new(compiled_dir).join("plush-#{Plush::VERSION}.min.css")
      asset.write_to Pathname.new(dist_dir).join("plush.min.css")

      puts "successfully compiled css assets"
    end

  end
end