# Avoid problems when running Capybara specs before regular ones, and fix the
# "Could not find a valid mapping for X". Part of the  solution is to use the
# Devise test helpers as explained on link A, but then you need to clear the
# fabricated objects, as explained on link B. Here's the equivalent code when
# using the Fabrication gem
#
# A - http://stackoverflow.com/questions/4230152/mocks-arent-working-with-rspec-and-devise
# B - http://stackoverflow.com/questions/6363471/could-not-find-a-valid-mapping-for-user-only-on-second-and-successive-t
if Rails.env.development? || Rails.env.test?
  ActionDispatch::Callbacks.after do
    Rails.logger.debug 'Reloading fabricators'
    Fabrication.clear_definitions
  end
end
