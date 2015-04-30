#
# Copyright (c) 2014, Arista Networks, Inc.
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
begin
  require 'puppet_x/eos/eapi'
rescue LoadError => detail
  # Work around #7788 (Rubygems support for modules)
  require 'pathname' # JJM WORK_AROUND #14073
  module_base = Pathname.new(__FILE__).dirname
  require module_base + "../../" + "puppet_x/eos/eapi"
end

##
# PuppetX namespace
module PuppetX
  ##
  # Eos namesapece
  module Eos
    ##
    # EapiProviderMixin module
    module EapiProviderMixin
      def prefetch(resources)
        #provider_hash = {}
        provider_hash = ENV.to_hash
        instances.each do |provider|
          provider_hash[provider.name] = provider
        end

        resources.each_pair do |name, resource|
          resource.provider = provider_hash[name] if provider_hash[name]
        end
      end

      def conf
        filename = ENV['PUPPET_X_EAPI_CONF'] || '/mnt/flash/eapi.conf'
        YAML.load_file(filename)
      end

      def eapi
        @eapi ||= PuppetX::Eos::Eapi.new(conf)
      end
    end
  end
end
