class CartController < ApplicationController

	before_action :authenticate_user!, except: [:add_to_cart, :view_order, :edit_cart, :remove_from_cart]

  def add_to_cart
    @order = current_order

  	# line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])

    line_item = @order.line_items.new(product_id: params[:product_id], quantity: params[:quantity])
    @order.save
    session[:order_id] = @order.id

    line_item.update(line_item_total: (line_item.quantity * line_item.product.price))

  	redirect_back(fallback_location: root_path)
  end

  def view_order
  	@line_items = current_order.line_items
  end

  def edit_cart
    line_item = LineItem.find(params[:id])

    line_item.update(quantity: params[:quantity])
    line_item.update(line_item_total: (line_item.quantity * line_item.product.price))

    redirect_back(fallback_location: root_path)
  end

  def remove_from_cart
    line_item = LineItem.find(params[:id])
    line_item.destroy

    redirect_back(fallback_location: root_path)
  end

  def checkout
    line_items = current_order.line_items
    
    if line_items.length != 0
      current_order.update(user_id: current_user.id, subtotal: 0)
      @order = current_order

      line_items.each do |line_item|
        line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
        @order.order_items[line_item.product_id] = line_item.quantity
        @order.subtotal += line_item.line_item_total
      end

      @order.save

      @order.update(sales_tax: (@order.subtotal * 0.07))
      @order.update(grand_total: (@order.sales_tax + @order.subtotal))

      line_items.destroy_all
      session[:order_id] = nil
    end
  end

  def order_complete
    @order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i

    customer = Stripe::Customer.create(
      :email => current_user.email,
      :card => params[:stripeToken]
      )

    charge = Stripe::Charge.create(
      :customer => customer.id,
      :amount => @amount,
      :description => 'Rails Stripe customer',
      :currency => 'usd'
      )
    
    rescue Stripe::CardError => e
    flash[:error] = e.message
  end
end