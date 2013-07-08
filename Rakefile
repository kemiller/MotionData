$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionData'
  app.files = %w{
    lib/cdq.rb
    lib/cdq/object.rb
    lib/cdq/context.rb
    lib/cdq/model.rb
    lib/cdq/partial_predicate.rb
    lib/cdq/query.rb
    lib/cdq/store.rb
    lib/cdq/targeted_query.rb
    lib/cdq/managed_object.rb

    app/test_models.rb
    app/app_delegate.rb
  }
  app.frameworks += %w{ CoreData }

  app.vendor_project('vendor/motion_data/ext', :static)
end

require 'motion-stump'

namespace :schema do

  desc "Clear the datamodel outputs"
  task :clean do
    files = Dir.glob(File.join(App.config.project_dir, 'resources', App.config.name) + ".{momd,xcdatamodel}")
    files.each do |f|
      rm_rf f
    end
  end

  desc "Generate the xcdatamodel file"
  task :build => :clean do
    Dir.chdir App.config.project_dir
    system("xcdm", App.config.name, "schemas", "resources")
  end
end
