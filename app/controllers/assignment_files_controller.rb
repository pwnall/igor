class AssignmentFilesController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_user

  # GET /6.006/assignment_files/1/download
  def download
    @file = AssignmentFile.find params[:id]
    return bounce_user unless @file.can_read? current_user
    db_file = @file.db_file

    # NOTE: The CSP header provides some protection against an attacker who
    #       tries to serve active content (HTML+JS) using the server's origin.
    #       DbFile also explicitly disallows the HTML and XHTML MIME types.
    response.headers['Content-Security-Policy'] = "default-src 'none'"
    send_data @file.contents, filename: @file.file_name,
        type: db_file.f.content_type
  end
end
