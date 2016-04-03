require 'rake'
require 'rspec/core/rake_task'
require 'fileutils'
require 'aws-sdk'
require 'yaml'
require 'openssl'
require 'base64'
require 'erb'

config = YAML.load(File.read("config.yml"))
win_password = ""

ec2 = Aws::EC2::Client.new(
  access_key_id: config['access_key_id'],
  secret_access_key: config['secret_access_key'],
  region: config["region"]
)

#
desc "Build Image"
task :build do
  sh "PACKER_LOG=1 packer build template.json"
end
#
namespace :ec2 do

  desc "Get logon Password"
  task :getpw do
    instance = ec2.describe_instances({
      filters: [
        { name: "tag-value", values: [config["tag_name"]]},
        { name: "instance-state-name", values: ["running"]},
      ]
    })
    password_data = ec2.get_password_data({
      instance_id: instance.reservations[0].instances[0].instance_id
    }).password_data
    if password_data != ""
      private_key = OpenSSL::PKey::RSA.new(File.read(config['key_path']))
      decoded = Base64.decode64(password_data)
      win_password = private_key.private_decrypt(decoded)
    else
      puts "password_data empty"
    end
  end

  desc "Launch EC2 instances."
  task :launch do
    ec2.describe_images({
      filters: [
        { name: "name", values: [config["image_tag_name"]] }
      ]
    }).each do |image|
      instance = ec2.run_instances({
        :image_id => image.images[0].image_id,
        :instance_type => config["instance_type"],
        :subnet_id => config["vpc_subnet"],
        :security_group_ids => [config["security_group"]],
        :key_name => config["key_name"],
        :min_count => 1,
        :max_count => 1,
        :user_data => Base64.encode64(File.read(config["user_data_path"]))
      })
      ec2.create_tags({
        resources: [instance.instances[0].instance_id],
        tags: [
          { key: "Name", value: config["tag_name"] }
        ] 
      })
      ec2.wait_until(:instance_running,  instance_ids:[instance.instances[0].instance_id])
    end
  end

  desc "Terminate Instance"
  task :terminate do
    instance = ec2.describe_instances({
      filters: [
        { name: "tag-value", values: [config["tag_name"]]},
        { name: "instance-state-name", values: ["running"]},
      ]
    })
    # p instance.reservations[0]
    ec2.terminate_instances({
      instance_ids: [instance.reservations[0].instances[0].instance_id]
    })
    ec2.wait_until(:instance_terminated,  instance_ids:[instance.reservations[0].instances[0].instance_id])
  end

end
#
namespace :genspec do
  spc = "./spec"
  spec_helper = spc + "/" + "spec_helper.rb"

  instance = ec2.describe_instances({
    filters: [
      { name: "tag-value", values: [config["tag_name"]]},
      { name: "instance-state-name", values: ["running"]},
    ]
  })

  server = instance.reservations[0].instances[0].public_dns_name
  desc "Generate Spec File."
  task :linux do
    sh "rm -rf ./spec/ec*"
    org = "./spec_linux"
    #
    # server = instance.reservations[0].instances[0].public_dns_name
    FileUtils.cp_r("spec_helpers/spec_helper.rb.linux", spec_helper) unless FileTest.exist?(spec_helper)
    puts "Created " + spc "/" + "/spec_helper.rb"
    FileUtils.cp_r(org, spc + "/" + server) unless FileTest.exist?(server)
    puts "Created " + spc + "/" + server + "/check_spec.rb"
  end

  desc "Generate Spec File."
  task :win => "ec2:getpw" do
    sh "rm -rf ./spec/ec*"
    org = "./spec_win"
    #
    # server = instance.reservations[0].instances[0].public_dns_name
    result = ERB.new(File.read("spec_helpers/spec_helper.rb.win")).result(binding)
    File.open(spec_helper, "w") do |file|
      file.puts result
      puts "Created " + spc "/" + "/spec_helper.rb"
    end
    FileUtils.cp_r(org, spc + "/" + server) unless FileTest.exist?(server)
    puts "Created " + spc + "/" + server + "/check_spec.rb"
  end

end

#
# execute "rake spec"
#
namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym)  do |t|
      ENV['TARGET_HOST'] = original_target
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end
