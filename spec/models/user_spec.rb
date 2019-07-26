require 'rails_helper'

describe User, type: :model do
  let(:valid_user) { User.new(name: 'テスト　太郎', login_id: 'testuser', password: 'p@ssw0rd', password_confirmation: 'p@ssw0rd') }

  describe 'バリデーション' do
    shared_examples_for 'invalid' do
      it { expect(invalid_user).to be_invalid }
    end

    context '名前、ログインID、パスワードが未入力の場合' do
      let(:invalid_user) { User.new }
      it_behaves_like 'invalid'
    end

    context '名前が未入力の場合' do
      let(:invalid_user) { valid_user.tap { |u| u.name = '' } }
      it_behaves_like 'invalid'
    end

    context 'ログインIDが未入力の場合' do
      let(:invalid_user) { valid_user.tap { |u| u.login_id = '' } }
      it_behaves_like 'invalid'
    end
  
    context 'パスワードが未入力の場合' do
      let(:invalid_user) { valid_user.tap { |u| u.password_digest = '' } }
      it_behaves_like 'invalid'
    end

    context 'パスワード(確認)が未入力の場合' do
      let(:invalid_user) { valid_user.tap { |u| u.password_confirmation = '' } }
      it_behaves_like 'invalid'
    end

    context 'パスワードとパスワード(確認)が違う場合' do
      let(:invalid_user) { valid_user.tap { |u| u.password = 'different' } }
      it_behaves_like 'invalid'
    end

    context '同一login_idのレコードが存在する' do
      before do
        FactoryBot.create(:user, login_id: 'testuser')
      end

      let(:invalid_user) { valid_user }
      it_behaves_like 'invalid'
    end

    context '全項目不備がない場合、バリデーションエラーにならない' do
      it 'should be valid' do
        expect(valid_user).to be_valid
      end
    end
  end

  describe 'DB登録' do
    context '同一idのレコードが存在する' do
      it 'Errorが発生する' do
        FactoryBot.create(:user, login_id: 'testuser')

        user = valid_user.tap do |u|
          u.id = 1
          u.login_id = 'testuser'
        end

        expect { user.save! }.to raise_error(StandardError)
      end
    end

    context 'エラーなし' do
      it '正常に登録される' do
        expect(valid_user.save).to be_truthy
      end
    end
  end

  describe 'DB削除' do
    before do
      FactoryBot.create(:user, id: 1, login_id: 'testuser1')
      FactoryBot.create(:user, id: 2, login_id: 'testuser2')
    end

    context 'User(id=1,2)が存在する状態でUser(id=1)を削除' do
      it 'User(id=1)が削除される' do
        expect { User.destroy(1) }.to change { User.where(id: 1).count }.by(-1)
      end

      it 'User(id=2)が削除されない' do
        expect { User.destroy(1) }.not_to(change{ User.where(id: 2).count })
      end
    end

    context 'User(id=1,2)、Memo(user_id=1,2)が存在する状態でUser(id=1)を削除' do
      before do
        FactoryBot.create(:memo, id: 1, user_id: 1)
        FactoryBot.create(:memo, id: 2, user_id: 1)
        FactoryBot.create(:memo, id: 3, user_id: 2)
        FactoryBot.create(:memo, id: 4, user_id: 2)
      end

      it 'User(id=1)が削除される' do
        expect { User.destroy(1) }.to change { User.where(id: 1).count }.by(-1)
      end

      it 'User(id=1)に紐づくMemoが削除される' do
        expect { User.destroy(1) }.to change { Memo.where(user_id: 1).count }.by(-2)
      end

      it 'User(id=2)に紐づくMemoが削除されない' do
        expect { User.destroy(1) }.not_to(change{ Memo.where(user_id: 2).count })
      end

      context 'User(id=1,2)、Memo(user_id=1,2)、MemoTag(memo_id=1,2,3,4)が存在する状態でUser(id=1)を削除' do
        before do
          FactoryBot.create(:tag, id: 1, name: 'タグ１')
          FactoryBot.create(:tag, id: 2, name: 'タグ２')
          FactoryBot.create(:tag, id: 3, name: 'タグ３')

          FactoryBot.create(:memo_tag, memo_id: 1, tag_id: 1)
          FactoryBot.create(:memo_tag, memo_id: 1, tag_id: 2)
          FactoryBot.create(:memo_tag, memo_id: 2, tag_id: 2)
          FactoryBot.create(:memo_tag, memo_id: 2, tag_id: 3)
          FactoryBot.create(:memo_tag, memo_id: 3, tag_id: 1)
          FactoryBot.create(:memo_tag, memo_id: 3, tag_id: 2)
          FactoryBot.create(:memo_tag, memo_id: 4, tag_id: 1)
          FactoryBot.create(:memo_tag, memo_id: 4, tag_id: 2)
        end

        it 'User(id=1)が削除される' do
          expect { User.destroy(1) }.to change { User.where(id: 1).count }.by(-1)
        end

        it 'User(id=1)に紐づくMemoが削除される' do
          expect { User.destroy(1) }.to change { Memo.where(user_id: 1).count }.by(-2)
        end

        it 'Memo(id=1,2)に紐づくMemoTagが削除される' do
          expect { User.destroy(1) }.to change { MemoTag.where(memo_id: %w[1 2]).count }.by(-4)
        end

        it 'Memo(id=3,4)に紐づくMemoTagが削除されない' do
          expect { User.destroy(1) }.not_to(change{ MemoTag.where(memo_id: %w[3 4]).count })
        end

        it 'Tagが削除されない' do
          expect { User.destroy(1) }.not_to(change{ Tag.count })
        end
      end
    end
  end
end
