# frozen_string_literal: true

module StocksService
  def create_stock(attrs)
    return I18n.t('bearer.error.not_found') unless Bearer.find_by(id: attrs[:bearer_id])

    stock = Stock.new(attrs)
    if stock.save
      I18n.t('stock.successful_create')
    else
      I18n.t('stock.error.occurred', errors: stock.errors.full_messages.join(', '))
    end
  end

  def update_stock(attrs)
    bearer_params = { id: attrs[:bearer_id], name: attrs[:bearer_name] }.compact
    bearer = Bearer.find_or_initialize_by(bearer_params)
    return I18n.t('bearer.error.not_found') unless bearer.valid?

    stock = Stock.find_by(id: attrs[:id])
    return I18n.t('stock.error.no_found') if stock.blank?

    stock.name = attrs[:name] if attrs[:name].present?
    stock.bearer = bearer.new_record? ? bearer.dup : bearer
    return I18n.t('stock.error.no_update') unless stock.changed?

    stock.save ? I18n.t('stock.successful_update') : stock.errors.full_messages.join(', ')
  end

  def delete_stock(attrs)
    return I18n.t('stock.error.no_found') unless Stock.find_by(id: attrs[:id])

    if Stock.delete(params[:id])
      I18n.t('stock.successful_delete')
    else
      I18n.t('errors.something_went_wrong')
    end
  end
end
