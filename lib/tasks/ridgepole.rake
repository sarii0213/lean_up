namespace :ridgepole do
  desc 'Apply database schema'
  task apply: :environment do
    run('--apply')
    Rake::Task['annotate_models'].invoke if Rails.env.development?
  end

  desc 'Export database schema'
  task export: :environment do
    run('--export')
  end

  desc 'Diff database schema'
  task diff: :environment do
    run('--diff')
  end

  private

  def run(*options)
    config = 'config/database.yml'
    schema = 'db/Schemafile'
    rails_env = ENV['RAILS_ENV'] || Rails.env

    command = "bundle exec ridgepole --config #{config} --env #{rails_env} --file #{schema}"
    command = [command, *options].join(' ')

    puts '=== run ridgepole... ==='
    puts "[Running] #{command}"
    system command
  end
end
