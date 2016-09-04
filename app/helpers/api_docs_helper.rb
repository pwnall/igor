module ApiDocsHelper
  def api_docs_curl_example(&block)
    safe_join([
      '<pre><code>curl -i -H "Authorization: Bearer $API_TOKEN" '.html_safe,
      capture(&block).strip,
      '</code></pre>'.html_safe,
    ])
  end

  def api_docs_call(&block)
    safe_join([
      '<ul class="accordion" data-accordion data-multi-expand="true" data-allow-all-closed="true">'.html_safe,
      capture(&block),
      '</ul>'.html_safe,
    ])
  end

  def api_docs_call_section(title, is_active = false, &block)
    li_class= is_active ? ' is-active' : ''
    safe_join([
      %Q|<li class="accordion-item#{li_class}" data-accordion-item>|.html_safe,
      content_tag(:a, title, class: 'accordion-title', href: '#'),
      '<div class="accordion-content" data-tab-content>'.html_safe,
      capture(&block),
      '</div></li>'.html_safe,
    ])
  end

  def api_docs_call_summary(&block)
    api_docs_call_section 'Summary', true, &block
  end

  def api_docs_call_params(&block)
    api_docs_call_section 'Parameters', false do
      safe_join([
        '<p>The supported parameters are outlined below.</p>'.html_safe,
        '<table><tr><th>Parameter</th><th>Optional</th><th>Description</th><tr>'.html_safe,
        capture(&block),
        '</table>'.html_safe
      ])
    end
  end

  def api_docs_call_response(&block)
    api_docs_call_section 'Response', false do
      safe_join([
        '<p>The supported response fields are outlined below.</p>'.html_safe,
        '<table><tr><th>Response Field</th><th>Description</th><tr>'.html_safe,
        capture(&block),
        '</table>'.html_safe
      ])
    end
  end

  def api_docs_call_example(&block)
    api_docs_call_section 'Example', false, &block
  end
end
