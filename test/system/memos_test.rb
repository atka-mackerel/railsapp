require "application_system_test_case"

class MemosTest < ApplicationSystemTestCase
  setup do
    @memo = memos(:one)
  end

  test "visiting the index" do
    visit memos_url
    assert_selector "h1", text: "Memos"
  end

  test "creating a Memo" do
    visit memos_url
    click_on "New Memo"

    fill_in "Content", with: @memo.content
    fill_in "Raw content", with: @memo.raw_content
    fill_in "Title", with: @memo.title
    fill_in "Type", with: @memo.type
    click_on "Create Memo"

    assert_text "Memo was successfully created"
    click_on "Back"
  end

  test "updating a Memo" do
    visit memos_url
    click_on "Edit", match: :first

    fill_in "Content", with: @memo.content
    fill_in "Raw content", with: @memo.raw_content
    fill_in "Title", with: @memo.title
    fill_in "Type", with: @memo.type
    click_on "Update Memo"

    assert_text "Memo was successfully updated"
    click_on "Back"
  end

  test "destroying a Memo" do
    visit memos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Memo was successfully destroyed"
  end
end
