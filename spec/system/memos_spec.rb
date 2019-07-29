# frozen_string_literal: true

require 'rails_helper'

describe 'Cloud Memo', type: :system do
  let(:first_visit_path) { login_path }
  let(:after_login_path) {}
  let(:user1) { FactoryBot.build(:user, id: 1) }
  let(:user2) { FactoryBot.build(:user, id: 2) }
  let(:memo1) { FactoryBot.build(:memo, id: 1, title: 'メモ１', user_id: 1) }
  let(:memo2) { FactoryBot.build(:memo, id: 2, title: 'メモ２', user_id: 1) }
  let(:tag1) { FactoryBot.build(:tag, id: 1, name: 'タグ1') }
  let(:tag2) { FactoryBot.build(:tag, id: 2, name: 'タグ2') }
  let(:tag3) { FactoryBot.build(:tag, id: 3, name: 'タグ3') }
  let(:memo_tag1) { FactoryBot.build(:memo_tag, memo_id: 1, tag_id: 1) }
  let(:memo_tag2) { FactoryBot.build(:memo_tag, memo_id: 1, tag_id: 2) }

  before do
    user1.save!
    user2.save!
    memo1.save!
    memo2.save!
    tag1.save!
    tag2.save!
    memo_tag1.save!
    memo_tag2.save!
  end

  # ログイン
  RSpec.shared_context 'login', :login do
    before do
      visit first_visit_path
      fill_in 'session_login_id', with: login_user.login_id
      fill_in 'session_password', with: login_user.password
      click_button 'ログイン'
    end
  end

  # ログイン後に画面遷移(to after_login_path)
  RSpec.shared_context 'visit_after_login', :visit_after_login do
    include_context 'login'
    before do
      visit after_login_path
    end
  end

  shared_examples_for 'to_login' do
    it 'ログイン画面に遷移する' do
      visit first_visit_path
      expect(current_path).to eq login_path
    end
  end

  RSpec.configure do |config|
    config.include_context 'login', :login
    config.include_context 'visit_after_login', :visit_after_login
  end

  describe 'メモ一覧画面' do
    context 'ログインしていない場合' do
      let(:first_visit_path) { memos_path }

      it_behaves_like 'to_login'

      context 'ログイン後', :login do
        let(:login_user) { user1 }

        it '一覧画面に遷移する' do
          expect(current_path).to eq memos_path
        end
      end
    end
    
    context 'user1でログインしている場合', :visit_after_login do
      let(:login_user) { user1 }
      let(:after_login_path) { memos_path }

      it 'メモ１、メモ２が表示される' do
        expect(page).to have_content(memo1.title)
        expect(page).to have_content(memo2.title)
      end

      context 'キーワードに"メモ１"を入力し絞り込むボタン押下' do
        before do
          fill_in 'memos_keyword',	with: memo1.title
          click_button '絞り込む'
        end

        it 'メモ１が表示され、メモ２が表示されない' do
          expect(page).to have_content(memo1.title)
          expect(page).not_to have_content(memo2.title)
        end

        context 'リセットリンク押下' do
          it '絞り込みが解除され、メモ１、メモ２が表示される' do
            click_link 'リセット'
            expect(page).to have_content(memo1.title)
            expect(page).to have_content(memo2.title)
          end
        end
        
      end

      context '新規作成ボタン押下' do
        before do
          click_link '新規作成'
        end

        it '登録画面に遷移する' do
          expect(current_path).to eq new_memo_path
        end
      end

      context 'タイトルリンク押下' do
        it '詳細画面に遷移する' do
          click_link memo1.title
          expect(current_path).to eq memo_path(memo1)
        end
      end

      context '編集リンク押下' do
        it '編集画面に遷移する' do
          find("#memos_edit_link#{memo1.id}").click
          expect(current_path).to eq edit_memo_path(memo1)
        end
      end

      context '削除リンク押下' do
        before do
          find("#memos_delete_link#{memo1.id}").click
        end

        it '確認ダイアログが表示される' do
          expect(page.driver.browser.switch_to.alert.text).to eq '削除します。よろしいですか？'
        end

        context '確認ダイアログでOK押下' do
          it 'メモが削除される' do
            page.driver.browser.switch_to.alert.accept
            expect(page).not_to have_content(memo1.title)
            expect(page).to have_content(memo2.title)
          end
        end

        context '確認ダイアログでキャンセル押下' do
          it 'メモが削除されない' do
            page.driver.browser.switch_to.alert.dismiss
            expect(page).to have_content(memo1.title)
            expect(page).to have_content(memo2.title)
          end
        end
      end
    end

    context 'user2でログインしている場合', :login do
      let(:create_memo_num) { 0 }
      let(:login_user) { user2 }

      before do
        FactoryBot.rewind_sequences
        FactoryBot.create_list(:memo, create_memo_num, user_id: user2.id)
        visit memos_path
      end

      it 'メモ１、メモ２が表示されない' do
        expect(page).not_to have_content(memo1.title)
        expect(page).not_to have_content(memo2.title)
        expect(page).to have_content('メモがありません')
      end

      context 'メモが1ページに収まる場合' do
        let(:create_memo_num) { 25 }

        it '1ページに全件表示される' do
          expect(page).to have_content('25件のメモが表示されています')
          (1..25).each { |n| expect(page).to have_content("メモタイトル#{n}") }
        end
      end
      
      context 'メモが1ページに収まらない場合' do
        let(:create_memo_num) { 100 }

        context 'ページ番号リンク押下' do
          it '押下したページのデータが表示される' do
            find('.pagination a', text: '2').click
            expect(page).to have_content('全100 件中 26 - 50 件のメモが表示されています')
            (26..50).each { |n| expect(page).to have_content("メモタイトル#{n}") }
          end
        end

        context '›リンク押下' do
          it '次ページのデータが表示される' do
            find('.pagination a', text: '›').click
            expect(page).to have_content('全100 件中 26 - 50 件のメモが表示されています')
            (26..50).each { |n| expect(page).to have_content("メモタイトル#{n}") }
          end
        end

        context '»リンク押下' do
          it '最終ページのデータが表示される' do
            find('.pagination a', text: '»').click
            expect(page).to have_content('全100 件中 76 - 100 件のメモが表示されています')
            (76..100).each { |n| expect(page).to have_content("メモタイトル#{n}") }
          end
        end

        context '‹リンク押下' do
          before do
            find('.pagination a', text: '»').click
          end

          it '前ページのデータが表示される' do
            find('.pagination a', text: '‹').click
            expect(page).to have_content('全100 件中 51 - 75 件のメモが表示されています')
            (51..75).each { |n| expect(page).to have_content("メモタイトル#{n}") }
          end
        end

        context '«リンク押下' do
          before do
            find('.pagination a', text: '»').click
          end

          it '1ページ目のデータが表示される' do
            find('.pagination a', text: '«').click
            expect(page).to have_content('全100 件中 1 - 25 件のメモが表示されています')
            (1..25).each { |n| expect(page).to have_content("メモタイトル#{n}") }
          end
        end
      end
    end
  end
  
  describe '新規登録画面' do
    context 'ログインしていない場合' do
      let(:first_visit_path) { new_memo_path }

      it_behaves_like 'to_login'

      context 'ログイン後', :login do
        let(:login_user) { user1 }

        it '登録画面に遷移する' do
          expect(current_path).to eq new_memo_path
        end
      end
    end

    context 'ログインしている場合', :visit_after_login do
      let(:login_user) { user1 }
      let(:after_login_path) { new_memo_path }

      let(:memo3) { Memo.new }
      let(:memo4) { Memo.new(id: 3, title: 'メモ４') }
      let(:memo5) { FactoryBot.build(:memo, id: 3, title: 'メモ５', user_id: 1) }
      let(:new_tags) {}

      context '登録ボタン押下' do
        before do
          # タイトル入力
          fill_in 'memo_title',	with: new_memo.title
          # テキスト入力
          fill_in 'memo_text_content',	with: new_memo.text_content
          # 手書き入力
          if new_memo.draw_content.present?
            click_button '編集'
            wait_for_css('#btn-draw-complete', &:click)
          end
          # タグ追加
          if new_tags
            click_button 'タグ編集'
            new_tags.each do |item|
              fill_in 'txt-add-tag',	with: item.name
              click_button 'タグ追加'
            end
          end

          click_button '登録'
        end

        context '全項目未入力の状態' do
          let(:new_memo) { memo3 }
          it 'タイトル未入力のエラーとなり、登録画面が再描画される' do
            expect(current_path).to eq memos_path
            expect(find('#errors_area')).to have_content('タイトルを入力してください')
          end
        end
      
        context 'タイトルのみ入力した状態' do
          let(:new_memo) { memo4 }
          it '登録が完了し、詳細画面にタイトルが表示される' do
            expect(current_path).to eq memo_path(memo4)
            expect(page).to have_content(memo4.title)
          end
        end

        context '全項目入力した状態' do
          let(:new_memo) { memo5 }
          let(:new_tags) { [tag1, tag2] }
          it '登録が完了し、詳細画面に入力内容が表示される' do
            expect(current_path).to eq memo_path(memo5)
            expect(page).to have_content(memo5.title)
            expect(page).to have_content(memo5.text_content)
            expect(find('.show-img')[:src]).to eq memo5.draw_content
            expect(find('.tag-area')).to have_content(tag1.name)
            expect(find('.tag-area')).to have_content(tag2.name)
          end
        end
      end

      context 'クリアボタン押下' do
        before do
          # 手書き入力
          click_button '編集'
          wait_for_css('#btn-draw-complete', &:click)
          click_button 'クリア'
        end

        it '手書き入力がクリアされる' do
          expect(find('#hidden-content', visible: false)[:value]).to eq ''
        end
      end

      context 'メモ一覧リンク押下' do
        it '一覧画面に遷移する' do
          find('.main a', text: 'メモ一覧').click
          expect(current_path).to eq memos_path
        end
      end
    end
  end

  describe '編集画面' do
    context 'ログインしていない場合' do
      let(:first_visit_path) { edit_memo_path(memo1) }

      it_behaves_like 'to_login'

      context 'ログイン後', :login do
        let(:login_user) { user1 }

        it '登録画面に遷移する' do
          expect(current_path).to eq edit_memo_path(memo1)
        end
      end
    end

    context 'ログインしている場合', :visit_after_login do
      let(:login_user) { user1 }
      let(:after_login_path) { edit_memo_path(memo1) }

      let(:memo3) { Memo.new }
      let(:memo4) { Memo.new(id: 3, title: 'メモ４') }
      let(:memo5) { FactoryBot.build(:memo, id: 3, title: 'メモ５', user_id: 1) }
      let(:new_tags) {}
      let(:del_tags) {}

      context '更新ボタン押下' do
        before do
          # タイトル入力
          fill_in 'memo_title',	with: new_memo.title
          # テキスト入力
          fill_in 'memo_text_content',	with: new_memo.text_content
          # 手書き入力
          if new_memo.draw_content.present?
            click_button '編集'
            wait_for_css('#btn-draw-complete', &:click)
          end
          if new_tags || del_tags
            click_button 'タグ編集'
            # タグ追加
            new_tags&.each do |item|
              fill_in 'txt-add-tag',	with: item.name
              click_button 'タグ追加'
            end
            # タグ削除
            del_tags&.each do |item|
              find("a[tag-name='#{item.name}']").click
            end
          end
          click_button '更新'
        end

        context '全項目未入力の状態' do
          let(:new_memo) { memo3 }
          it 'タイトル未入力のエラーとなり、登録画面が再描画される' do
            expect(current_path).to eq memo_path(memo1)
            expect(find('#errors_area')).to have_content('タイトルを入力してください')
          end
        end
      
        context 'タイトルのみ入力した状態' do
          let(:new_memo) { memo4 }
          it '登録が完了し、詳細画面にタイトルが表示される' do
            expect(current_path).to eq memo_path(memo1)
            expect(page).to have_content(memo4.title)
          end
        end

        context '全項目入力した状態' do
          let(:new_memo) { memo5 }
          let(:new_tags) { [tag3] }
          let(:del_tags) { [tag2] }
          it '登録が完了し、詳細画面に入力内容が表示される' do
            expect(current_path).to eq memo_path(memo1)
            expect(page).to have_content(memo5.title)
            expect(page).to have_content(memo5.text_content)
            expect(find('.show-img')[:src]).to eq memo5.draw_content
            expect(find('.tag-area')).to have_content(tag1.name)
            expect(find('.tag-area')).to have_content(tag3.name)
          end
        end
      end

      context 'クリアボタン押下' do
        before do
          # 手書き入力
          click_button '編集'
          wait_for_css('#btn-draw-complete', &:click)
          click_button 'クリア'
        end

        it '手書き入力がクリアされる' do
          expect(find('#hidden-content', visible: false)[:value]).to eq ''
        end
      end

      context 'メモ一覧リンク押下' do
        it '一覧画面に遷移する' do
          find('.main a', text: 'メモ一覧').click
          expect(current_path).to eq memos_path
        end
      end

      context '参照リンク押下' do
        it '詳細画面に遷移する' do
          find('.main a', text: '参照').click
          expect(current_path).to eq memo_path(memo1)
        end
      end
    end
  end

  describe '詳細画面' do
    context 'ログインしていない場合' do
      let(:first_visit_path) { memo_path(memo1) }

      it_behaves_like 'to_login'

      context 'ログイン後', :login do
        let(:login_user) { user1 }

        it '詳細画面に遷移する' do
          expect(current_path).to eq memo_path(memo1)
        end
      end
    end
    
    context 'ログインしている場合', :visit_after_login do
      let(:login_user) { user1 }
      let(:after_login_path) { memo_path(memo1) }
      
      context '編集リンク押下' do
        it '編集画面に遷移する' do
          find('.main a', text: '編集').click
          expect(current_path).to eq edit_memo_path(memo1)
        end
      end
      
      context 'メモ一覧リンク押下' do
        it '一覧画面に遷移する' do
          find('.main a', text: 'メモ一覧').click
          expect(current_path).to eq memos_path
        end
      end

      context 'タグリンク押下' do
        it 'メモ一覧画面に遷移し、タグで絞り込まれた結果が表示される' do
          find('a', text: tag1.name).click
          expect(current_path).to eq memos_search_path
          expect(find('#memos_keyword')[:value]).to eq tag1.name
          expect(find('#memo-result')).to have_content memo1.title
          expect(find('#memo-result')).not_to have_content memo2.title
        end
      end
    end
  end
end
