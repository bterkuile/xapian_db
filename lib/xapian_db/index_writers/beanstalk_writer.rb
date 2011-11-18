# encoding: utf-8

# This writer puts reindex requests into a stalker queue. If you want
# to use this writer, you must install beanstalkd and the stalker gem.
# This writer can only be used inside a Rails app.
# See https://github.com/adamwiggins/stalker for more info
# @author Gernot Kogler

require 'beanstalk-client'

module XapianDb
  module IndexWriters

    class BeanstalkWriter

      class << self

        # Update an object in the index
        # @param [Object] obj An instance of a class with a blueprint configuration
        def index(obj, commit=true)
          beanstalk.use tube
          beanstalk.put( {:task => "index_task", :class => obj.class.name, :id => obj.id }.to_yaml )
        end

        # Remove an object from the index
        # @param [String] xapian_id The document id
        def delete_doc_with(xapian_id, commit=true)
          beanstalk.use tube
          beanstalk.put( { :task => "delete_doc_task", :xapian_id => xapian_id }.to_yaml )
        end

        # Reindex all objects of a given class
        # @param [Class] klass The class to reindex
        def reindex_class(klass, options={})
          beanstalk.use tube
          beanstalk.put( { :task => "reindex_class_task", :class => klass.name }.to_yaml )
        end

        private

        def beanstalk
          @beanstalk ||= Beanstalk::Pool.new([XapianDb::Config.beanstalk_daemon_url])
        end

        def tube
          XapianDb::Config.beanstalk_tube
        end

      end

    end

  end
end
