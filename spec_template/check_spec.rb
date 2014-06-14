require 'spec_helper'

describe package('httpd') do
  it { should be_installed }
end

describe file('/etc/motd') do
  its(:content) { should match /tegokoro ami/ }
end
