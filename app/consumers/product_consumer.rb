class ProductConsumer
  def self.start
    exchange = $channel.fanout('product.events')
    queue = $channel.queue('', durable: true)
    queue.bind(exchange)

    puts "ProductConsumer is waiting for messages..."

    queue.subscribe(block: true) do |_delivery_info, _properties, body|
      begin
        data = JSON.parse(body)
        case data['event']
        when 'created', 'updated'
          payload = build_product_payload(data)
          product = Product.find_or_initialize_by(id: payload[:id])
          product.update!(payload)        
        when 'deleted'
          product = Product.find(data["id"])
          product.delete()
        end
      rescue => e
        puts "Error processing message: #{e.message}"
      end
    end
  end

  private

  def self.build_product_payload(data)
    {
      id: data["id"],
      name: data["name"],
      image: data["images"][0],
      price: data["price"],
      status: data["status"]
    }
  end
end