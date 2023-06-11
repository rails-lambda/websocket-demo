import { Turbo, cable } from "@hotwired/turbo-rails";
import "controllers";

//  Eventual LambdaCable Assets

class LambdaCable {
  constructor() {
    this.cable = cable;
    this.session = Turbo.session;
  }

  async start() {
    if (!this.isAdapter()) {
      return;
    }
    this.consumer = await this.cable.getConsumer();
    this.setRecordPingInterval();
    this.setPingApiGatewayInterval();
  }

  isAdapter() {
    const element = document.head.querySelector(
      `meta[name='action-cable-adapter']`
    );
    if (element) {
      return element.getAttribute("content") === "lambda_cable";
    }
  }

  apiGatewayPingInterval() {
    const element = document.head.querySelector(
      `meta[name='lambda-cable-ping-interval']`
    );
    if (element) {
      return parseInt(element.getAttribute("content"));
    } else {
      return 60000;
    }
  }

  // We force the state of ActionCable / Turbo to be happy since it is simply not going to get a
  // heartbeat ping from the server every 3 seconds. Instead we keep the connection alive via the
  // client-side ping to API Gateway. This method will check if the connection has been disconnected
  // from the server. This allows normal reconnect behavior to occur.
  //
  recordPing() {
    if (
      this.session.enabled &&
      this.consumer &&
      !this.consumer.connection.disconnected
    ) {
      this.consumer.connection.monitor.recordPing();
    }
  }

  setRecordPingInterval() {
    this.recordPingInterval = setInterval(this.recordPing.bind(this), 3000);
  }

  pingApiGateway() {
    if (this.session.enabled && this.consumer) {
      this.consumer.connection.send({ type: "ping" });
    }
  }

  setPingApiGatewayInterval() {
    this.pingApiGatewayInterval = setInterval(
      this.pingApiGateway.bind(this),
      this.apiGatewayPingInterval()
    );
  }
}

window.LambdaCable = new LambdaCable();
await window.LambdaCable.start();
