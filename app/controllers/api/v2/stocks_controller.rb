# frozen_string_literal: true

module Api
  module V2
    class StocksController < ApplicationController
      include StocksService
      layout false
      respond_to :json

      # POST
      def create
        stock_params = params.permit(%i[name bearer_id])
        data = stock_params.present? ? create_stock(stock_params) : I18n.t('errors.empty_params')

        render json: data, status: :ok
      end

      # PUT
      def update
        stock_params = params.permit(%i[id name bearer_id bearer_name])
        data = update_stock(stock_params)

        render json: data, status: :ok
      end

      # GET
      def list
        json = Stock.all.map { |s| { id: s.id, name: s.name, bearer: s.bearer } }

        render json: json.presence || I18n.t('stock.error.create'), status: :ok
      end

      # DELETE
      def delete
        render json: delete_stock(params.permit(:id)), status: :ok
      end
    end
  end
end
