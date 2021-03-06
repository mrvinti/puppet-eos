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

Puppet::Type.newtype(:eos_ntp_config) do
  @doc = <<-EOS
    Manage global NTP configuration settings on Arista EOS.

    Example:

        eos_ntp_config { 'settings':
          source_interface => 'Management1',
        }
  EOS

  # Parameters

  newparam(:name) do
    desc <<-EOS
      The name parameter identifies the global NTP instance for
      configuration and should be configured as 'settings'.  All
      other values for name will be siliently ignored by the provider.
    EOS
    isnamevar
  end

  # Properties (state management)
  #
  newproperty(:source_interface) do
    desc <<-EOS
      The source interface property provides configuration management
      of the NTP source-interface value.  The source interface value
      configures the interface address to use as the source address
      when sending NTP packets on the network.

      The default value for source_interface is ''
    EOS

    validate do |value|
      unless value =~ /^[EMPLV]/
        fail "value #{value.inspect} is invalid, must be an interface name"
      end
    end
  end
end
