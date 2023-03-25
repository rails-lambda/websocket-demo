class MessagesController < ApplicationController
  def new
    @message = room.messages.new
  end

  def create
    @message = room.messages.create!(message_params)
    redirect_to(room)
  end
  
  private

  def room
    @room ||= Room.find(params[:room_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
