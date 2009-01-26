#
#--
# Copyright (c) 2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++
#

unless defined?(FFI)
  #
  # don't require rubygems if not necessary
  #
  require 'rubygems'
  require 'ffi'
end

module Rufus
module Tokyo

  VERSION = '0.1.3'

  #
  # A common error class
  #
  class TokyoError < RuntimeError; end

  #
  # Some methods common to all the API bindings
  #
  module TokyoApiMixin

    #
    # The path to the lib in use
    #
    # (returns something like '/usr/local/lib/libtokyodystopia.dylib')
    #
    attr_accessor :lib

    #
    # Given a list of paths, link to the first one available (via #ffi_lib)
    #
    def ffi_paths (paths)

      paths.each do |path|
        if File.exist?(path)
          ffi_lib(path)
          @lib = path
          break
        end
      end
    end

    #
    # Given a short function name, attaches the full function name to that
    # short name
    #
    # (beware names like 'new' and 'open')
    #
    def attach_func (short_name, params, ret)

      long_name = "#{api_name}#{short_name}"
      attach_function(short_name, long_name, params, ret)
    end

    #
    # Returns the api name (downcased), something like 'tcadb' or 'tcwdb'
    #
    def api_name

      ancestors.first.name.split('::').last.downcase
    end
  end

  #
  # a class common to all the Tokyo containers, mainly provides the 'api'
  # methods
  #
  class TokyoContainer

    #
    # meta stuff
    #

    def self.metaclass #:nodoc#
      class << self; self; end
    end
    def self.meta_eval (&block) #:nodoc#
      metaclass.instance_eval(&block)
    end
    #def self.meta_def (method_name, &block) #:nodoc#
    #  meta_eval { define_method(method_name, &block) }
    #end
    #def class_def (method_name, &block) #:nodoc#
    #  class_eval { define_method(name, &block) }
    #end

    #
    # Registers the api class to use for this container
    #
    def self.api (api)
      meta_eval { @api = api }
    end

    #
    # Returns the api class to use
    #
    def api
      self.class.meta_eval { @api }
    end
  end

  #
  # Some constants shared by most of Tokyo Cabinet APIs
  #
  module TokyoContainerMixin

    #
    # some Tokyo constants

    OREADER = 1 << 0 # open as a reader
    OWRITER = 1 << 1 # open as a writer
    OCREAT = 1 << 2 # writer creating
    OTRUNC = 1 << 3 # writer truncating
    ONOLCK = 1 << 4 # open without locking
    OLCKNB = 1 << 5 # lock without blocking

    OTSYNC = 1 << 6 # synchronize every transaction (tctdb.h)

    #
    # Makes sure that a set of parameters is a hash (will transform an
    # array into a hash if necessary)
    #
    def params_to_h (params)

      params.is_a?(Hash) ?
        params :
        Array(params).inject({}) { |h, e| h[e] = true; h }
    end

    #
    # Given params (array or hash), computes the open mode (an int)
    # for the Tokyo Cabinet object.
    #
    def compute_open_mode (params)

      params = params_to_h(params)

      {
        :read => OREADER,
        :reader => OREADER,
        :write => OWRITER,
        :writer => OWRITER,
        :create => OCREAT,
        :truncate => OTRUNC,
        :no_lock => ONOLCK,
        :lock_no_block => OLCKNB,
        :sync_every => OTSYNC

      }.inject(0) { |r, (k, v)|

        r = r | v if params[k]; r
      }
    end
  end
end
end
