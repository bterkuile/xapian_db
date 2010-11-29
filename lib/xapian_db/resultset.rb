# encoding: utf-8

# The resultset holds a Xapian::Query object and allows paged access
# to the found documents.
# author Gernot Kogler

module XapianDb
  
  class Resultset
    
    attr_reader :size
    
    # Constructor
    # @param [Xapian::Enquire] a Xapian query result
    def initialize(enquiry)
      @enquiry = enquiry
      # By passing 0 as the max parameter to the mset method,
      # we only get statistics about the query, no results
      @size = enquiry.mset(0, 0).matches_estimated
    end

    # Paginate the result
    def paginate(opts={})
      options = {:page => 1, :per_page => 10}.merge(opts)
      offset = (options[:page] - 1) * options[:per_page]
      return [] if offset > @size
      build_page(offset, options[:per_page])
    end
    
    private
    
    # Build a page of Xapian documents
    def build_page(offset, count)
      docs = []
      result_window = @enquiry.mset(offset, count)
      result_window.matches.each do |match|
        docs << decorate(match.document)
      end
      docs
    end
    
    # Decorate a Xapian document with field accessors
    def decorate(document)
      klass_name = document.values[0].value
      blueprint  = XapianDb::DocumentBlueprint.blueprint_for(Kernel.const_get(klass_name))
      document.extend blueprint.accessors_module
      document
    end
              
  end
  
end