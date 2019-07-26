require 'rails_helper'

describe CmntsrchController, type: :controller do
  let(:custom_params) { {} }
  let(:session) { {} }
  let(:params) do
    {
      youtube_search_condition: {
        q: '',
        video_id: '',
        published_after: '',
        published_before: '',
        with_comment: false,
        order: ''
      }
    }
  end

  describe 'GET #index' do
    before do
      get :index, params: {}, session: {}
    end

    it 'ステータスコード200となる' do
      expect(response).to have_http_status(:ok)
    end

    it '変数@search_conditionが正しい' do
      expect(assigns(:search_condition)).to be_a_new(YoutubeSearchCondition)
    end

    it 'テンプレートindexをレンダリングする' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #search' do
    before do
      get :search, params: params.deep_merge!(custom_params), session: session
    end

    context 'リクエストに不備がない場合' do
      it 'ステータスコード200となる' do
        expect(response).to have_http_status(:ok)
      end

      context 'パラメータpage_tokenが無い場合' do
        it '変数@next_page_tokenがnilとなる' do
          expect(assigns(:next_page_token)).to eq nil
        end
      end

      context 'パラメータpage_tokenがある場合' do
        let(:custom_params) { { page_token: 'page_token' } }
        let(:session) do
          {
            search_condition: {
              'q': 'Test',
              'with_comment': false
            }
          }
        end

        it '変数@next_page_tokenが正しい' do
          expect(assigns(:next_page_token)).to eq 'page_token'
        end

        it '変数@search_conditionが正しい' do
          prms = { page_token: 'page_token', q: 'Test' }
          expect(assigns(:search_condition)).to eq prms
        end

        it '変数@session_search_conditionが正しい' do
          prms = { q: 'Test', with_comment: false }
          expect(assigns(:session_search_condition)).to eq prms
        end
      end

      it '変数@search_resultにエラーが無い' do
        expect(assigns(:search_result).errors).to be_nil
      end

      it 'テンプレートcmntsrch/searchをレンダリングする' do
        expect(response).to render_template 'cmntsrch/search'
      end
    end

    context 'リクエストに不備がある' do
      let(:custom_params) { { page_token: 'page_token' } }
      let(:session) do
        {
          search_condition: {
            'order': 'invalid',
            'with_comment': false
          }
        }
      end

      it 'ステータスコード500となる' do
        expect(response).to have_http_status(:internal_server_error)
      end

      it '変数@search_resultにエラーがある' do
        expect(assigns(:search_result).errors).not_to be_nil
      end

      it 'テンプレートcmntsrch/searchをレンダリングする' do
        expect(response).to render_template 'cmntsrch/search'
      end
    end
  end
  
  describe 'GET #comments' do
    let(:params) { { video_id: '', page_token: '' } }

    before do
      get :comments, format: :json, params: params.deep_merge!(custom_params), session: session
    end

    context 'リクエストに不備がない場合' do
      let(:custom_params) { { video_id: 'WJzSBLCaKc8' } }

      it 'ステータスコード200となる' do
        expect(response).to have_http_status(:ok)
      end

      it '変数@search_conditionが正しい' do
        prm = { video_id: 'WJzSBLCaKc8', page_token: '' }
        expect(assigns(:search_condition).to_h.symbolize_keys).to eq prm
      end

      it '変数@comment_threadsにエラーが無い' do
        expect(assigns(:comment_threads).errors).to be_nil
      end

      it 'テンプレートcmntsrch/commentsをレンダリングする' do
        expect(response).to render_template 'cmntsrch/_comments'
      end
    end

    context 'リクエストに不備がある場合' do
      it 'ステータスコード500となる' do
        expect(response).to have_http_status(:internal_server_error)
      end

      it '変数@comment_threadsにエラーがある' do
        expect(assigns(:comment_threads).errors).not_to be_nil
      end

      it 'テンプレートcmntsrch/commentsをレンダリングする' do
        expect(response).to render_template 'cmntsrch/_comments'
      end
    end
  end
end
