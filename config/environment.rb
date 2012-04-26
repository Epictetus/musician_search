# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ArtistSearch::Application.initialize!

ActiveResource::Base.logger = ActiveRecord::Base.logger
