RSpec::Matchers.define :authorize do |record, query|
  match do
    assigns(:_policy_authorized).include?([record, query])
  end

  failure_message_for_should do
    "Expected: #{ [record, query] }
    \n
    Was: #{ assigns(:_policy_authorized) }."
  end

  description do
    "authorize #{ query } on #{ record.try(:class) } record"
  end
end
