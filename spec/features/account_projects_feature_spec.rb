require 'spec_helper'

describe 'Account projects' do
  before do
    # Open signup page
    visit new_signup_path
    expect(current_path).to eq(new_signup_path)

    # Fill in valid details and submit signup form
    fill_in 'Your name',  with: 'Thomas Klemm'
    fill_in 'Company',    with: 'Rainmakers'
    fill_in 'Your email', with: 'thomas@rainmakers.com'
    fill_in 'password',   with: 'rainmaking123'
    click_button 'Sign up'

    # Instant sign in
    expect(current_path).to match(project_tweets_path(Project.first))
  end

  it "lists projects" do
    click_on 'Account'
    expect(current_path).to eq(account_projects_path)

    within('.projects-table') do
      expect(page).to have_content("1Rainmakers")
    end
  end

  it "new and create project" do
    visit account_projects_path
    click_on 'New project'

    fill_in 'Project name', with: "Second Rainmakers project"
    click_on 'Create Project'
    expect(page).to have_content("Project has been created")

    within('.projects-table') do
      expect(page).to have_content("1Second Rainmakers project")
      expect(page).to have_content("2Rainmakers")
    end

    # Permissions
    within('.navbar') do
      click_on 'Second Rainmakers project'
      expect(current_path).to match(/second-rainmakers-project/)
    end
  end

  it "edit and update project" do
    visit account_projects_path

    within('.projects-table') do
      click_on 'Edit'
    end

    fill_in 'Project name', with: "First Rainmakers project"
    click_on 'Update Project'
    expect(page).to have_content("Project has been updated")

    within('.projects-table') do
      expect(page).to have_content("First Rainmakers project")
    end
  end
end
