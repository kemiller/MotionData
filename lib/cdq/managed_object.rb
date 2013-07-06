
module CDQ

  class CDQManagedObject < NSManagedObject

    extend CDQ

    class << self

      def where(*args)
        cdq.where(*args)
      end

      def sort_by(*args)
        cdq.sort_by(*args)
      end

      def limit(*args)
        cdq.limit(*args)
      end

      def first
        cdq.first
      end

      def all
        cdq.all
      end

      def scope(name, query)
        cdq.scope name, query
        self.class.send(:define_method, name) do |*args|
          query
        end
      end

      def method_missing(name, *args)
        cdq.send(name, *args)
      end

    end

  end
  
end
