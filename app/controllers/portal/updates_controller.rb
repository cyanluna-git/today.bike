module Portal
  class UpdatesController < BaseController
    def index
      @updates = PortalUpdateFeed.new(customer: current_customer).all
    end
  end
end
