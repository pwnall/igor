require "spec_helper"

describe RecitationSectionsController do
  describe "routing" do

    it "routes to #index" do
      get("/recitation_sections").should route_to("recitation_sections#index")
    end

    it "routes to #new" do
      get("/recitation_sections/new").should route_to("recitation_sections#new")
    end

    it "routes to #show" do
      get("/recitation_sections/1").should route_to("recitation_sections#show", :id => "1")
    end

    it "routes to #edit" do
      get("/recitation_sections/1/edit").should route_to("recitation_sections#edit", :id => "1")
    end

    it "routes to #create" do
      post("/recitation_sections").should route_to("recitation_sections#create")
    end

    it "routes to #update" do
      put("/recitation_sections/1").should route_to("recitation_sections#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/recitation_sections/1").should route_to("recitation_sections#destroy", :id => "1")
    end

  end
end
