# encoding: utf-8

# Mock for the beanstalk-client gem
# @author Gernot Kogler

module Beanstalk

  class Pool

    def initialize(*args)
    end

    def put(command)
      worker = XapianDb::IndexWriters::BeanstalkWorker.new
      params = YAML::load command
      task = params.delete :task
      worker.send task, params
    end

    def use(tube)

    end

  end
end
