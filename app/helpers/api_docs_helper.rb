module ApiDocsHelper
  def api_docs_curl_example(&block)
    safe_join([
      '<pre><code>curl -i -H "Authorization: Bearer $API_TOKEN" '.html_safe,
      capture(&block).strip,
      '</code></pre>'.html_safe
    ])
  end
end
