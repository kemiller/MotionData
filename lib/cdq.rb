Motion::Project::App.setup do |app|

  app.files.unshift(File.join(File.dirname(__FILE__), "../motion/cdq.rb"))

  %w{
    object.rb
    context.rb
    store.rb
    model.rb
    partial_predicate.rb
    query.rb
    targeted_query.rb
    managed_object.rb
  }.map { |f| File.join(File.dirname(__FILE__), "../motion/cdq/#{f}") }.each { |f| app.files.unshift(f) }

  app.frameworks += %w{ CoreData }
  app.vendor_project(File.expand_path(File.join(File.dirname(__FILE__), "../vendor/motion_data/ext")), :static)
end
