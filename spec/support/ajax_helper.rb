module AjaxHelper
  def wait_for_css(selector)
    sleep(1)
    until has_css?(selector) do sleep(0.1) end
    yield(find(selector))
  end
end
