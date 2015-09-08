class AnalyzersController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_course_editor

  # GET /6.006/analyzers/1/source
  def source
    @analyzer = Analyzer.find params[:id]
    db_file = @analyzer.db_file

    # NOTE: The CSP header provides some protection against an attacker who
    #       tries to serve active content (HTML+JS) using the server's origin.
    #       DbFile also explicitly disallows the HTML and XHTML MIME types.
    response.headers['Content-Security-Policy'] = "default-src 'none'"
    send_data @analyzer.contents, filename: @analyzer.file_name,
        type: db_file.f.content_type
  end

  # GET /6.006/analyzers/help
  def help
    render 'docker_analyzers/help'
  end
end
