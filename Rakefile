#!/usr/bin/env rake

require 'rubygems'
require 'hoe'
Hoe.plugin :doofus, :git, :gemcutter

Hoe.spec 'rubygems-mirror' do
  developer('James Tucker', 'raggi@rubyforge.org')

  extra_dev_deps << %w[hoe-doofus >=1.0.0]
  extra_dev_deps << %w[hoe-git >=1.3.0]
  extra_dev_deps << %w[hoe-gemcutter >=1.0.0]
  extra_dev_deps << %w[builder >=2.1.2]
  extra_deps << %w[net-http-persistent >=1.2.5]

  self.extra_rdoc_files = FileList["**/*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"
  self.rubyforge_name   = 'rubygems'
  self.testlib          = :minitest
end

namespace :mirror do
  desc "Run the Gem::Mirror::Command"
  task :update do
    $:.unshift File.join(File.dirname(__FILE__), 'lib')
    require 'rubygems/mirror/command'

    Gem.configuration.verbose = true

    mirror = Gem::Commands::MirrorCommand.new
    mirror.execute
  end
end
