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

Puppet::Type.newtype(:eos_prefixlist) do
  @doc = 'Configure prefix lists'

  ensurable

  # Parameters

  newparam(:name) do
    desc 'Specifies the name of the access list'
  end

  # Properties (state management)

  newproperty(:seqno) do
    desc 'The entry seqno <0-65535>'
  end

  newproperty(:action) do
    desc 'Action for this rule to perform if matched'
    newvalues(:permit, :deny)
  end

  newproperty(:prefix) do
    desc 'IP prefix to match'
  end

  newproperty(:mask) do
    desc 'Prefix mask'
  end

  newproperty(:masklen) do
    desc 'Mask len'
  end

  newproperty(:eq) do
    desc 'equal to <1-32>'
  end

  newproperty(:ge) do
    desc 'greater than <1-32>; must be equal to or greater than the mask len'
  end

  newproperty(:le) do
    desc 'less than <1-32>; must be be equal to or greater than the mask len'
  end
end
