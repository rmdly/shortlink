class RedirectsController < ApplicationController
  # A 302 on purpose: a permanent redirect would be cached by the browser and
  # we would never hear about the visit again.
  def show
    link = Link.find_by!(slug: params[:slug])
    link.visits.create! referrer: request.referer, user_agent: request.user_agent

    redirect_to link.url, allow_other_host: true
  end
end
