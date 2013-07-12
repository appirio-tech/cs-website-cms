class RequirementsController < ApplicationController
  respond_to :json

  def index
    if params[:challenge_id]
      respond_with Requirement.where("challenge_id = ?", params[:challenge_id]).order("order_by")
    elsif params[:library]
      respond_with Requirement.where("library = ?", params[:library]).order("order_by")
    else
      respond_with Requirement.all
    end
  end

  def create
    requirement = Requirement.new(params[:requirement])
    if requirement.save
      Resque.enqueue(MadisonCreateRequirement, requirement)
      respond_with requirement
    else
      respond_with requirement.errors
    end    
  rescue Exception => e
    puts e.message
  end   

  def update
    requirement = Requirement.find(params[:id])
    if requirement.update_attributes(params[:requirement])
      Resque.enqueue(MadisonUpdateRequirement, requirement)
      respond_with requirement
    else
      respond_with requirement.errors
    end
  end   

  def destroy
    requirement = Requirement.find(params[:id])
    Resque.enqueue(MadisonDeleteRequirement, requirement) 
    requirement.destroy
  end    

end