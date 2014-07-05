require_relative 'spec_helper'

describe 'box' do
  # this tests if rsync works from bin/test-box-vcloud.bat
  describe file('/vagrant/testdir/testfile.txt') do
    it { should be_file }
    its(:content) { should match /Works/ }
  end

  # check SSH
  describe service('ssh') do
    it { should be_enabled }
    it { should be_running }
  end
  describe port(22) do
    it { should be_listening  }
  end

  # check for 10GBit vmxnet3
  describe command('dmesg') do
    it { should return_stdout(/vmxnet3.*eth0: NIC Link is Up 10000 Mbps/)   }
  end

end
