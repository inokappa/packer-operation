require 'rake'
require 'rspec/core/rake_task'
#
require 'fileutils'
require 'aws-sdk'
require 'yaml'
#
desc "Build Image"
task :ec2build do
  sh "cd ~/packer/hello_ami/ && packer build hello_ami.json"
end
#
desc "Launch EC2 instances."
task :ec2launch do
  config = YAML.load(File.read("config.yml"))
  AWS.config(config)
  AWS.ec2.images.with_tag("Name", config.fetch("image_tag_name")).each do |image|
    inst = AWS.ec2.instances.create({
      :image_id => image.image_id,
      :instance_type => config.fetch("instance_type"),
      :subnet => config.fetch("vpc_subnet"),
      :security_group_ids => config.fetch("security_group"),
      :key_name => config.fetch("key_name"),
    })
    AWS.ec2.tags.create(inst, 'Name',:value => config.fetch("tag_name"))
  end
end
#
desc "Generate Spec File."
task :genspec do
  sh "rm -rf ./spec/ec*"
  config = YAML.load(File.read("config.yml"))
  AWS.config(config)
  #
  ORIG = "./spec_template"
  SPEC = "./spec"
  #
  servers = AWS.ec2.instances.select {|i| i.tags[:Name] == config.fetch("tag_name") && i.status == :running}.map(&:dns_name)
  servers.each do |server|
    puts "Created #{SPEC}/#{server}/check_spec.rb"
    FileUtils.cp_r("#{ORIG}","#{SPEC}""/""#{server}") unless FileTest.exist?(server)
  end
end
#
desc "Terminate Instance"
task :ec2terminate do
  config = YAML.load(File.read("config.yml"))
  AWS.config(config)
  AWS.ec2.instances.with_tag("Name", config.fetch("tag_name")).each do |instance|
    instance.terminate
  end
end
#
# execute "rake spec"
#
desc "Instance Check via Serverspec"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end
