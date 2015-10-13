#
# Copyright (c) 2014, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#  Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the following disclaimer.
#
#  Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#
#  Neither the name of Arista Networks nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.
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
# encoding: utf-8

Puppet::Type.newtype(:eos_prefix_list) do
  @doc = 'Configures prefix lists in EOS'

  ensurable

  # Parameters

  newparam(:name) do
    desc <<-EOS
      The name parameter is a composite namevar that combines the
      prefix-list name and the sequence number delimited by the
      colon (:) character

      For example, if the prefix-list name is foo and the sequence
      number for this rule is 10 the namvar would be constructed as
      "foo:10"

      The composite namevar is required to uniquely identify the
      specific list and rule to configure
    EOS
  end

  # Properties (state management)

  newproperty(:prefix_list) do
    desc 'Specifies the name of the prefix list'
  end

  newproperty(:seqno) do
    desc 'Specifies this rules sequence number'

    munge { |value| Integer(value) }

    validate do |value|
      unless value.to_i.between?(0, 65_535)
        fail "value #{value.inspect} is not between 1 and 65535"
      end
    end
  end

  newproperty(:action) do
    desc 'Configures the type of rule as either a permit or deny'
    newvalues(:permit, :deny)
  end

  newproperty(:prefix) do
    desc 'Configures the network prefix to match'
  end

  newproperty(:masklen) do
    desc 'Configures the network prefix mask'

    munge { |value| Integer(value) }

    validate do |value|
      unless value.to_i.between?(0, 32)
        fail "value #{value.inspect} is not between 0 and 32"
      end
    end
  end

  newproperty(:eq) do
    munge { |value| Integer(value) }

    validate do |value|
      unless value.to_i.between?(0, 32)
        fail "value #{value.inspect} is not between 0 and 32"
      end
    end

  end

  newproperty(:ge) do
    munge { |value| Integer(value) }

    validate do |value|
      unless value.to_i.between?(0, 32)
        fail "value #{value.inspect} is not between 0 and 32"
      end
    end
  end

  newproperty(:le) do
    munge { |value| Integer(value) }

    validate do |value|
      unless value.to_i.between?(0, 32)
        fail "value #{value.inspect} is not between 0 and 32"
      end
    end
  end
end


