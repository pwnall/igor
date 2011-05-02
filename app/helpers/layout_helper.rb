module LayoutHelper
  def head_resources_tags
    [
      csrf_meta_tag,
      favicon_link_tag,
      stylesheet_link_tag(:pwnstyles, 'application', :cache => 'seven'),
      javascript_include_tag(:defaults, 'pwn-fx', 'grade-editor',
                             :cache => 'seven')
    ].join.html_safe
  end
end