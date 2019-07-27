# frozen_string_literal: true

require 'rails_helper'

describe MemoTag, type: :model do
  let(:valid_memo_tag) { FactoryBot.build(:memo_tag) }

  describe 'バリデーション' do
    shared_examples_for 'invalid' do
      it { expect(invalid_memo_tag).to be_invalid }
    end

    before do
      FactoryBot.create(:user, id: 1)
    end

    context 'Tagが存在しない場合' do
      before do
        FactoryBot.create(:memo, id: 1, user_id: 1)
      end

      let(:invalid_memo_tag) { valid_memo_tag }
      it_behaves_like 'invalid'
    end

    context 'Memoが存在しない場合' do
      before do
        FactoryBot.create(:tag, id: 1)
      end

      let(:invalid_memo_tag) { valid_memo_tag }
      it_behaves_like 'invalid'
    end

    context 'Memo、Tagが存在しない場合' do
      let(:invalid_memo_tag) { valid_memo_tag }
      it_behaves_like 'invalid'
    end

    context 'Memo、Tagが存在する場合' do
      before do
        FactoryBot.create(:memo, id: 1)
        FactoryBot.create(:tag, id: 1)
      end

      context 'メモIDが未入力の場合' do
        let(:invalid_memo_tag) { valid_memo_tag.tap { |mt| mt.memo_id = nil } }
        it_behaves_like 'invalid'
      end

      context 'タグIDが未入力の場合' do
        let(:invalid_memo_tag) { valid_memo_tag.tap { |mt| mt.tag_id = nil } }
        it_behaves_like 'invalid'
      end

      context '全て未入力の場合' do
        let(:invalid_memo_tag) { MemoTag.new }
        it_behaves_like 'invalid'
      end

      context '全項目入力されている場合' do
        it 'should be valid' do
          expect(valid_memo_tag).to be_valid
        end
      end
    end
  end
end
