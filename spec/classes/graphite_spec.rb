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
    end
  end
end
