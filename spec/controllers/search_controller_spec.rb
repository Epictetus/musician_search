require 'spec_helper'

describe SearchController do

  describe "GET info" do
    it "should be successful" do
      get "info"
      response.should be_success
    end
  end

end
