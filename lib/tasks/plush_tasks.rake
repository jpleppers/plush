desc "Compile Handlebars templates"
namespace :plush do
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
    output_dir = Plush::Engine.config.root.join("compiled")
    assets_dir = Plush::Engine.config.root.join("app/assets")
    sprockets = Sprockets::Environment.new(Pathname.new(File.dirname(__FILE__))) { |env| env.logger = Logger.new(STDOUT)}

    FileUtils.mkdir_p output_dir
   
    task :compile => [:compile_js, :compile_css]

    task :compile_js do
      sprockets.append_path(assets_dir.join('javascripts').to_s)

      
      asset = sprockets['plush.js.coffee']
      asset.write_to Pathname.new(output_dir).join("plush-#{Plush::VERSION}.js")
      
      sprockets.js_compressor = Uglifier.new(mangle: true)

      asset = sprockets['plush.js.coffee']
      asset.write_to Pathname.new(output_dir).join("plush-#{Plush::VERSION}.min.js")

      puts "successfully compiled js assets"
    end

    task :compile_css do
      sprockets.append_path(assets_dir.join('stylesheets').to_s)

      asset = sprockets['plush.css.sass']
      asset.write_to Pathname.new(output_dir).join("plush-#{Plush::VERSION}.css")

      sprockets.css_compressor = YUI::CssCompressor.new

      asset = sprockets['plush.css.sass']
      asset.write_to Pathname.new(output_dir).join("plush-#{Plush::VERSION}.min.css")

      puts "successfully compiled css assets"
    end

  end
end