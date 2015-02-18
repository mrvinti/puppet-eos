begin
  require 'puppet_x/eos/version'
  require 'puppet_x/eos/autoload'
  require 'puppet_x/eos/eapi'
rescue LoadError => detail
  # Work around #7788 (Rubygems support for modules)
  require 'pathname' # JJM WORK_AROUND #14073
  module_base = Pathname.new(__FILE__).dirname
  require module_base + "../../../" + "puppet_x/eos/version"
  require module_base + "../../../" + "puppet_x/eos/autoload"
  require module_base + "../../../" + "puppet_x/eos/eapi"
end

##
# eos namespace
module Eos
end
