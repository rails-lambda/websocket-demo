module Lamby
  class Command

    def call
      begin
        body = eval(command, TOPLEVEL_BINDING).inspect
        { statusCode: 200, headers: {}, body: body }
      rescue Exception => e
        body = "#<#{e.class}:#{e.message}>".tap do |b|
          if e.backtrace
            b << "\n"
            b << e.backtrace.join("\n")
          end
        end
        { statusCode: 422, headers: {}, body: body }
      end
    end

  end
end
