require 'spec_helper'

describe 'Account projects' do
  include_context 'signup feature'

  it "lists projects" do
    click_on 'Account'
    expect(current_path).to eq(account_projects_path)

    within('.projects-table') do
      expect(page).to have_content("Rainmakers")
    end
  end

  it "new and create project" do
    visit account_projects_path
    click_on 'New project'

    fill_in 'Project name', with: "Second Rainmakers project"
    click_on 'Create Project'
    expect(page).to have_content("Project has been created")

    within('.projects-table') do
      expect(page).to have_content("Second Rainmakers project")
      expect(page).to have_content("Rainmakers")
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
      click_on 'Rename project'
    end

    fill_in 'Project name', with: "First Rainmakers project"
    click_on 'Update Project'
    expect(page).to have_content("Project has been updated")

    within('.projects-table') do
      expect(page).to have_content("First Rainmakers project")
    end
  end
end
