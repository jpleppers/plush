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
end
