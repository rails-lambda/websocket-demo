// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo, cable } from "@hotwired/turbo-rails"
import "controllers"

window.LambdaCable = {};
LambdaCable.consumer = await cable.getConsumer();
setInterval(() => {
  if (Turbo.session.enabled) {
    LambdaCable.consumer.connection.monitor.recordPing();
  }
}, 3000);
