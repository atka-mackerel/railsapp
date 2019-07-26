# frozen_string_literal: true

require 'rails_helper'

describe Memo, type: :model do
  let(:valid_memo) { FactoryBot.build(:memo, user_id: 1) }

  describe 'バリデーション' do
    shared_examples_for 'invalid' do
      it { expect(invalid_memo).to be_invalid }
    end

    context 'Userが存在しない' do
      let(:invalid_memo) { valid_memo }
      it_behaves_like 'invalid'
    end

    context 'Userが存在する' do
      before do
        FactoryBot.create(:user, id: 1)
      end

      context 'タイトルが未入力の場合' do
        let(:invalid_memo) { valid_memo.tap { |m| m.title = '' } }
        it_behaves_like 'invalid'
      end

      context '全項目入力されている場合' do
        it 'should be valid' do
          expect(valid_memo).to be_valid
        end
      end
    end
  end

  describe 'DB登録' do
    context 'Userが登録されていない場合' do
      it 'エラーが発生する' do
        expect { FactoryBot.create(:memo) }.to raise_error(StandardError)
      end
    end

    context '同一idが登録されている場合' do
      before do
        FactoryBot.create(:user, id: 1)
        FactoryBot.create(:memo, id: 1)
      end

      it 'エラーが発生する' do
        memo = valid_memo.tap { |m| m.id = 1 }
        expect { memo.save }.to raise_error(StandardError)
      end
    end

    context '新規登録' do
      before do
        FactoryBot.create(:user, id: 1)
      end

      it '正常に登録される' do
        expect(valid_memo.save).to be_truthy
      end
    end
  end

  describe 'DB更新' do
    before do
      FactoryBot.create(:user, id: 1)
      FactoryBot.create(:memo, id: 1)
    end

    context '新規登録' do
      it '正常に更新される' do
        memo = Memo.find(1)
        expect(memo.update(title: 'タイトル2', text_content: 'テキスト入力２', draw_content: '手書き入力２')).to be_truthy
        expect(memo.save).to be_truthy
      end
    end
  end

  describe 'DB削除' do
    before do
      FactoryBot.create(:user, id: 1)
      FactoryBot.create(:memo, id: 1)
      FactoryBot.create(:memo, id: 2)
    end

    context 'Memo(id=1,2)が存在する状態でMemo(id=1)を削除' do
      it 'Memo(id=1)が削除される' do
        expect { Memo.destroy(1) }.to change { Memo.where(id: 1).count }.by(-1)
      end

      it 'Memo(id=2)が削除されない' do
        expect { Memo.destroy(1) }.not_to(change { Memo.where(id: 2).count })
      end

      context 'Memo(id=1,2)、MemoTag(memo_id=1,2)が存在する状態でMemo(id=1)を削除' do
        before do
          FactoryBot.create(:tag, id: 1, name: 'タグ1')
          FactoryBot.create(:tag, id: 2, name: 'タグ2')

          FactoryBot.create(:memo_tag, memo_id: 1, tag_id: 1)
          FactoryBot.create(:memo_tag, memo_id: 1, tag_id: 2)
          FactoryBot.create(:memo_tag, memo_id: 2, tag_id: 1)
          FactoryBot.create(:memo_tag, memo_id: 2, tag_id: 2)
        end

        it 'Memo(id=1)が削除される' do
          expect { Memo.destroy(1) }.to change { Memo.where(id: 1).count }.by(-1)
        end

        it 'MemoTag(memo_id=1)が削除される' do
          expect { Memo.destroy(1) }.to change { MemoTag.where(memo_id: 1).count }.by(-2)
        end

        it 'MemoTag(memo_id=2)が削除されない' do
          expect { Memo.destroy(1) }.not_to(change { MemoTag.where(memo_id: 2).count })
        end

        it 'Tagが削除されない' do
          expect { Memo.destroy(1) }.not_to(change { Tag.count })
        end
      end
    end
  end
end
