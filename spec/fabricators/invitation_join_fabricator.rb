Fabricator(:invitation_join, from: :'invitation/join') do
  invitation
  user
end
