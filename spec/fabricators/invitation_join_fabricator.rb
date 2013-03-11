Fabricator(:invitation_join, from: :'invitation/join') do
  invitation
  # code { |attrs| attrs[:invitation].code }

  user
end
