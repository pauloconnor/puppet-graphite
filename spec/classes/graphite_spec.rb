require 'spec_helper'

describe 'graphite' do
  context 'supported operating systems' do
    describe "graphite class without any parameters on Debian" do
      let(:params) {{ 
        :graphite_version => 'present',
        :carbon_version => 'present',
        :whisper_version => 'present',
        }}
      let(:facts) {{
        :osfamily => 'Debian',
        :concat_basedir => '/dne',
        :ipaddress => '127.0.0.1'
      }}

      it { should compile }
      it { should contain_class('graphite') }
      it { should contain_class('graphite::config') }
      it { should contain_file('/opt/graphite/conf/storage-schemas.conf') }
    end
  end
end
