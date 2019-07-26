# frozen_string_literal: true

require 'rails_helper'

describe Tag, type: :model do
  let(:valid_tag) { FactoryBot.build(:tag) }

  shared_examples_for 'invalid' do
    it { expect(invalid_tag).to be_invalid }
  end

  describe 'バリデーション' do
    context 'nameが未入力の場合' do
      let(:invalid_tag) { Tag.new }
      it_behaves_like 'invalid'
    end

    context 'nameが重複するTagが存在する' do
      before do
        FactoryBot.create(:tag)
      end

      let(:invalid_tag) { valid_tag }
      it_behaves_like 'invalid'
    end
  end

  describe 'DB登録' do
    context 'idが重複する場合' do
      before do
        FactoryBot.create(:tag, id: 1, name: 'タグ1')
      end

      it 'エラーが発生する' do
        tag = FactoryBot.build(:tag, id: 1, name: 'タグ2')
        expect { tag.save }.to raise_error(StandardError)
      end
    end

    context 'エラーが無い場合' do
      it '正常に登録される' do
        expect { valid_tag.save }.to change { Tag.count }.by(1)
      end
    end
  end
  
  describe 'DB更新' do
    context 'idが存在しない場合' do
      it '登録される' do
        tag = FactoryBot.build(:tag)
        expect { tag.update(name: 'タグ更新') }.to change { Tag.count }.by(1)
      end
    end

    context 'エラーが無い場合' do
      before do
        FactoryBot.create(:tag, id: 1, name: 'タグ1')
      end

      it '正常に更新される' do
        tag = Tag.find(1)
        expect(tag.update(name: 'タグ更新')).to be_truthy
      end
    end
  end

  describe 'DB削除' do
    before do
      FactoryBot.create(:user, id: 1)
      FactoryBot.create(:memo, id: 1, user_id: 1)
      FactoryBot.create(:tag, id: 1)
    end

    context '紐づくMemoTagが存在する' do
      before do
        FactoryBot.create(:memo_tag, memo_id: 1, tag_id: 1)
      end

      it 'エラーが発生する' do
        expect { Tag.destroy!(1) }.to raise_error(StandardError)
      end
    end

    context '紐づくMemoTagが存在しない' do
      it '正常に削除される' do
        expect(Tag.destroy(1)).to be_truthy
      end
    end
    
  end
end
