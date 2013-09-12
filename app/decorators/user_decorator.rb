class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
end
