module EventHub
  
  class Message

    VERSION = '1.0.0'

    # Headers that are required (value can be nil) in order to pass valid?
    REQUIRED_HEADERS = [
      'message_id',
      'version',
      'created_at',
      'origin.module_id',
      'origin.type',
      'origin.site_id',
      'process.name',
      'process.step_position',
      'process.execution_id',
      'status.retried_count',
      'status.code',
      'status.message'
    ]

    attr_accessor :header, :body, :raw, :vhost, :routing_key

    # Build accessors for all required headers
    REQUIRED_HEADERS.each do |header|
      name = header.gsub(/\./,"_")

      define_method(name) do
        self.header.get(header)
      end

      define_method("#{name}=") do |value|
        self.header.set(header,value)
      end
    end

    def self.from_json(json)
      data = JSON.parse(json)
      Eventhub::Message.new(data.get('header'), data.get('body'),json)
    rescue => e
      Eventhub::Message.new({ "status" =>  { "code" => STATUS_INVALID, "message" => "JSON parse error: #{e}" }} ,{},json)
    end

    # process_step_position should be
    def initialize(header, body,raw=nil)

      @header = header || {}
      @body   = body || {}
      @raw    = raw

      # set message defaults, that we have required headers
      now = Time.now
      @header.set('message_id',UUIDTools::UUID.timestamp_create.to_s,false)
      @header.set('version',VERSION,false)
      @header.set('created_at',now.utc.strftime("%Y-%m-%dT%H:%M:%S.#{now.usec/1000}Z"),false)

      @header.set('process.name',nil,false)
      @header.set('process.execution_id',UUIDTools::UUID.timestamp_create.to_s,false)
      @header.set('process.step_position',0,false)

      @header.set('status.retried_count',0,false)
      @header.set('status.code',STATUS_INITIAL,false)
      @header.set('status.message',nil,false)

    end

    def valid?
      REQUIRED_HEADERS.all? { |key| @header.all_keys_with_path.include?(key) }
    end

    def success?
      self.status_code == STATUS_SUCCESS
    end

    def retry?
      !success?
    end

    def initial?
      self.status_code == STATUS_INITIAL
    end

    def retried?
      self.status_code == STATUS_RETRIED
    end

    def to_json
      {'header' => self.header, 'body' => self.body}.to_json
    end

    def to_s
      "Message: message_id [#{self.message_id}], status.code [#{status_code}], status.message [#{status_message}], status.retried_count [#{status_retried_count}] "
    end

    def copy(args={})
      copied_header = self.header.dup
      copied_body   = self.body.dup

      args.each { |key,value| copied_header.set(key,value) } if args.is_a?(Hash)
      Eventhub::Message.new(copied_header, copied_body)
    end  

  end

end
