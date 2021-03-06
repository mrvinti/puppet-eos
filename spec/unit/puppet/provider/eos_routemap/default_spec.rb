#
# Copyright (c) 2015, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
#   Neither the name of Arista Networks nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'spec_helper'

include FixtureHelpers

describe Puppet::Type.type(:eos_routemap).provider(:eos) do
  def load_default_settings
    @name = 'test:10'
    @description = 'descript'
    @action = 'permit'
    @match = ['ip address prefix-list MYLOOPBACK', 'interface Loopback0']
    @set = ['community internet 5555:5555']
    @continue = 1
  end
  # Puppet RAL memoized methods
  let(:resource) do
    load_default_settings
    resource_hash = {
      name: @name,
      description: @description,
      action: @action,
      match: @match,
      set: @set,
      continue: @continue,
      ensure: :present,
      provider: described_class.name
    }
    Puppet::Type.type(:eos_routemap).new(resource_hash)
  end

  let(:provider) { resource.provider }

  let(:api) { double('routemaps') }

  def routemaps
    routemaps = Fixtures[:routemap]
    return routemaps if routemaps
    fixture('routemap', dir: File.dirname(__FILE__))
  end

  before :each do
    allow(described_class.node).to receive(:api).with('routemaps')
      .and_return(api)
    allow(provider.node).to receive(:api).with('routemaps').and_return(api)
    load_default_settings
  end

  context 'class methods' do
    before { allow(api).to receive(:getall).and_return(routemaps) }

    describe '.instances' do
      subject { described_class.instances }

      it { is_expected.to be_an Array }

      it 'has six entry' do
        expect(subject.size).to eq(8)
      end

      it 'has an instance for test' do
        instance = subject.find { |p| p.name == 'test:10' }
        expect(instance).to be_a described_class
      end

      context 'eos_routemap { test }' do
        subject { described_class.instances.find { |p| p.name == @name } }

        include_examples 'provider resource methods',
                         description: 'descript',
                         action: 'permit',
                         match: ['ip address prefix-list MYLOOPBACK',
                                 'interface Loopback0'],
                         set: ['community internet 5555:5555'],
                         continue: 1
      end
    end

    describe '.prefetch' do
      let :resources do
        {
          'test:10' => Puppet::Type.type(:eos_routemap).new(name: 'test:10'),
          'test:20' => Puppet::Type.type(:eos_routemap).new(name: 'test:20'),
          'test:30' => Puppet::Type.type(:eos_routemap).new(name: 'test:30'),
          'test:40' => Puppet::Type.type(:eos_routemap).new(name: 'test:40'),
          'test1:10' => Puppet::Type.type(:eos_routemap).new(name: 'test1:10'),
          'test1:20' => Puppet::Type.type(:eos_routemap).new(name: 'test1:20'),
          'test1:30' => Puppet::Type.type(:eos_routemap).new(name: 'test1:30'),
          'test1:40' => Puppet::Type.type(:eos_routemap).new(name: 'test1:40'),
          'test2:10' => Puppet::Type.type(:eos_routemap).new(name: 'test2:10')
        }
      end

      subject { described_class.prefetch(resources) }

      it 'resource providers are absent prior to calling .prefetch' do
        resources.values.each do |rsrc|
          expect(rsrc.provider.description).to eq(:absent)
          expect(rsrc.provider.action).to eq(:absent)
          expect(rsrc.provider.match).to eq(:absent)
          expect(rsrc.provider.set).to eq(:absent)
          expect(rsrc.provider.continue).to eq(:absent)
        end
      end

      it 'sets the provider instance of the managed resource test:10' do
        subject
        expect(resources['test:10'].provider.name).to eq('test:10')
        expect(resources['test:10'].provider.description).to eq(@description)
        expect(resources['test:10'].provider.action).to eq(@action)
        expect(resources['test:10'].provider.match).to eq(@match)
        expect(resources['test:10'].provider.set).to eq(@set)
        expect(resources['test:10'].provider.continue).to eq(@continue)
      end

      it 'sets the provider instance of the managed resource test:20' do
        subject
        expect(resources['test:20'].provider.name).to eq('test:20')
        expect(resources['test:20'].provider.action).to eq('permit')
        expect(resources['test:20'].provider.description).to eq(:absent)
        expect(resources['test:20'].provider.match).to eq(:absent)
        expect(resources['test:20'].provider.set).to eq(:absent)
        expect(resources['test:20'].provider.continue).to eq(:absent)
      end

      it 'sets the provider instance of the managed resource test:30' do
        subject
        expect(resources['test:30'].provider.name).to eq('test:30')
        expect(resources['test:30'].provider.action).to eq('deny')
        expect(resources['test:30'].provider.description).to eq('description')
        expect(resources['test:30'].provider.match).to eq(:absent)
        expect(resources['test:30'].provider.set).to eq(:absent)
        expect(resources['test:30'].provider.continue).to eq(1)
      end

      it 'sets the provider instance of the managed resource test1:40' do
        subject
        expect(resources['test1:40'].provider.name).to eq('test1:40')
        expect(resources['test1:40'].provider.action).to eq('permit')
        expect(resources['test1:40'].provider.description).to eq(:absent)
        expect(resources['test1:40'].provider.match).to eq(:absent)
        expect(resources['test1:40'].provider.set)
          .to eq(['community internet 5555:5555'])
        expect(resources['test1:40'].provider.continue).to eq(:absent)
      end

      it 'does not set the provider instance of the unmanaged resource' do
        subject
        expect(resources['test2:10'].provider.name).to eq('test2:10')
        expect(resources['test2:10'].provider.action).to eq(:absent)
        expect(resources['test2:10'].provider.description).to eq(:absent)
        expect(resources['test2:10'].provider.match).to eq(:absent)
        expect(resources['test2:10'].provider.set).to eq(:absent)
        expect(resources['test2:10'].provider.continue).to eq(:absent)
      end
    end

    it 'fails non composite name' do
      expect { Puppet::Type.type(:eos_routemap).new(name: 'notest') }
        .to raise_error(Puppet::ResourceError)
    end

    it 'fails seqno integer check' do
      expect { Puppet::Type.type(:eos_routemap).new(name: 'notest:abc') }
        .to raise_error(Puppet::ResourceError)
    end
  end

  context 'resource exists method' do
    describe '#exists?' do
      subject { provider.exists? }

      context 'when the resource does not exist on the system' do
        it { is_expected.to be_falsey }
      end

      context 'when the resource exists on the system' do
        let(:provider) do
          allow(api).to receive(:getall).and_return(routemaps)
          described_class.instances.first
        end
        it { is_expected.to be_truthy }
      end
    end
  end

  context 'resource (instance) methods' do
    describe '#create' do
      it 'sets ensure on the resource with all values' do
        expect(api).to receive(:create)
          .with('test',
                'permit',
                10,
                name: @name,
                description: @description,
                action: @action,
                match: @match,
                set: @set,
                continue: @continue)
        provider.create
        provider.description = @description
        provider.action = @action
        provider.match = @match
        provider.set = @set
        provider.continue = @continue
        provider.flush
        expect(provider.description).to eq(@description)
        expect(provider.action).to eq(@action)
        expect(provider.match).to eq(@match)
        expect(provider.set).to eq(@set)
        expect(provider.continue).to eq(@continue)
      end
    end

    describe '#description=(value)' do
      it 'sets description on the resource' do
        expect(api).to receive(:create).with('test',
                                             'permit',
                                             10,
                                             name: @name,
                                             description: @description,
                                             action: @action,
                                             match: @match,
                                             set: @set,
                                             continue: @continue)
        provider.create
        provider.description = @description
        provider.flush
        expect(provider.description).to eq(@description)
      end
    end

    describe '#action=(value)' do
      it 'sets action on the resource' do
        expect(api).to receive(:create).with('test',
                                             'permit',
                                             10,
                                             name: @name,
                                             description: @description,
                                             action: @action,
                                             match: @match,
                                             set: @set,
                                             continue: @continue)
        provider.create
        provider.action = @action
        provider.flush
        expect(provider.action).to eq(@action)
      end
    end

    describe '#match=(value)' do
      it 'sets match on the resource' do
        expect(api).to receive(:create).with('test',
                                             'permit',
                                             10,
                                             name: @name,
                                             description: @description,
                                             action: @action,
                                             match: @match,
                                             set: @set,
                                             continue: @continue)
        provider.create
        provider.match = @match
        provider.flush
        expect(provider.match).to eq(@match)
      end
    end

    describe '#set=(value)' do
      it 'sets set on the resource' do
        expect(api).to receive(:create).with('test',
                                             'permit',
                                             10,
                                             name: @name,
                                             description: @description,
                                             action: @action,
                                             match: @match,
                                             set: @set,
                                             continue: @continue)
        provider.create
        provider.set = @set
        provider.flush
        expect(provider.set).to eq(@set)
      end
    end

    describe '#continue=(value)' do
      it 'sets continue on the resource' do
        expect(api).to receive(:create).with('test',
                                             'permit',
                                             10,
                                             name: @name,
                                             description: @description,
                                             action: @action,
                                             match: @match,
                                             set: @set,
                                             continue: @continue)
        provider.create
        provider.continue = @continue
        provider.flush
        expect(provider.continue).to eq(@continue)
      end
    end

    describe '#destroy' do
      it 'sets ensure to :absent' do
        resource[:ensure] = :absent
        expect(api).to receive(:delete)
        provider.destroy
        provider.flush
        expect(provider.ensure).to eq(:absent)
      end
    end
  end
end
