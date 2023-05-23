import { Controller } from "@hotwired/stimulus";
import { cable } from "@hotwired/turbo-rails";

export default class extends Controller {
  async logout() {
    // const consumer = await cable.getConsumer();
    // consumer.disconnect();
  }
}
