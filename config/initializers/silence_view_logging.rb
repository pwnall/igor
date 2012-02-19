# Disable the "Rendered ..." lines that show up when rendering partials.
if Rails.env.production?
  ActionView::LogSubscriber.class_eval do
    def logger
      nil
    end
  end
end
