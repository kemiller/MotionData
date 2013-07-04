Motion::Project::App.setup do |app|
  %w{
    scope.rb
    managed_object.rb
    predicate.rb
    context.rb
    store_coordinator.rb
    setup.rb
  }.map { |f| File.join(File.dirname(__FILE__), "motion_data/#{f}") }.each { |f| app.files.unshift(f) }

  app.files.unshift(File.join(File.dirname(__FILE__), "cdq.rb"))

  %w{
    partial_predicate.rb
    query.rb
    targeted_query.rb
  }.map { |f| File.join(File.dirname(__FILE__), "cdq/#{f}") }.each { |f| app.files.unshift(f) }

  app.frameworks += %w{ CoreData }
  app.vendor_project(File.expand_path(File.join(File.dirname(__FILE__), "../vendor/motion_data/ext")), :static)
end
