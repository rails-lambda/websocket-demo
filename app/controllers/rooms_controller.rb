class RoomsController < ApplicationController
  def index
    @rooms = Room.recent
  end

  def show
    room
  end

  def new
    @room = Room.new
  end

  def edit
    room
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      redirect_to room_url(@room), notice: "Room was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if room.update(room_params)
      redirect_to room_url(room), notice: "Room was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    room.destroy
    redirect_to rooms_url, notice: "Room was successfully destroyed."
  end

  private

  def room
    @room ||= Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name)
  end
end
