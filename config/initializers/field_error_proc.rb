# Do not add special markup for fields with validation errors.
#
# Additional markup should be specified within a custom form builder.
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
  html_tag.html_safe
}
