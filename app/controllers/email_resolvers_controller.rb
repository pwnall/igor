class EmailResolversController < ApplicationController
  before_action :authenticated_as_admin
  before_action :set_email_resolver, only: [:show, :edit, :update, :destroy]

  # GET /email_resolvers
  def index
    @email_resolvers = EmailResolver.all
  end

  # GET /email_resolvers/1
  def show
  end

  # GET /email_resolvers/new
  def new
    @email_resolver = EmailResolver.new
  end

  # GET /email_resolvers/1/edit
  def edit
  end

  # POST /email_resolvers
  def create
    @email_resolver = EmailResolver.new email_resolver_params

    if @email_resolver.save
      redirect_to email_resolvers_url,
          notice: "@#{@email_resolver.domain} e-mail resolver created."
    else
      render :new
    end
  end

  # PATCH/PUT /email_resolvers/1
  def update
    if @email_resolver.update email_resolver_params
      redirect_to email_resolvers_url,
          notice: "@#{@email_resolver.domain} e-mail resolver created."
    else
      render :edit
    end
  end

  # DELETE /email_resolvers/1
  def destroy
    @email_resolver.destroy
    redirect_to email_resolvers_url, notice: 'Resolver removed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email_resolver
      @email_resolver = EmailResolver.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def email_resolver_params
      params.require(:email_resolver).permit :domain, :ldap_server,
          :ldap_auth_dn, :ldap_password, :ldap_search_base, :name_ldap_key,
          :dept_ldap_key, :year_ldap_key, :user_ldap_key, :use_ldaps
    end
end
