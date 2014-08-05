require 'spec_helper'

describe 'graphite' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "graphite class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('graphite::params') }
        it { should contain_class('graphite::install').that_comes_before('graphite::config') }
        it { should contain_class('graphite::config') }
        it { should contain_class('graphite::service').that_subscribes_to('graphite::config') }

        it { should contain_service('graphite') }
        it { should contain_package('graphite').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'graphite class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('graphite') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
