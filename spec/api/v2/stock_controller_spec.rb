# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::StocksController do
  context 'GET #list' do
    let!(:stock1) { FactoryBot.create :stock }
    let!(:stock2) { FactoryBot.create(:stock) }
    it 'return all stocks' do
      get '/list', as: :json
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq(Stock.count)
      expect(response.body).to eq(Stock.all.map { |s| { id: s.id, name: s.name, bearer: s.bearer } }.to_json)
    end

    it 'return NOT deleted' do
      stock1.update(deleted: true)
      get '/list', as: :json
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq(Stock.count)
      expect(response.body).to eq(Stock.all.map { |s| { id: s.id, name: s.name, bearer: s.bearer } }.to_json)
    end

    it 'return nothing' do
      stock1.update(deleted: true)
      stock2.update(deleted: true)
      get '/list', as: :json
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.error.create'))
    end
  end

  context 'DELETE #delete' do
    let!(:stock) { FactoryBot.create(:stock) }

    it 'successful' do
      delete "/delete/#{stock.id}", as: :json
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.successful_delete'))
      expect(Stock.all.count).to eq(0)
    end

    it 'not created' do
      delete '/delete/9999', as: :json
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.error.no_found'))
      expect(Stock.all.count).to eq(1)
    end

    it 'before deleted record' do
      stock.update(deleted: true)
      delete "/delete/#{stock.id}", as: :json
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.error.no_found'))
      expect(Stock.all.count).to eq(0)
      expect(Stock.unscoped.count).to eq(1)
    end

    it 'error until deleting' do
      expect(Stock).to receive(:delete).with(stock.id.to_s).and_return(false)
      delete "/delete/#{stock.id}", as: :json
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('errors.something_went_wrong'))
      expect(Stock.all.count).to eq(1)
      expect(Stock.unscoped.count).to eq(1)
    end
  end

  context 'POST #create' do
    let!(:bearer) { FactoryBot.create(:bearer) }
    it 'create' do
      expect(Stock.count).to eq(0)
      post '/create', params: { name: 'Test', bearer_id: bearer.id }, as: :json
      expect(response).to have_http_status(200)
      expect(Stock.count).to eq(1)
      expect(Stock.first.name).to eq('Test')
      expect(Stock.first.bearer_id).to eq(bearer.id)
    end

    context 'errored' do
      let!(:stock) { FactoryBot.create(:stock) }
      it 'existing name' do
        expect(Stock.count).to eq(1)
        post '/create', params: { name: stock.name, bearer_id: stock.bearer.id }, as: :json
        expect(Stock.count).to eq(1)
        expect(response).to have_http_status(200)
        expect(response.body).to eq('Error occurred: Name has already been taken')
      end

      it 'without params' do
        expect(Stock.count).to eq(1)
        post '/create', params: {}, as: :json
        expect(Stock.count).to eq(1)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('errors.empty_params'))
      end

      it 'without bearer params' do
        expect(Stock.count).to eq(1)
        post '/create', params: { name: stock.name }, as: :json
        expect(Stock.count).to eq(1)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('bearer.error.not_found'))
      end

      it 'without name params' do
        expect(Stock.count).to eq(1)
        post '/create', params: { bearer_id: stock.bearer.id }, as: :json
        expect(Stock.count).to eq(1)
        expect(response).to have_http_status(200)
        expect(response.body).to eq("Error occurred: Name can't be blank")
      end
    end
  end

  context 'PUT#update' do
    let!(:stock) { FactoryBot.create :stock }
    it 'successful' do
      put '/update', params: { id: stock.id,
                               name: "#{stock.name}!",
                               bearer_id: stock.bearer.id,
                               bearer_name: stock.bearer.name }, as: :json
      expect(Stock.count).to eq(1)
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.successful_update'))
    end

    it 'without id' do
      put '/update', params: { name: stock.name }, as: :json
      expect(Stock.count).to eq(1)
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.error.no_found'))
    end

    it 'without name' do
      put '/update', params: { id: stock.id }, as: :json
      expect(Stock.count).to eq(1)
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.error.no_update'))
    end

    it 'with existing name' do
      stock2 = FactoryBot.create :stock
      put '/update', params: { id: stock.id, name: stock2.name }, as: :json
      stock.reload
      expect(stock.name).not_to eq(stock2.name)
      expect(response).to have_http_status(200)
      expect(response.body).to eq('Name has already been taken')
    end

    it 'empty params' do
      put '/update', params: {}, as: :json
      expect(response).to have_http_status(200)
      expect(response.body).to eq(I18n.t('stock.error.no_found'))
    end

    context 'when updated bearer' do
      it 'new name' do
        expect(Stock.count).to eq(1)
        expect(Bearer.count).to eq(1)
        put '/update', params: { id: stock.id,
                                 name: stock.name,
                                 bearer_id: stock.bearer.id,
                                 bearer_name: "#{stock.bearer.name}!" }, as: :json
        expect(Stock.count).to eq(1)
        expect(Bearer.count).to eq(2)
        expect(Bearer.last.name).to eq("#{stock.bearer.name}!")
        expect(Stock.first.bearer_id).to eq(Bearer.last.id)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('stock.successful_update'))
      end

      it 'existing bearer name' do
        bearer = FactoryBot.create :bearer
        expect(stock.bearer.id).not_to eq(bearer.id)
        put '/update', params: { id: stock.id, bearer_name: bearer.name }, as: :json
        stock.reload
        expect(Stock.count).to eq(1)
        expect(Bearer.count).to eq(2)
        expect(bearer.id).to eq(stock.bearer.id)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('stock.successful_update'))
      end

      it 'existing bearer_id' do
        bearer = FactoryBot.create :bearer
        expect(stock.bearer.id).not_to eq(bearer.id)
        put '/update', params: { id: stock.id, bearer_id: bearer.id }, as: :json
        stock.reload
        expect(Stock.count).to eq(1)
        expect(Bearer.count).to eq(2)
        expect(bearer.id).to eq(stock.bearer.id)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('stock.successful_update'))
      end

      it 'existing bearer_name and bearer_id' do
        bearer = FactoryBot.create :bearer
        expect(stock.bearer.id).not_to eq(bearer.id)

        put '/update', params: { id: stock.id,
                                 bearer_name: bearer.name,
                                 bearer_id: bearer.id }, as: :json
        stock.reload
        expect(Stock.count).to eq(1)
        expect(Bearer.count).to eq(2)
        expect(bearer.id).to eq(stock.bearer.id)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('stock.successful_update'))
      end

      it 'existing bearer_id and NEW bearer_name' do
        bearer = FactoryBot.create :bearer
        expect(stock.bearer.id).not_to eq(bearer.id)

        put '/update', params: { id: stock.id,
                                 bearer_name: "#{bearer.name}!",
                                 bearer_id: bearer.id }, as: :json
        stock.reload
        expect(Stock.count).to eq(1)
        expect(Stock.first.bearer.name).to eq("#{bearer.name}!")
        expect(Bearer.count).to eq(3)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('stock.successful_update'))
      end

      it 'invalid bearer_id' do
        bearer = FactoryBot.create :bearer
        expect(stock.bearer.id).not_to eq(bearer.id)
        put '/update', params: { id: stock.id, bearer_id: '99999' }, as: :json
        stock.reload
        expect(Stock.count).to eq(1)
        expect(Stock.first.bearer.name).to eq(Stock.first.bearer.name)
        expect(Bearer.count).to eq(2)
        expect(response).to have_http_status(200)
        expect(response.body).to eq(I18n.t('bearer.error.not_found'))
      end
    end
  end
end
