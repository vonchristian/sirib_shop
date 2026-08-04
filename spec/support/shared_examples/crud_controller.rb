require "rails_helper"

RSpec.shared_examples "a standard crud controller" do |opts|
  let(:resource_name) { opts.fetch(:resource).to_s }
  let(:resource_plural) { resource_name.pluralize }
  let(:record_class) { opts.fetch(:record_class) }
  let(:factory_name) { opts.fetch(:factory, resource_name).to_s }
  let(:record) { resolve(opts[:record] || -> { create(factory_name, business: business) }) }

  def resolve(value)
    value.respond_to?(:call) ? instance_exec(&value) : value
  end

  let(:valid_params) { resolve(opts.fetch(:valid_params)) }
  let(:invalid_params) { resolve(opts.fetch(:invalid_params)) }

  it "indexes" do
    get send("#{resource_plural}_path")
    expect(response).to have_http_status(:ok)
  end

  it "renders new" do
    get send("new_#{resource_name}_path")
    expect(response).to have_http_status(:ok)
  end

  it "creates and shows" do
    post send("#{resource_plural}_path"), params: { resource_name => valid_params }
    expect(response).to redirect_to(send("#{resource_name}_path", record_class.last))
    get send("#{resource_name}_path", record_class.last)
    expect(response).to have_http_status(:ok)
  end

  it "re-renders new on invalid create" do
    post send("#{resource_plural}_path"), params: { resource_name => invalid_params }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "renders edit and updates" do
    get send("edit_#{resource_name}_path", record)
    expect(response).to have_http_status(:ok)

    patch send("#{resource_name}_path", record), params: { resource_name => valid_params }
    expect(response).to redirect_to(send("#{resource_name}_path", record.reload))
  end

  it "re-renders edit on invalid update" do
    patch send("#{resource_name}_path", record), params: { resource_name => invalid_params }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
