require 'spec_helper'

describe 'graphite' do
  context 'supported operating systems' do
    describe "graphite class without any parameters on Debian" do
      let(:params) {{ 
        :graphiteVersion => 'present',
        :carbonVersion => 'present',
        :whisperVersion => 'present',
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
