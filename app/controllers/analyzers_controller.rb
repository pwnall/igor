class AnalyzersController < ApplicationController
  before_action :authenticated_as_admin

  # GET /analyzers/1/source
  def source
    @analyzer = Analyzer.find params[:id]
    db_file = @analyzer.db_file
    send_data @analyzer.full_db_file.f.file_contents,
              filename: db_file.f.original_filename,
              type: db_file.f.content_type
  end

  # GET /analyzers/help
  def help
    render 'script_analyzers/help'
  end
end
