# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"

Rake::ExtensionTask.new "baba_vm" do |ext|
  ext.lib_dir = "lib/baba"
end

task default: [:clean, :compile]
