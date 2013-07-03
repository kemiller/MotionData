Motion::Project::App.setup do |app|
  %w{
    scope.rb
    managed_object.rb
    predicate.rb
    context.rb
    store_coordinator.rb
    setup.rb
  }.map { |f| File.join(File.dirname(__FILE__), "motion_data/#{f}") }.each { |f| app.files.unshift(f) }

  %w{
    scope.rb
    partial_predicate.rb
  }.map { |f| File.join(File.dirname(__FILE__), "cdq/#{f}") }.each { |f| app.files.unshift(f) }

  app.frameworks += %w{ CoreData }
  app.vendor_project(File.expand_path(File.join(File.dirname(__FILE__), "../vendor/motion_data/ext")), :static)
end
