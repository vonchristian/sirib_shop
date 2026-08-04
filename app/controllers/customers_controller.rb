class CustomersController < ApplicationController
  before_action :require_business_user
  before_action :set_customer, only: %i[show edit update]

  def index
    @customers = Customer.order(:name)
  end

  def tree
    roots = Customer.where(parent_id: nil).order(:name)
    @tree = roots.map { |c| build_tree(c) }
  end

  def show
  end

  def new
    @customer = Customer.new(parent_id: params[:parent_id])
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      redirect_to @customer, notice: "Customer created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Customer updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :customer_type, :code, :email, :phone, :tax_identifier, :status, :parent_id)
  end

  def build_tree(customer)
    {
      customer: customer,
      children: Customer.where(parent_id: customer.id).order(:name).map { |c| build_tree(c) }
    }
  end
end
