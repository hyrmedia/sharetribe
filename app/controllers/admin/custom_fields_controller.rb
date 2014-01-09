class Admin::CustomFieldsController < ApplicationController
  
  before_filter :ensure_is_admin
  before_filter :custom_fields_allowed
  
  skip_filter :dashboard_only
  
  def index
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = DropdownField.new
    @custom_fields = @current_community.categories.flat_map(&:custom_fields).uniq.sort
    @custom_field.options = [CustomFieldOption.new, CustomFieldOption.new]
    session[:option_amount] = 1
  end
  
  def create
    success = if valid_categories?(@current_community, params[:custom_field][:category_attributes])
      @custom_field = DropdownField.new(params[:custom_field])
      @custom_field.save
    end

    flash[:error] = "Listing field saving failed" unless success

    redirect_to admin_custom_fields_path
  end

  def destroy
    @custom_field = DropdownField.find(params[:id])
    success = @custom_field.destroy
    redirect_to admin_custom_fields_path
  end
  
  def add_option
    session[:option_amount] += 1
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  private

  # Return `true` if all the category id's belong to `community`
  def valid_categories?(community, category_attributes)
    is_community_category = category_attributes.map do |category|
      community.categories.any? { |community_category| community_category.id == category[:category_id].to_i }
    end

    is_community_category.all?
  end

  # Before filter
  def custom_fields_allowed
    unless @current_community.custom_fields_allowed?
      flash[:error] = "Custom listing fields are not enabled for this community"
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end

end