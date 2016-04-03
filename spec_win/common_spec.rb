require 'spec_helper'

context "ExecutionPolicy が RemoteSigned になっている場合..." do
  describe command("powershell -Command \"Get-ExecutionPolicy\"") do
    its(:stdout) { should match /RemoteSigned/ }
  end
end

context "NetConnectionProfile が Private になっている場合..." do
  describe command("powershell -Command \"Get-NetConnectionProfile | select -First 1 NetworkCategory -ExpandProperty NetworkCategory\"") do
    its(:stdout) { should match /Private/ }
  end
end

context "python がインストールされている / python へのパスが適切に設定されている / pywin32 がインストールされている場合..." do

  describe file("C:\\Python27\\python.exe") do 
    it { should be_file }
  end

  describe command("powershell -Command \"Get-ChildItem env:Path | select value -ExpandProperty value |Select-String python -quiet\"") do
    its(:stdout) { should match /True/ }
  end

  describe file("C:\\Python27\\Lib\\site-packages\\pywin32-220-py2.7-win-amd64.egg") do 
    it { should be_directory }
  end
end

context "Time Zone が Tokyo Standard Time に設定されている場合..." do
  describe command("powershell -Command \"tzutil.exe /g\"") do
    its(:stdout) { should match /Tokyo Standard Time/ }
  end
end
