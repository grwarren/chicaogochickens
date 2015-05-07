class OrdersController < ApplicationController
  before_action :set_current_user
  before_action :set_products, only: [:new, :create]

  def new
    @orders = Responses::OrderResponse.new(user: @current_user).orders
  end

   def index_all
    @orders = Order.all.order_by(:delivery_date.desc, :product.asc)
   end

  def index
    unless @current_user.nil?
      @orders = @current_user.orders.order_by(:delivery_date.desc, :product.asc)

      @grid = PivotTable::Grid.new do |g|
        g.source_data = @orders.to_a
        g.column_name = :delivery_date
        g.row_name = :product
        g.value_name   = :quantity
      end

      @grid.build


    end

  end

   def create
     params = order_params.merge(user: @current_user)
     order_request = Requests::OrderRequest.new(params: params)
     if order_request.save
       redirect_to user_orders_path(@current_user) , notice: 'Your order has been saved'
     else
       @order = order_request.order
       render :new
     end
   end

    def update
      puts "order update_params = " + user_params.inspect
      if @current_user.update(user_params)
        redirect_to user_orders_url(@current_user), notice: "Your orders were successfully updated."
      else
        render action: 'edit'
      end
  end

private
   def user_params
    params.require(:user).permit!
   end

  def order_params
    params.require(:order).permit(:quantity, :delivery_date, :product, :user_name)
  end

  def set_products
    @products = Product.all.order_by(:sort_order.asc)
  end

end
